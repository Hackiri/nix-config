# Treesitter Main Branch - Verified Information

## Official Source
https://github.com/nvim-treesitter/nvim-treesitter/blob/main/README.md

## ✅ Verified Commands (Main Branch)

### Commands THAT EXIST:
- `:TSInstall {language}` - Install parsers
- `:TSInstallSync {language}` - Synchronous install
- `:TSInstallInfo` - List installed parsers
- `:TSUpdate {language}` - Update parsers
- `:TSUpdateSync {language}` - Synchronous update
- `:TSUninstall {language}` - Remove parsers

### Commands from Master Branch (May Not Exist on Main):
- `:TSBufEnable` - Module commands may not exist
- `:TSModuleInfo` - Module system removed on main

## ✅ Verified API (Main Branch)

### CORRECT:
```lua
require('nvim-treesitter').setup {
  install_dir = vim.fn.stdpath('data') .. '/site'
}
```

### INCORRECT (Master Branch Only):
```lua
require('nvim-treesitter.configs').setup {  -- ❌ Does NOT exist on main branch
  highlight = { enable = true },
  indent = { enable = true },
}
```

## ✅ Verified Installation

```lua
-- Install parsers (async)
require('nvim-treesitter').install({ 'rust', 'javascript', 'zig' })

-- Install parsers (sync - for bootstrapping)
require('nvim-treesitter').install({ 'rust', 'javascript', 'zig' }):wait(300000)
```

## ✅ Verified Feature Setup

### Highlighting
```lua
-- Manual setup required - NO automatic module
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'lua', 'python', 'rust' },
  callback = function()
    vim.treesitter.start()
  end,
})
```

### Folding
```lua
-- Per filetype
vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.wo.foldmethod = 'expr'
```

### Indentation
```lua
-- Experimental, provided by plugin
vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
```

## 🔍 Current Issues

### 1. Compatibility Shims in lazy.lua
The shims in `/Users/wm/nix-config/home/programs/editors/neovim/lua/config/lazy.lua` are designed for the **master branch** API and try to provide `nvim-treesitter.configs` which doesn't exist on main branch.

**Status**: These shims are for DEPENDENCY PLUGINS (textobjects, etc.) that still expect master branch API. They're actually NEEDED.

### 2. Current Configuration
Your `/Users/wm/nix-config/home/programs/editors/neovim/lua/plugins/treesitter.lua` is CORRECT for main branch:
- ✅ Uses `require('nvim-treesitter').setup`
- ✅ Manual highlighting autocmds
- ✅ Manual indentation setup
- ✅ Uses `:TSUpdate` in build

## Summary

| Aspect | Master Branch | Main Branch |
|--------|--------------|-------------|
| **Setup API** | `require("nvim-treesitter.configs").setup` | `require("nvim-treesitter").setup` |
| **Highlighting** | `highlight = { enable = true }` | Manual `FileType` autocmd |
| **Commands** | `:TSUpdate`, `:TSModuleInfo` | `:TSUpdate`, `:TSInstallInfo` |
| **Module System** | ✅ Yes | ❌ No |
| **Updates** | ❌ Frozen | ✅ Active |

## Recommendation

**Your current setup is CORRECT!** The compatibility shims in lazy.lua are needed for plugins like nvim-treesitter-textobjects that haven't migrated to main branch yet. Keep them.
