return {
  {
    "zbirenbaum/copilot.lua",
    version = "*",
    event = "InsertEnter", -- Load when entering insert mode
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        hide_during_completion = true,
        keymap = {
          accept = false, -- handled by nvim-cmp / blink.cmp
          next = "<M-]>",
          prev = "<M-[>",
        },
      },
      panel = { enabled = false },
    },
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    version = "*",
    enabled = vim.g.neovim_mode ~= "skitty",
    opts = function(_, opts)
      opts = opts or {}
      local user = (vim.env.USER or "User"):gsub("^%l", string.upper)
      opts.question_header = string.format(" %s ", user)
      opts.mappings = {
        close = { normal = "<Esc>", insert = "<Esc>" },
        reset = { normal = "", insert = "" },
      }
      return opts
    end,
    keys = {
      {
        "<M-o>",
        function()
          return require("CopilotChat").toggle()
        end,
        desc = "[P]Toggle (CopilotChat)",
        mode = { "n", "i", "v" },
      },
    },
  },
}
