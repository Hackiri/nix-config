# Treesitter Manual Loading Guide

## Overview

If treesitter doesn't auto-load for a file, you now have **multiple ways** to manually trigger it.

## Quick Reference

| Method | Command | Keybinding | Use Case |
|--------|---------|------------|----------|
| **Start** | `:TSStart` | `<leader>ts` | File opened but no highlighting |
| **Restart** | `:TSRestart` | `<leader>tr` | Highlighting broken, need to reload |
| **Status** | `:TSStatus` | - | Check if treesitter is working |
| **Force** | `:lua vim.treesitter.start()` | - | Direct API call |

## Commands

### 1. `:TSStart` - Start Treesitter

Manually starts treesitter highlighting for the current buffer.

**Usage:**
```vim
:TSStart
```

**What it does:**
1. Checks if filetype is set
2. Checks if treesitter already active
3. Tries to start treesitter
4. Shows success/error notification
5. Suggests parser installation if fails

**Examples:**
```vim
" Open a file without highlighting
:e test.lua

" Manually start treesitter
:TSStart
" Output: ✓ Treesitter started for lua

" Try again (already active)
:TSStart
" Output: Treesitter already active for lua

" File with no parser
:e test.unknown
:TSStart
" Output: ✗ Failed to start treesitter
" Output: Try: :TSInstall unknown
```

**Keybinding:** `<leader>ts`
```vim
" Same as :TSStart
<leader>ts
```

### 2. `:TSRestart` - Restart Treesitter

Stops and restarts treesitter (useful if highlighting is broken).

**Usage:**
```vim
:TSRestart
```

**What it does:**
1. Stops treesitter if active
2. Waits a tick (vim.schedule)
3. Restarts treesitter
4. Shows notification

**Use cases:**
- Highlighting suddenly disappeared
- Syntax colors look wrong
- After installing a new parser
- After updating parsers

**Keybinding:** `<leader>tr`
```vim
" Restart treesitter
<leader>tr
```

### 3. `:TSStatus` - Check Status

Shows detailed treesitter status for current buffer.

**Usage:**
```vim
:TSStatus
```

**Output example:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Treesitter Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Buffer: 1
Filetype: lua
Active: ✓ YES
Language: lua
Parser: ✓ Installed
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Or if parser missing:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Treesitter Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Buffer: 2
Filetype: rust
Active: ✗ NO
Language: rust
Parser: ✗ Not installed

Install with: :TSInstall rust
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Use cases:**
- Debugging why highlighting isn't working
- Checking if parser is installed
- Verifying filetype detection
- Troubleshooting

## Keybindings

### `<leader>ts` - Start Treesitter

Quick way to manually start highlighting:
```vim
" In normal mode
<leader>ts
```

**When to use:**
- File opened from explorer without highlighting
- After setting filetype manually
- After installing parser

### `<leader>tr` - Restart Treesitter

Quick way to restart when broken:
```vim
" In normal mode
<leader>tr
```

**When to use:**
- Colors suddenly wrong
- Highlighting disappeared
- After parser update

## Advanced Usage

### Direct API Calls

If commands don't work, use the Lua API directly:

```vim
" Start treesitter
:lua vim.treesitter.start()

" Start for specific buffer
:lua vim.treesitter.start(0)  " 0 = current buffer

" Stop treesitter
:lua vim.treesitter.stop()

" Check if active
:lua print(vim.treesitter.highlighter.active[0] ~= nil)
```

### Set Filetype First

If filetype isn't detected:
```vim
" Set filetype
:set filetype=python

" Then start treesitter
:TSStart
```

### Install Missing Parser

If parser is missing:
```vim
" Install parser
:TSInstall python

" Then start treesitter
:TSStart
```

## Troubleshooting Workflow

### Problem: No highlighting in opened file

**Step 1:** Check status
```vim
:TSStatus
```

**Step 2:** If "Active: ✗ NO", try starting
```vim
:TSStart
" or
<leader>ts
```

**Step 3:** If "Parser: ✗ Not installed", install it
```vim
:TSInstall <language>
```

**Step 4:** Try starting again
```vim
:TSStart
```

**Step 5:** If still fails, check filetype
```vim
:set filetype?
```

