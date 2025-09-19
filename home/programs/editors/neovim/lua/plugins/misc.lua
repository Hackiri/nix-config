-- Standalone plugins with less than 10 lines of config go here
return {
  {
    -- autoclose tags
    "windwp/nvim-ts-autotag",
  },
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
    -- Autoclose parentheses, brackets, quotes, etc.
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
    opts = {},
  },
  {
    "mireq/luasnip-snippets",
    dependencies = { "L3MON4D3/LuaSnip" },
    init = function()
      -- Mandatory setup function
      require("luasnip_snippets.common.snip_utils").setup()
    end,
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
  {
    -- Notification manager
    "rcarriga/nvim-notify",
    config = function()
      require("notify").setup({
        timeout = 5000,
      })
      vim.notify = require("notify")
    end,
  },
}
