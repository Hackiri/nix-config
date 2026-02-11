return {
  "folke/which-key.nvim",
  version = "*",
  event = "VeryLazy", -- Load after UI is rendered
  config = function()
    require("which-key").setup({
      -- I want which key to only popup if I don't remember the key
      delay = 1500,
    })
    -- Register group labels for AI and tool prefixes
    require("which-key").add({
      { "<leader>c", group = "Claude Code" },
      { "<leader>l", group = "LSP" },
      { "<leader>lm", group = "Mason Tools" },
    })
  end,
}
