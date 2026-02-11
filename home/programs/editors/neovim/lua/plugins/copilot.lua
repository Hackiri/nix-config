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
          accept = false, -- handled by blink.cmp
          next = "<M-]>",
          prev = "<M-[>",
        },
      },
      panel = { enabled = false },
    },
    config = function(_, opts)
      require("copilot").setup(opts)

      -- Coordinate ghost text: hide Copilot suggestions when blink-cmp menu is visible
      vim.api.nvim_create_autocmd("User", {
        pattern = "BlinkCmpMenuOpen",
        callback = function()
          local ok, suggestion = pcall(require, "copilot.suggestion")
          if ok then
            suggestion.dismiss()
          end
          vim.b.copilot_suggestion_hidden = true
        end,
      })
      vim.api.nvim_create_autocmd("User", {
        pattern = "BlinkCmpMenuClose",
        callback = function()
          vim.b.copilot_suggestion_hidden = false
        end,
      })
    end,
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    version = "*",
    enabled = vim.g.neovim_mode ~= "skitty",
    opts = function(_, opts)
      opts = opts or {}
      local user = (vim.env.USER or "User"):gsub("^%l", string.upper)
      opts.question_header = string.format(" %s ", user)
      opts.model = "claude-sonnet-4" -- Use Claude via Copilot for best results
      opts.mappings = {
        close = { normal = "<Esc>", insert = "<Esc>" },
        reset = { normal = "", insert = "" },
      }
      opts.prompts = {
        Explain = { prompt = "/COPILOT_EXPLAIN Write an explanation for the active selection as paragraphs of text." },
        Review = { prompt = "/COPILOT_REVIEW Review the selected code for bugs, performance issues, and improvements." },
        Fix = { prompt = "/COPILOT_GENERATE Fix the problems in the selected code." },
        Refactor = { prompt = "/COPILOT_GENERATE Refactor the selected code for readability and maintainability." },
        Tests = { prompt = "/COPILOT_GENERATE Generate unit tests for the selected code." },
        Docs = { prompt = "/COPILOT_GENERATE Add documentation comments to the selected code." },
      }
      return opts
    end,
    keys = {
      {
        "<M-o>",
        function()
          return require("CopilotChat").toggle()
        end,
        desc = "Toggle (CopilotChat)",
        mode = { "n", "i", "v" },
      },
    },
  },
}
