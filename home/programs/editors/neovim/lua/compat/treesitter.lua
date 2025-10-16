-- Treesitter compatibility shims for Neovim 0.11+
-- Provides backward compatibility for plugins expecting nvim-treesitter API

local M = {}

-- Setup all compatibility shims
function M.setup()
  -- Compatibility for `nvim-treesitter.query`
  package.preload["nvim-treesitter.query"] = function()
    local q
    local ok = pcall(function()
      q = vim.treesitter and vim.treesitter.query or nil
    end)
    if not ok or type(q) ~= "table" then
      local ok_tsq, tsq = pcall(require, "nvim-treesitter.ts_query")
      if ok_tsq then
        q = tsq
      else
        q = {}
      end
    end

    local Query = {}
    
    local function wrap_query(obj)
      if type(obj) ~= "table" then
        return obj
      end
      local info = { captures = obj.captures or {}, patterns = obj.patterns or {} }
      local wrapper = { captures = obj.captures, info = info }
      setmetatable(wrapper, {
        __index = function(_, k)
          local v = obj[k]
          if type(v) == "function" then
            return function(_, ...)
              return v(obj, ...)
            end
          end
          return v
        end,
      })
      return wrapper
    end

    function Query.get_query(lang, name)
      if q.get_query then
        return wrap_query(q.get_query(lang, name))
      end
      if q.get then
        return wrap_query(q.get(lang, name))
      end
      return nil
    end

    function Query.get(lang, name)
      if q.get then
        return wrap_query(q.get(lang, name))
      end
      if q.get_query then
        return wrap_query(q.get_query(lang, name))
      end
      return nil
    end

    function Query.get_files(lang, name, is_included)
      if q.get_files then
        return q.get_files(lang, name, is_included)
      end
      return {}
    end

    function Query.get_capture_matches_recursively(bufnr, capture_string, query_group)
      if type(capture_string) ~= "string" then
        return {}
      end
      local capture = capture_string
      if type(capture) == "string" and capture:sub(1, 1) == "@" then
        capture = capture:sub(2)
      end

      local ts = vim.treesitter
      if not (ts and ts.get_parser) then
        return {}
      end
      local parser = ts.get_parser(bufnr)
      if not parser then
        return {}
      end

      local results = {}
      parser:for_each_tree(function(tree, lang_tree)
        local root = tree:root()
        local lang = lang_tree:lang()
        local qry
        if q.get then
          qry = q.get(lang, query_group)
        elseif q.get_query then
          qry = q.get_query(lang, query_group)
        end
        if not qry then
          return
        end
        local start_row, _, end_row, _ = root:range()
        for _, match, _ in qry:iter_matches(root, bufnr, start_row, end_row + 1) do
          for id, nodes in pairs(match) do
            local name = qry.captures and qry.captures[id]
            if name == capture and nodes and nodes[1] then
              local node = nodes[#nodes]
              local srow, scol, erow, ecol = node:range()
              table.insert(results, { node = { start_pos = { srow, scol }, end_pos = { erow, ecol } } })
            end
          end
        end
      end)
      return results
    end

    function Query.has_query_files(lang, name)
      local files = {}
      if q.get_files then
        local ok_files, res = pcall(q.get_files, lang, name, true)
        if ok_files and type(res) == "table" then
          files = res
        end
      end
      return #files > 0
    end

    function Query.parse(lang, query_string)
      if q.parse then
        return q.parse(lang, query_string)
      end
      return nil
    end

    function Query.get_node_text(node, bufnr)
      if vim.treesitter and vim.treesitter.get_node_text then
        return vim.treesitter.get_node_text(node, bufnr)
      end
      local ok_ts_utils, ts_utils = pcall(require, "nvim-treesitter.ts_utils")
      if ok_ts_utils and ts_utils.get_node_text then
        return ts_utils.get_node_text(node, bufnr)
      end
      return ""
    end

    return Query
  end

  -- Compatibility for `nvim-treesitter.ts_utils`
  package.preload["nvim-treesitter.ts_utils"] = function()
    local Utils = {}

    function Utils.update_selection(bufnr, range, selection_mode)
      local api = vim.api
      local start_row, start_col, end_row, end_col = unpack(range)
      selection_mode = selection_mode or "v"

      local mode = api.nvim_get_mode()
      if mode.mode ~= selection_mode then
        local sm = api.nvim_replace_termcodes(selection_mode, true, true, true)
        vim.cmd.normal({ sm, bang = true })
      end

      local end_col_offset = 1
      if selection_mode == "v" and vim.o.selection == "exclusive" then
        end_col_offset = 0
      end

      api.nvim_win_set_cursor(0, { start_row + 1, start_col })
      vim.cmd("normal! o")
      api.nvim_win_set_cursor(0, { end_row + 1, math.max(end_col - end_col_offset, 0) })
    end

    function Utils.get_node_text(node, bufnr)
      if vim.treesitter and vim.treesitter.get_node_text then
        return vim.treesitter.get_node_text(node, bufnr)
      end
      local srow, scol, erow, ecol = node:range()
      local lines = vim.api.nvim_buf_get_text(bufnr, srow, scol, erow, ecol, {})
      return table.concat(lines, "\n")
    end

    return Utils
  end

  -- Compatibility for `nvim-treesitter.parsers`
  package.preload["nvim-treesitter.parsers"] = function()
    local loader = package.preload["nvim-treesitter.parsers"]
    package.preload["nvim-treesitter.parsers"] = nil

    local ok_real, real = pcall(require, "nvim-treesitter.parsers")
    if not ok_real or type(real) ~= "table" then
      real = {}
    end

    local cfg_ok, cfg = pcall(require, "nvim-treesitter.config")

    local function list_contains(t, v)
      if vim.list_contains then
        return vim.list_contains(t, v)
      end
      for _, x in ipairs(t) do
        if x == v then
          return true
        end
      end
      return false
    end

    local methods = {}
    methods.has_parser = function(lang)
      if not lang or lang == "" then
        return false
      end
      if cfg_ok and cfg.get_installed then
        local ok, installed = pcall(cfg.get_installed, "parsers")
        if ok and type(installed) == "table" and list_contains(installed, lang) then
          return true
        end
      end
      return false
    end

    methods.get_buf_lang = function(bufnr)
      bufnr = bufnr or 0
      local ft = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
      if vim.treesitter and vim.treesitter.language and vim.treesitter.language.get_lang then
        return vim.treesitter.language.get_lang(ft)
      end
      return ft
    end

    local mt = getmetatable(real) or {}
    local old_index = mt.__index
    mt.__index = function(t, k)
      local v = methods[k]
      if v ~= nil then
        return v
      end
      if type(old_index) == "function" then
        return old_index(t, k)
      end
      if type(old_index) == "table" then
        return old_index[k]
      end
      return rawget(t, k)
    end
    setmetatable(real, mt)

    package.loaded["nvim-treesitter.parsers"] = real
    return real
  end

  -- Augment already-loaded parsers module if it exists
  local parsers = package.loaded["nvim-treesitter.parsers"]
  if type(parsers) == "table" then
    local cfg_ok, cfg = pcall(require, "nvim-treesitter.config")
    local function list_contains(t, v)
      if vim.list_contains then
        return vim.list_contains(t, v)
      end
      for _, x in ipairs(t or {}) do
        if x == v then
          return true
        end
      end
      return false
    end

    local methods = {}
    methods.has_parser = function(lang)
      if not lang or lang == "" then
        return false
      end
      if cfg_ok and cfg.get_installed then
        local ok, installed = pcall(cfg.get_installed, "parsers")
        if ok and type(installed) == "table" and list_contains(installed, lang) then
          return true
        end
      end
      return false
    end

    methods.get_buf_lang = function(bufnr)
      bufnr = bufnr or 0
      local ft = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
      if vim.treesitter and vim.treesitter.language and vim.treesitter.language.get_lang then
        return vim.treesitter.language.get_lang(ft)
      end
      return ft
    end

    local mt = getmetatable(parsers) or {}
    local old_index = mt.__index
    mt.__index = function(t, k)
      local v = methods[k]
      if v ~= nil then
        return v
      end
      if type(old_index) == "function" then
        return old_index(t, k)
      end
      if type(old_index) == "table" then
        return old_index[k]
      end
      return rawget(t, k)
    end
    setmetatable(parsers, mt)
  end

  -- Ensure parser install dir is on runtimepath
  local site = vim.fn.stdpath("data") .. "/site"
  local rtp = vim.o.runtimepath or ""
  if not string.find("," .. rtp .. ",", "," .. site .. ",", 1, true) then
    vim.opt.runtimepath:append(site)
  end
end

return M
