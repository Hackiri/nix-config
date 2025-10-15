-- ~/.config/nvim/lua/plugins/windsurf.lua
-- Windsurf/Codeium AI code completion
return {
  "Exafunction/codeium.nvim",
  event = "InsertEnter",
  config = function()
    require("codeium").setup({
      enable_cmp_source = true, -- Enable for blink.compat integration
      virtual_text = {
        enabled = true,
        manual = false,
      },
    })
  end,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "saghen/blink.compat",
  },
}
