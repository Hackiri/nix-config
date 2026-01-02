-- claudecode.nvim: Claude Code CLI integration for Neovim
-- https://github.com/coder/claudecode.nvim
return {
  "coder/claudecode.nvim",
  dependencies = {
    "folke/snacks.nvim", -- Required for terminal support
  },
  event = "VeryLazy",
  opts = {
    -- Server configuration
    auto_start = true,
    log_level = "info",

    -- Terminal configuration
    terminal = {
      split_side = "right",
      split_width_percentage = 0.4,
      provider = "snacks", -- Use snacks.nvim for floating terminals
    },

    -- Diff configuration
    diff_opts = {
      layout = "vertical",
    },

    -- Behavior
    track_selection = true,
  },
  keys = {
    -- Core commands (<leader>A for Claude Code to avoid conflicts with alt-file nav)
    { "<leader>Ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude Code" },
    { "<leader>Af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude Code" },
    { "<leader>Ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
    { "<leader>AC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
    { "<leader>Am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Model" },

    -- Context sending
    { "<leader>Ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add Buffer to Claude" },
    { "<leader>As", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send Selection to Claude" },

    -- Diff management
    { "<leader>Ay", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept Diff (yes)" },
    { "<leader>An", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny Diff (no)" },
  },
}
