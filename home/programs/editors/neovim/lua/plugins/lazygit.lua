return {
  -- Override LazyVim default keymaps to prevent conflicts with LSP operations
  {
    "folke/lazy.nvim",
    keys = {
      -- Disable default <leader>l keymap to prevent conflict with LSP operations
      { "<leader>l", false },
      -- Remap Lazy plugin manager to uppercase L
      { "<leader>L", "<cmd>Lazy<cr>", desc = "Lazy Plugin Manager" },
    },
  },
  -- lazygit.nvim removed: consolidated under Snacks.lazygit()
}
