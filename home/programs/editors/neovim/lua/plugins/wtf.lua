-- wtf.nvim: AI-powered diagnostic explanations
-- One keypress to explain the diagnostic under cursor with AI
-- https://github.com/piersolenski/wtf.nvim
return {
  "piersolenski/wtf.nvim",
  dependencies = { "MunifTanjim/nui.nvim" },
  event = "VeryLazy",
  opts = {
    popup_type = "popup", -- "popup" or "horizontal" or "vertical"
    default_ai = "copilot", -- Uses existing Copilot subscription
  },
  keys = {
    {
      "<leader>de",
      function()
        require("wtf").ai()
      end,
      desc = "AI Explain Diagnostic",
    },
    {
      "<leader>dW",
      function()
        require("wtf").search()
      end,
      desc = "Web Search Diagnostic",
    },
  },
}
