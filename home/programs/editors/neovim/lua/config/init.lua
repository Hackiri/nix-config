-- lua/config/init.lua
-- This file is loaded by the root init.lua after lazy.nvim is set up

-- Load core configurations
require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.colors")

-- Load LuaSnip configuration
local status_ok, _ = pcall(require, "luasnip")
if status_ok then
  require("config.luasnip_config")
end

-- Load custom highlights
require("config.highlights")

-- Load folding (with error handling)
vim.schedule(function()
  pcall(require, "config.folding")
end)
