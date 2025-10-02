--
-- https://github.com/stevearc/conform.nvim

-- Auto-format when focus is lost or I leave the buffer
-- Useful if on skitty-notes or a regular buffer and switch somewhere else the
-- formatting doesn't stay all messed up
-- I found this autocmd example in the readme
-- https://github.com/stevearc/conform.nvim/blob/master/README.md#setup
-- "FocusLost" used when switching from skitty-notes
-- "BufLeave" is used when switching between 2 buffers
vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave" }, {
  pattern = "*",
  callback = function(args)
    local buf = args.buf or vim.api.nvim_get_current_buf()
    -- Only format if the current mode is normal mode
    -- Only format if autoformat is enabled for the current buffer (if
    -- autoformat disabled globally the buffers inherits it, see :LazyFormatInfo)
    if LazyVim.format.enabled(buf) and vim.fn.mode() == "n" then
      -- Add a small delay to the formatting so it doesn't interfere with
      -- CopilotChat's or grug-far buffer initialization, this helps me to not
      -- get errors when using the "BufLeave" event above, if not using
      -- "BufLeave" the delay is not needed
      vim.defer_fn(function()
        if vim.api.nvim_buf_is_valid(buf) then
          require("conform").format({ bufnr = buf })
        end
      end, 100)
    end
  end,
})

return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    -- Removed <leader>f to prevent conflict with find/file prefix
    -- Use <leader>lf instead (defined in config/keymaps.lua)
  },
  opts = {
    -- Define formatters
    formatters = {
      -- Override prettier to use the Mason-installed version
      prettier = {
        -- Use the version installed by Mason
        command = vim.fn.stdpath("data") .. "/mason/bin/prettier",
        -- Add condition to check if the command exists and is executable
        condition = function()
          local cmd = vim.fn.stdpath("data") .. "/mason/bin/prettier"
          return vim.fn.executable(cmd) == 1
        end,
      },
    },
    -- Disable formatters that are showing warnings
    formatters_by_ft = {
      -- I was having issues formatting .templ files, all the lines were aligned
      -- to the left.
      -- When I ran :ConformInfo I noticed that 2 formatters showed up:
      -- "LSP: html, templ"
      -- But none showed as `ready` This fixed that issue and now templ files
      -- are formatted correctly and :ConformInfo shows:
      -- "LSP: html, templ"
      -- "templ ready (templ) /Users/wm/.local/share/nvim/mason/bin/templ"
      templ = { "templ" },
      -- Not sure why I couldn't make ruff work, so I'll use ruff_format instead
      -- it didn't work even if I added the pyproject.toml in the project or
      -- root of my dots, I was getting the error [LSP][ruff] timeout
      python = { "ruff_format" },
      -- php = { nil },

      -- Add JavaScript/TypeScript formatting with prettier
      javascript = { "prettier" },
      typescript = { "prettier" },
      javascriptreact = { "prettier" },
      typescriptreact = { "prettier" },
      css = { "prettier" },
      html = { "prettier" },
      json = { "prettier" },
      yaml = { "prettier" },
      markdown = { "prettier" },

      -- Use stylua for Lua files
      lua = { "stylua" },

      -- Explicitly disable fish_indent since it's not installed
      fish = {},
    },

    -- LazyVim will handle format_on_save automatically

    -- Don't show errors in the notification window
    notify_on_error = false,
  },
}
