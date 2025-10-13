-- Standalone plugins with less than 10 lines of config go here
return {
  {
    -- detect tabstop and shiftwidth automatically
    "tpope/vim-sleuth",
  },
  {
    -- Powerful Git integration for Vim
    "tpope/vim-fugitive",
  },
  {
    -- GitHub integration for vim-fugitive
    "tpope/vim-rhubarb",
  },
  {
    -- Bind9 DNS syntax highlighting
    "egberts/vim-syntax-bind-named",
  },
  {
    -- Highlight todo, notes, etc in comments
    "folke/todo-comments.nvim",
    event = "VimEnter",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = false },
  },
  -- {
  --   -- high-performance color highlighter
  --   "norcalli/nvim-colorizer.lua",
  --   config = function()
  --     require("colorizer").setup()
  --   end,
  -- },
  -- Notification manager (nvim-notify) replaced by Snacks.notifier in LazyVim 14.x+
  -- Snacks.notifier is configured in plugins/snacks.lua
  -- {
  --   "rcarriga/nvim-notify",
  --   config = function()
  --     require("notify").setup({
  --       timeout = 5000,
  --     })
  --     vim.notify = require("notify")
  --   end,
  -- },
}
