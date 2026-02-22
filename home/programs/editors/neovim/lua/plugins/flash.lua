-- flash.nvim is included via LazyVim core
-- This file adds treesitter-based selection keymaps
return {
  "folke/flash.nvim",
  keys = {
    {
      "S",
      mode = { "n", "o", "x" },
      function()
        require("flash").treesitter()
      end,
      desc = "Flash Treesitter",
    },
    {
      "R",
      mode = { "o", "x" },
      function()
        require("flash").treesitter_search()
      end,
      desc = "Treesitter Search",
    },
  },
}
