return {
  "L3MON4D3/LuaSnip",
  version = "v2.*",
  -- jsregexp is provided via Nix extraLuaPackages in default.nix
  -- This is required for LSP snippet transformations
  dependencies = {
    "rafamadriz/friendly-snippets",
  },
  enabled = true,
  lazy = true,
  config = function()
    local ls = require("luasnip")

    -- Configure snippet options
    ls.config.set_config({
      history = true,
      updateevents = "TextChanged,TextChangedI",
      delete_check_events = "TextChanged",
      enable_autosnippets = true,
    })

    -- Load modular snippets
    -- Snippets are now organized in lua/snippets/ directory for better maintainability
    -- This improves startup time by reducing the size of this file
    require("snippets").load_snippets()

    vim.notify("LuaSnip snippets loaded from modular files", vim.log.levels.INFO)
  end,
}
