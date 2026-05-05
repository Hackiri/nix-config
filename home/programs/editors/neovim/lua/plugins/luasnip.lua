-- plugin: LuaSnip | https://github.com/L3MON4D3/LuaSnip
return {
  "L3MON4D3/LuaSnip",
  version = "v2.*",
  -- jsregexp is provided via Nix extraLuaPackages in default.nix
  -- This is required for LSP snippet transformations
  event = "InsertEnter",
  dependencies = {
    "rafamadriz/friendly-snippets",
  },
  enabled = true,
  opts = {
    history = true,
    update_events = "TextChanged,TextChangedI",
    delete_check_events = "TextChanged",
    enable_autosnippets = true,
    store_selection_keys = "<Tab>",
    region_check_events = "InsertEnter",
  },
  config = function(_, opts)
    local ls = require("luasnip")
    ls.setup(opts)
    require("snippets").setup()
  end,
}
