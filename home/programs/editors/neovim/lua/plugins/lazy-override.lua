-- Override LazyVim default keymaps to prevent conflicts
-- https://github.com/folke/lazy.nvim

return {
  "folke/lazy.nvim",
  keys = {
    -- Disable default <leader>l keymap to prevent conflict with LSP operations
    { "<leader>l", false },
    -- Remap Lazy plugin manager to uppercase L
    { "<leader>L", "<cmd>Lazy<cr>", desc = "Lazy Plugin Manager" },
  },
}
