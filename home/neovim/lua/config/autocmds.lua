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

  -- Set the TMUX title to the file name of current buffer
  -- This requires the following tmux settings:
  --   set -g allow-rename on
  --   set -g automatic-rename off
  vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter', 'BufFilePost', 'BufWritePost' }, {
    group = augroup("tmux_title"),
    callback = function()
      local filename = vim.fn.expand('%:t') -- get filename only (no path)
      if filename == '' then
        return
      end
      -- truncate to 15 characters
      local shortname = #filename > 15 and filename:sub(1, 15) .. '…' or filename
      -- Update tmux window name
      io.write('\027kVI:' .. shortname .. '\027\\')
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
          vim.api.nvim_exec_autocmds("FileType", {})

          if vim.g.editorconfig then
            require("editorconfig").config(args.buf)
          end
        end)
      end
    end,
  })
end

return M
