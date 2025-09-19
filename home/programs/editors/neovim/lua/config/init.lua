-- lua/config/init.lua

-- Load lazy.nvim configuration first
require("config.lazy")

-- Load core configurations
require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.colors")
-- require("config.session")

-- Load LuaSnip first
local status_ok, luasnip = pcall(require, "luasnip")
if status_ok then
  require("config.luasnip_config")
end

-- Load custom highlights
require("config.highlights")

-- Load folding (with error handling)
vim.schedule(function()
  require("config.folding")
end)
