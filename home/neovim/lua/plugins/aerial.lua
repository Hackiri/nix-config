return {
  "stevearc/aerial.nvim",
  lazy_load = true,
  keys = {
    { "<leader>o", "<cmd>AerialToggle!<CR>", desc = "Toggle outline" },
    { "<leader>os", "<cmd>AerialNavToggle<CR>", desc = "Toggle outline sidebar" },
    { "[s", "<cmd>AerialPrev<CR>", desc = "Previous symbol" },
    { "]s", "<cmd>AerialNext<CR>", desc = "Next symbol" },
  },
  opts = {},
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("aerial").setup({
      layout = {
        min_width = 30,
      },
    })
  end,
}
