return {
  "folke/which-key.nvim",
  version = "*",
  event = "VeryLazy", -- Load after UI is rendered
  config = function()
    require("which-key").setup({
      -- I want which key to only popup if I don't remember the key
      delay = 1500,
    })
  end,
}
