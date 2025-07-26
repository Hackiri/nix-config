return {
  "Hackiri/cccli",
  event = "VeryLazy",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    require("cccli").setup({
      -- Claude Code integration
      claude = {
        api_key = nil, -- Will use ANTHROPIC_API_KEY env var
        model = "claude-3-5-sonnet-20241022",
        streaming = true,
      },
      -- UI configuration
      ui = {
        sidebar = {
          width = 40,
          position = "right", -- "left" or "right"
          auto_open = false,
        },
        suggestions = {
          enabled = true,
          ghost_text = true,
        },
      },
      -- Keybindings
      keymaps = {
        toggle_sidebar = "<leader>cc",
        ask_claude = "<leader>ca",
        edit_selection = "<leader>ce",
        explain_code = "<leader>cx",
      },
    })
  end,
}
