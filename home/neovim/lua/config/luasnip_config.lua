local status_ok, luasnip = pcall(require, "luasnip")
if not status_ok then
  return
end

-- Configure LuaSnip
luasnip.setup({
  history = true,
  update_events = "TextChanged,TextChangedI",
  enable_autosnippets = true,
  store_selection_keys = "<Tab>",
  -- Enable jsregexp for variable/placeholder transformations
  region_check_events = "InsertEnter",
  delete_check_events = "TextChanged",
})

-- Load friendly-snippets
pcall(function()
  require("luasnip.loaders.from_vscode").lazy_load()
end)
