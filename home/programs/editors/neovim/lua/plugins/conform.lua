--
-- https://github.com/stevearc/conform.nvim

-- Auto-format when focus is lost or I leave the buffer
-- Useful if on skitty-notes or a regular buffer and switch somewhere else the
-- formatting doesn't stay all messed up
-- I found this autocmd example in the readme
-- https://github.com/stevearc/conform.nvim/blob/master/README.md#setup
-- "FocusLost" used when switching from skitty-notes
-- "BufLeave" is used when switching between 2 buffers
-- Defer autocmd creation until after LazyVim is loaded
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = function()
    -- Auto-format when focus is lost or I leave the buffer
    vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave" }, {
      pattern = "*",
      callback = function(args)
        local buf = args.buf or vim.api.nvim_get_current_buf()

        -- Skip formatting if buffer is not valid or is being loaded
        if not vim.api.nvim_buf_is_valid(buf) then
          return
        end

        -- Skip if buffer is not loaded (prevents interfering with file loading)
        if not vim.api.nvim_buf_is_loaded(buf) then
          return
        end

        -- Only format if the current mode is normal mode
        if vim.fn.mode() ~= "n" then
          return
        end

        -- Check if LazyVim is available and autoformat is enabled
        local lazyvim_ok = pcall(require, "lazyvim.util")
        if lazyvim_ok and LazyVim and LazyVim.format and not LazyVim.format.enabled(buf) then
          return
        end

        -- Add a delay to prevent interfering with file loading
        vim.defer_fn(function()
          if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
            require("conform").format({ bufnr = buf, quiet = true })
          end
        end, 100)
      end,
    })
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
      -- Use system-installed prettier from Nix
      prettier = {
        -- Let conform find prettier in PATH (installed via Nix)
        command = "prettier",
        condition = function()
          return vim.fn.executable("prettier") == 1
        end,
      },
      -- Use system-installed shfmt from Nix
      shfmt = {
        command = "shfmt",
        condition = function()
          return vim.fn.executable("shfmt") == 1
        end,
      },
    },
    -- Disable formatters that are showing warnings
    formatters_by_ft = {
      -- Disabled templ formatter (not installed via Nix)
      -- Uncomment the line below if you install templ via Nix
      -- templ = { "templ" },
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

      -- Shell script formatting
      sh = { "shfmt" },
      bash = { "shfmt" },
      zsh = { "shfmt" },

      -- Explicitly disable fish_indent since it's not installed
      fish = {},
    },

    -- LazyVim will handle format_on_save automatically

    -- Don't show errors in the notification window
    notify_on_error = false,
  },
}
