# Neovim Hang Debugging Guide

## Issue
Neovim hangs on startup showing only a cursor.

## Quick Fix - Disable Treesitter Auto-Install
The auto-install autocmd has been disabled in `treesitter.lua` (line 363-388).

## Debugging Steps

### 1. Start Neovim with Minimal Config
```bash
# Start with NO plugins
nvim --clean

# If this works, the issue is in your config
```

### 2. Start with Verbose Logging
```bash
# See what's loading
nvim -V9nvim.log

# Check the log
tail -f nvim.log
```

### 3. Check for Hanging Processes
```bash
# In another terminal while nvim is hung
ps aux | grep nvim
ps aux | grep tree-sitter
```

### 4. Start with Lazy Profile
```bash
# Normal start, then in nvim (if it loads):
:Lazy profile
```

### 5. Disable Treesitter Completely (Temporary)
Edit `lua/plugins/treesitter.lua` and add at the top:
```lua
return {} -- Disable treesitter temporarily
```

### 6. Check Lazy.nvim Lock File
```bash
# Remove lazy-lock.json to force fresh install
rm ~/.local/share/nvim/lazy-lock.json
```

## Common Causes

### 1. Treesitter Parser Installation
**Symptom:** Hangs when opening files  
**Fix:** Disabled auto-install, use `:TSInstallCurrent` manually

### 2. LSP Server Starting
**Symptom:** Hangs on specific filetypes  
**Fix:** Check `:LspInfo` or disable LSP temporarily

### 3. Plugin Sync/Install
**Symptom:** Hangs on first startup  
**Fix:** Let it finish or delete `~/.local/share/nvim/lazy/`

### 4. Conform.nvim Formatting
**Symptom:** Hangs when switching buffers  
**Fix:** Already wrapped in VeryLazy event

## Manual Parser Installation

Instead of auto-install, use these commands:

```vim
" Install parser for current file
:TSInstallCurrent

" Install specific parser
:TSInstall python

" Install all parsers (slow, do this once when you have time)
:TSInstallAll

" Check what's installed
:TSStatus
```

## Emergency Recovery

If Neovim won't start at all:

```bash
# 1. Backup your config
cp -r ~/.config/nvim ~/.config/nvim.backup

# 2. Remove all Neovim data
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim

# 3. Start fresh
nvim
# Let Lazy.nvim bootstrap and install plugins
# This may take a few minutes
```

## Test After Fix

1. Start Neovim: `nvim`
2. Should see dashboard immediately
3. Open a file: `:e test.lua`
4. Install parser if needed: `:TSInstallCurrent`
5. Check highlighting works

## Current Configuration

- ✅ Auto-install disabled (prevents hangs)
- ✅ Only essential parsers installed at startup
- ✅ Manual commands available:
  - `:TSInstallCurrent` - Install for current file
  - `:TSInstallAll` - Install all parsers
  - `:TSInstall <lang>` - Install specific parser
