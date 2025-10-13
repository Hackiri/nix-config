-- Main init.lua - Entry point for Neovim configuration

-- Bootstrap and setup lazy.nvim (handles leader keys, plugin loading, etc.)
require("config.lazy")

-- Load remaining configuration after plugins are loaded
require("config.init")
