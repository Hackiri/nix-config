return {
  {
    "zbirenbaum/copilot.lua",
    version = "*",
    event = "InsertEnter", -- Load when entering insert mode
    opts = {
      suggestion = {
        enabled = false,
        auto_trigger = true,
        hide_during_completion = vim.g.ai_cmp,
        keymap = {
          accept = false, -- handled by nvim-cmp / blink.cmp
          next = "<M-]>",
          prev = "<M-[>",
        },
      },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        help = true,
        -- html = true,
        -- css = true,
        -- javascript = true,
        -- typescript = true,
        -- javascriptreact = true,
        -- typescriptreact = true,
        -- json = true,
        -- yaml = true,
        -- markdown = true,
        -- help = true,
      },
    },
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    version = "*",
    enabled = vim.g.neovim_mode ~= "skitty",
    opts = function(_, opts)
      opts = opts or {}
      opts.model = _G.COPILOT_MODEL
      local user = (vim.env.USER or "User"):gsub("^%l", string.upper)
      opts.question_header = string.format(" %s (%s) ", user, opts.model)
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
