local M = {}

M.setup = function()
  -- Create augroups
  local function augroup(name)
    return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
  end

  -- IndentBlankline augroup and autocommands
  local ibl_group = vim.api.nvim_create_augroup("IndentBlankline", {})
  local ibl = require("ibl")
  local highlights = require("ibl.highlights")
  local buffer_leftcol = {}

  vim.api.nvim_create_autocmd("VimEnter", {
    group = ibl_group,
    pattern = "*",
    callback = ibl.refresh_all,
  })

  vim.api.nvim_create_autocmd({
    "CursorMoved",
    "CursorMovedI",
    "BufWinEnter",
    "CompleteChanged",
    "FileChangedShellPost",
    "FileType",
    "TextChanged",
    "TextChangedI",
  }, {
    group = ibl_group,
    pattern = "*",
    callback = function(opts)
      -- Skip expensive IBL refresh on cursor move for TSX/JSX files to prevent lag
      local ft = vim.bo[opts.buf].filetype
      if ft == "tsx" or ft == "jsx" or ft == "typescriptreact" or ft == "javascriptreact" then
        -- Only refresh on text changes, not cursor movement
        if opts.event == "TextChanged" or opts.event == "TextChangedI" or opts.event == "BufWinEnter" then
          ibl.debounced_refresh(opts.buf)
        end
      else
        ibl.debounced_refresh(opts.buf)
      end
    end,
  })

  vim.api.nvim_create_autocmd("OptionSet", {
    group = ibl_group,
    pattern = "list,listchars,shiftwidth,tabstop,vartabstop,breakindent,breakindentopt",
    callback = function(opts)
      ibl.debounced_refresh(opts.buf)
    end,
  })

  vim.api.nvim_create_autocmd("WinScrolled", {
    group = ibl_group,
    pattern = "*",
    callback = function(opts)
      local win_view = vim.fn.winsaveview() or { leftcol = 0 }
      if buffer_leftcol[opts.buf] ~= win_view.leftcol then
        buffer_leftcol[opts.buf] = win_view.leftcol
        -- Refresh immediately for horizontal scrolling
        ibl.refresh(opts.buf)
      else
        ibl.debounced_refresh(opts.buf)
      end
    end,
  })

  vim.api.nvim_create_autocmd("ColorScheme", {
    group = ibl_group,
    pattern = "*",
    callback = function()
      highlights.setup()
      ibl.refresh_all()
    end,
  })

  -- LazyVim augroups and autocommands
  vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = augroup("checktime"),
    command = "checktime",
  })

  -- Consolidated TextYankPost: highlight, sticky cursor, cyclic paste
  vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Yank utilities: highlight, sticky cursor, cyclic paste",
    group = augroup("yank_utilities"),
    callback = function()
      -- Highlight yanked text
      vim.highlight.on_yank()

      -- Sticky yank: return cursor to position (from v12 config)
      if vim.v.event.operator == "y" and vim.v.event.regname == "" and vim.b.cursorPreYank then
        vim.api.nvim_win_set_cursor(0, vim.b.cursorPreYank)
        vim.b.cursorPreYank = nil
      end

      -- Cyclic paste: store yanks in register 1 (from v12 config)
      if vim.v.event.operator == "y" and vim.v.event.regname == "" then
        vim.fn.setreg("1", vim.fn.getreg("0"))
      end
    end,
  })

  vim.api.nvim_create_autocmd({ "VimResized" }, {
    group = augroup("resize_splits"),
    callback = function()
      local current_tab = vim.fn.tabpagenr()
      vim.cmd("tabdo wincmd =")
      vim.cmd("tabnext " .. current_tab)
    end,
  })

  vim.api.nvim_create_autocmd("BufReadPost", {
    group = augroup("last_loc"),
    callback = function(event)
      local exclude = { "gitcommit" }
      local buf = event.buf
      if vim.tbl_contains(exclude, vim.bo[buf].filetype) then
        return
      end
      local mark = vim.api.nvim_buf_get_mark(buf, '"')
      local lcount = vim.api.nvim_buf_line_count(buf)
      if mark[1] > 0 and mark[1] <= lcount then
        pcall(vim.api.nvim_win_set_cursor, 0, mark)
      end
    end,
  })

  -- Close special filetypes with <esc> (more intuitive than q)
  vim.api.nvim_create_autocmd("FileType", {
    group = augroup("close_with_q"),
    pattern = {
      "PlenaryTestPopup",
      "grug-far",
      "help",
      "lspinfo",
      "man",
      "notify",
      "qf",
      "spectre_panel",
      "startuptime",
      "tsplayground",
      "neotest-output",
      "checkhealth",
      "neotest-summary",
      "neotest-output-panel",
      "dbout",
      "gitsigns-blame",
      "Lazy",
    },
    callback = function(event)
      vim.bo[event.buf].buflisted = false
      vim.schedule(function()
        vim.keymap.set("n", "<esc>", function()
          vim.cmd("close")
          pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
        end, {
          buffer = event.buf,
          silent = true,
          desc = "Quit buffer",
        })
      end)
    end,
  })

  -- Wrap and spell check for text filetypes
  vim.api.nvim_create_autocmd("FileType", {
    group = augroup("wrap_spell"),
    pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
    callback = function()
      vim.opt_local.wrap = true
      vim.opt_local.spell = true
    end,
  })

  -- User event that loads after UIEnter + only if file buf is there
  vim.api.nvim_create_autocmd({ "UIEnter", "BufReadPost", "BufNewFile" }, {
    group = vim.api.nvim_create_augroup("FilePost", { clear = true }),
    callback = function(args)
      local file = vim.api.nvim_buf_get_name(args.buf)
      local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })

      if not vim.g.ui_entered and args.event == "UIEnter" then
        vim.g.ui_entered = true
      end

      if file ~= "" and buftype ~= "nofile" and vim.g.ui_entered then
        vim.api.nvim_exec_autocmds("User", { pattern = "FilePost", modeline = false })
        vim.api.nvim_del_augroup_by_name("FilePost")

        vim.schedule(function()
          -- Force filetype detection for files opened from explorers
          if vim.bo[args.buf].filetype == "" then
            vim.api.nvim_buf_call(args.buf, function()
              vim.cmd("filetype detect")
            end)
          end

          vim.api.nvim_exec_autocmds("FileType", {})

          if vim.g.editorconfig then
            require("editorconfig").config(args.buf)
          end
        end)
      end
    end,
  })

  -- Additional autocmd to ensure filetype detection for explorer-opened files
  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    group = vim.api.nvim_create_augroup("EnsureFiletypeDetection", { clear = true }),
    callback = function(args)
      -- If filetype is empty, force detection
      vim.schedule(function()
        local buf = args.buf
        if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == "" then
          local filename = vim.api.nvim_buf_get_name(buf)
          if filename ~= "" and vim.fn.filereadable(filename) == 1 then
            vim.api.nvim_buf_call(buf, function()
              vim.cmd("filetype detect")
            end)
          end
        end
      end)
    end,
    desc = "Ensure filetype detection for explorer-opened files",
  })

  -- LazyFile event for lazy loading plugins when opening files
  -- This mimics LazyVim's LazyFile event
  vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "BufWritePre" }, {
    group = augroup("lazy_file"),
    callback = function(event)
      -- Trigger LazyFile event for actual files (not special buffers)
      local file = vim.api.nvim_buf_get_name(event.buf)
      local buftype = vim.api.nvim_get_option_value("buftype", { buf = event.buf })

      if file ~= "" and buftype == "" then
        vim.api.nvim_exec_autocmds("User", { pattern = "LazyFile", modeline = false })
        -- Remove the autocmd after first trigger to avoid duplicate events
        vim.api.nvim_del_augroup_by_name("lazyvim_lazy_file")
      end
    end,
  })

  -- Specific autocmd for markdown files to ensure tree-sitter highlighting
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
    group = augroup("markdown_treesitter"),
    pattern = "*.md",
    callback = function(ev)
      -- Force start tree-sitter highlighting for markdown files
      pcall(function()
        vim.treesitter.start(ev.buf, "markdown")
      end)
    end,
  })

  -- Auto-fold markdown headings when opening markdown files
  vim.api.nvim_create_autocmd("BufRead", {
    group = augroup("markdown_fold"),
    pattern = "*.md",
    callback = function()
      -- Avoid running multiple times for the same buffer
      if vim.b.zk_executed then
        return
      end
      vim.b.zk_executed = true
      -- Use vim.defer_fn to add a slight delay before executing zk
      vim.defer_fn(function()
        vim.cmd("normal zk")
        vim.notify("Folded markdown headings", vim.log.levels.INFO)
      end, 100) -- Delay in milliseconds
    end,
  })

  -- Clear jump list when Neovim starts (prevents stale jumps from previous sessions)
  vim.api.nvim_create_autocmd("BufWinEnter", {
    group = augroup("clear_jumps"),
    once = true,
    callback = function()
      vim.schedule(function()
        vim.cmd("clearjumps")
      end)
    end,
  })

  -- Auto-nohl with inline search count (from v12 config)
  -- Automatically clears search highlight and shows inline search count
  local function searchCountIndicator(mode)
    local signColumnPlusScrollbarWidth = 2 + 3

    local countNs = vim.api.nvim_create_namespace("searchCounter")
    vim.api.nvim_buf_clear_namespace(0, countNs, 0, -1)
    if mode == "clear" then
      return
    end

    local row = vim.api.nvim_win_get_cursor(0)[1]
    local count = vim.fn.searchcount()
    if vim.tbl_isempty(count) or count.total == 0 then
      return
    end

    local text = (" %d/%d "):format(count.current, count.total)
    local line = vim.api.nvim_get_current_line():gsub("\t", (" "):rep(vim.bo.shiftwidth))
    local lineFull = #line + signColumnPlusScrollbarWidth >= vim.api.nvim_win_get_width(0)
    local margin = { (" "):rep(lineFull and signColumnPlusScrollbarWidth or 0) }

    vim.api.nvim_buf_set_extmark(0, countNs, row - 1, 0, {
      virt_text = { { text, "IncSearch" }, margin },
      virt_text_pos = lineFull and "right_align" or "eol",
      priority = 200,
    })
  end

  -- Auto-nohl and search count indicator
  vim.on_key(function(key, _typed)
    key = vim.fn.keytrans(key)
    local isCmdlineSearch = vim.fn.getcmdtype():find("[/?]") ~= nil
    local isNormalMode = vim.api.nvim_get_mode().mode == "n"
    local searchStarted = (key == "/" or key == "?") and isNormalMode
    local searchConfirmed = (key == "<CR>" and isCmdlineSearch)
    local searchCancelled = (key == "<Esc>" and isCmdlineSearch)
    if not (searchStarted or searchConfirmed or searchCancelled or isNormalMode) then
      return
    end

    local searchMovement = vim.tbl_contains({ "n", "N", "*", "#" }, key)

    if searchCancelled or (not searchMovement and not searchConfirmed) then
      vim.opt.hlsearch = false
      searchCountIndicator("clear")
    elseif searchMovement or searchConfirmed or searchStarted then
      vim.opt.hlsearch = true
      vim.defer_fn(searchCountIndicator, 1)
    end
  end, vim.api.nvim_create_namespace("autoNohlAndSearchCount"))

  -- Lucky indent (from v12 config)
  -- Auto-detect and set indent based on first indented line
  local function luckyIndent(bufnr)
    local linesToCheck = 50
    if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].buftype ~= "" then
      return
    end

    -- Don't apply if .editorconfig is in effect
    local ec = vim.b[bufnr].editorconfig
    if ec and (ec.indent_style or ec.indent_size or ec.tab_width) then
      return
    end

    -- Guess indent from first indented line
    local indent
    local maxToCheck = math.min(linesToCheck, vim.api.nvim_buf_line_count(bufnr))
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, maxToCheck, false)
    for lnum = 1, #lines do
      indent = lines[lnum]:match("^%s*")
      if #indent > 0 then
        break
      end
    end

    if not indent or #indent == 0 then
      return
    end

    local spaces = indent:match(" +")
    if vim.bo[bufnr].ft == "markdown" then
      if not spaces then
        return
      end
      if #spaces == 2 then
        return
      end -- 2 space indents from hardwrap, not real indent
    end

    -- Apply if needed
    local opts = { title = "Lucky indent", icon = "󰉶" }
    if spaces and not vim.bo.expandtab then
      vim.bo[bufnr].expandtab = true
      vim.bo[bufnr].shiftwidth = #spaces
      vim.notify_once(("Set indentation to %d spaces."):format(#spaces), nil, opts)
    elseif not spaces and vim.bo.expandtab then
      vim.bo[bufnr].expandtab = false
      vim.notify_once("Set indentation to tabs.", nil, opts)
    end
  end

  vim.api.nvim_create_autocmd("BufReadPost", {
    group = augroup("lucky_indent"),
    desc = "Auto-detect indent from first indented line",
    callback = function(ctx)
      vim.defer_fn(function()
        luckyIndent(ctx.buf)
      end, 100)
    end,
  })

  -- Favicon prefixes for URLs (from v12 config)
  -- Adds icons before URLs in comments
  local favicons = {
    apple = "",
    github = "",
    google = "",
    microsoft = "",
    neovim = "",
    openai = "",
    reddit = "",
    stackoverflow = "󰓌",
    ycombinator = "",
    youtube = "",
  }

  local function addFavicons(bufnr)
    if not bufnr then
      bufnr = 0
    end
    if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].buftype ~= "" then
      return
    end

    local hasCommentParser, urlQuery = pcall(vim.treesitter.query.parse, "comment", "(uri) @string.special.url")
    if not hasCommentParser then
      return
    end

    local hasParserForFt, _ = pcall(vim.treesitter.get_parser, bufnr)
    if not hasParserForFt then
      return
    end

    local ns = vim.api.nvim_create_namespace("url-favicons")
    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

    local langTree = vim.treesitter.get_parser(bufnr)
    if not langTree then
      return
    end

    langTree:for_each_tree(function(tree, _)
      if not urlQuery.iter_captures then
        return
      end
      local commentUrlNodes = urlQuery:iter_captures(tree:root(), bufnr)
      vim.iter(commentUrlNodes):each(function(_, node)
        local nodeText = vim.treesitter.get_node_text(node, bufnr)
        local sitename = nodeText:match("(%w+)%.com") or nodeText:match("(%w+)%.io")
        local icon = favicons[sitename]
        if not icon then
          return
        end

        local row, col = node:start()
        vim.api.nvim_buf_set_extmark(bufnr, ns, row, col, {
          virt_text = { { icon .. " ", "Comment" } },
          virt_text_pos = "inline",
        })
      end)
    end)
  end

  vim.api.nvim_create_autocmd({ "FocusGained", "BufReadPost", "TextChanged", "InsertLeave" }, {
    group = augroup("url_favicons"),
    desc = "Add favicons to URLs in comments",
    callback = function(ctx)
      local delay = ctx.event == "BufReadPost" and 300 or 0
      vim.defer_fn(function()
        addFavicons(ctx.buf)
      end, delay)
    end,
  })
end

return M
