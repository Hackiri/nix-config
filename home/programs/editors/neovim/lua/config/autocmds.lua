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
      ibl.debounced_refresh(opts.buf)
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

  vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = augroup("highlight_yank"),
    callback = function()
      vim.highlight.on_yank()
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

  vim.api.nvim_create_autocmd("FileType", {
    group = augroup("close_with_q"),
    pattern = {
      "PlenaryTestPopup",
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
    },
    callback = function(event)
      vim.bo[event.buf].buflisted = false
      vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
    end,
  })

  vim.api.nvim_create_autocmd("FileType", {
    group = augroup("wrap_spell"),
    pattern = { "gitcommit", "markdown" },
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

  -- Fallback: Ensure Tree-sitter highlighting starts on filetype (Neovim 0.11+)
  -- NOTE: Primary treesitter autocmds are in plugins/treesitter.lua (init function)
  -- This is a fallback for filetypes not explicitly listed
  vim.api.nvim_create_autocmd("FileType", {
    group = augroup("treesitter_start"),
    callback = function(ev)
      -- Start only if not already active; ignore failures
      pcall(function()
        if not vim.treesitter.highlighter.active[ev.buf] then
          vim.treesitter.start(ev.buf)
        end
      end)
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
end

return M
