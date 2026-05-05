-- lua/config/init.lua
-- This file is loaded by the root init.lua after lazy.nvim is set up

-- Load core configurations
require("config.options")
require("config.clipboard").setup()
require("config.keymaps")
require("config.formatting").setup()
require("config.autocmds")
require("config.colors")

-- Load custom highlights
require("config.highlights")

-- Load folding (with error handling)
vim.schedule(function()
  pcall(require, "config.folding")
end)
