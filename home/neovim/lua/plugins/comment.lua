-- Easily comment visual regions/lines
return {
  "numToStr/Comment.nvim",
  event = { "BufReadPost", "BufNewFile" },
  opts = {},
  config = function()
    local api = require("Comment.api")
    vim.keymap.set("n", "<leader>/", api.toggle.linewise.current, { desc = "Toggle comment line" })
    vim.keymap.set(
      "v",
      "<leader>/",
      "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
      { desc = "Toggle comment selection" }
    )
    vim.keymap.set("n", "<leader>?", api.toggle.blockwise.current, { desc = "Toggle comment block" })
    vim.keymap.set(
      "v",
      "<leader>?",
      "<ESC><cmd>lua require('Comment.api').toggle.blockwise(vim.fn.visualmode())<CR>",
      { desc = "Toggle comment block" }
    )
  end,
}