**Step 6:** If filetype wrong, set it
```vim
:set filetype=python
:TSStart
```

### Problem: Highlighting is broken/wrong colors

**Solution:** Restart treesitter
```vim
:TSRestart
" or
<leader>tr
```

### Problem: Highlighting works in CLI but not from explorer

This should be fixed by the V2 autocmds, but if it happens:
```vim
" After opening file from explorer
<leader>ts
```

## Integration with Which-Key

The keybindings will show up in which-key:

Press `<leader>` and wait, you'll see:
```
t → Tabs/Treesitter
  ts → Start Treesitter
  tr → Restart Treesitter
  ...
```

## Examples

### Example 1: File from Explorer (No Auto-load)

```vim
" Open mini-files
:lua require("mini.files").open()

" Navigate and open test.lua
" Press <CR>

" No highlighting? Quick fix:
<leader>ts

" ✓ Treesitter started for lua
```

### Example 2: New Language Support

```vim
" Open file with new language
:e test.zig

" Check status
:TSStatus
" Output: Parser: ✗ Not installed

" Install parser
:TSInstall zig

" Start treesitter
:TSStart
" ✓ Treesitter started for zig
```

### Example 3: Debugging

```vim
" File opened but looks wrong
:TSStatus

" Shows:
" Active: ✓ YES
" Parser: ✓ Installed

" But colors still wrong? Restart:
:TSRestart
" ✓ Treesitter restarted for lua

" Still wrong? Check with Inspect:
:Inspect
" Shows highlight groups
```

### Example 4: Unknown Filetype

```vim
" Open file without extension
:e Jenkinsfile

" Set filetype manually
:set filetype=groovy

" Start treesitter
:TSStart
" ✓ Treesitter started for groovy
```

## Command Comparison

### `:TSStart` vs `:TSRestart`

| Aspect | :TSStart | :TSRestart |
|--------|----------|------------|
| **Use when** | Not started | Already started |
| **Action** | Start only | Stop + Start |
| **If already active** | Shows message, does nothing | Restarts anyway |
| **Speed** | Instant | Slight delay (schedule) |

### `:TSStatus` vs `:Inspect`

| Aspect | :TSStatus | :Inspect |
|--------|----------|----------|
| **Shows** | Parser status, filetype, active | Highlight groups at cursor |
| **Use for** | Debugging loading | Debugging colors |
| **Output** | Text summary | Floating window |

## Notifications

All commands show notifications:

**Success:**
```
✓ Treesitter started for lua
```

**Already active:**
```
Treesitter already active for lua
```

**Failed:**
```
✗ Failed to start treesitter: [error]
Try: :TSInstall lua
```

**No filetype:**
```
No filetype detected. Set filetype first with :set filetype=<lang>
```

## Tips

### 1. Add to Your Workflow

When opening files from explorers, if no highlighting:
```vim
<leader>ts  " Quick manual start
```

### 2. Check Parser Before Troubleshooting

Always run `:TSStatus` first to see what's wrong.

### 3. Restart After Updates

After `:TSUpdate`, restart treesitter in open buffers:
```vim
:bufdo TSRestart
```

### 4. Custom Keybindings

Don't like `<leader>ts`? Change it in your config:
```lua
vim.keymap.set("n", "<F5>", "<cmd>TSStart<cr>", { desc = "Start TS" })
vim.keymap.set("n", "<F6>", "<cmd>TSRestart<cr>", { desc = "Restart TS" })
```

### 5. Auto-restart on BufEnter

If you want to force restart every time you enter a buffer:
```lua
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    vim.schedule(function()
      pcall(vim.treesitter.start)
    end)
  end,
})
```

## Summary

You now have **4 manual methods**:

1. **`:TSStart`** / `<leader>ts` - Quick start
2. **`:TSRestart`** / `<leader>tr` - Fix broken highlighting
3. **`:TSStatus`** - Check what's wrong
4. **`:lua vim.treesitter.start()`** - Direct call

**Most common use case:**
```vim
" File opened without highlighting
<leader>ts
```

**When broken:**
```vim
" Highlighting looks wrong
<leader>tr
```

**When debugging:**
```vim
" What's wrong?
:TSStatus
```

Simple, fast, and always available! 🎉
