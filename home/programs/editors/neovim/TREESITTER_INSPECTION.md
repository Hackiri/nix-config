# Treesitter Inspection Tools (Native Neovim)

## Overview

The deprecated `nvim-treesitter/playground` plugin has been replaced by native Neovim commands in version 0.10+.

## Native Commands

### `:Inspect`
**Purpose:** Show highlight groups under the cursor  
**Keybinding:** `<leader>ti`  
**Alias:** `:TSInspect`

Shows all highlight groups applied to the character under the cursor, useful for debugging syntax highlighting.

### `:InspectTree`
**Purpose:** Show the parsed syntax tree (TSPlayground replacement)  
**Keybinding:** `<leader>tt`  
**Alias:** `:TSPlayground`

Opens an interactive window showing the treesitter syntax tree for the current buffer. This is the direct replacement for the old TSPlayground.

### `:EditQuery`
**Purpose:** Open the Live Query Editor  
**Keybinding:** `<leader>tq`  
**Requires:** Neovim 0.10+

Opens an interactive query editor where you can write and test treesitter queries in real-time.

## Quick Reference

| Command | Keybinding | Description |
|---------|------------|-------------|
| `:Inspect` | `<leader>ti` | Inspect highlight groups |
| `:InspectTree` | `<leader>tt` | Show syntax tree (playground) |
| `:EditQuery` | `<leader>tq` | Live query editor |
| `:TSStart` | `<leader>ts` | Start treesitter highlighting |
| `:TSRestart` | `<leader>tr` | Restart treesitter highlighting |
| `:TSStatus` | - | Show treesitter status |
| `:TSInstallAll` | - | Install all parsers |

## Backward Compatibility

For users familiar with the old playground plugin, these aliases are available:
- `:TSPlayground` → `:InspectTree`
- `:TSInspect` → `:Inspect`

## Benefits

✅ **No external plugin needed** - Built into Neovim  
✅ **Better performance** - Native implementation  
✅ **Always up-to-date** - Maintained by Neovim core team  
✅ **More features** - Live query editor is more powerful
