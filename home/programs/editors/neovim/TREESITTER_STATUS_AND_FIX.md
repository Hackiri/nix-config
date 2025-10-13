# Treesitter Status and Troubleshooting

## ✅ Configuration Verification (Completed)

### File Location
`/Users/wm/nix-config/home/programs/editors/neovim/lua/plugins/treesitter.lua` (209 lines)

### Configuration Status: ✅ CORRECT

Your configuration is properly set up for the **main branch**:

1. ✅ **API**: Uses `require("nvim-treesitter").setup` (correct for main)
2. ✅ **Commands**: Uses `:TSUpdate` in build (verified to exist)
3. ✅ **Highlighting**: Manual FileType autocmds (required for main)
4. ✅ **Indentation**: Manual setup (experimental)
5. ✅ **Folding**: Optional treesitter folding
6. ✅ **Lazy Loading**: `lazy = false` (correct - no lazy loading)
7. ✅ **Compatibility Shims**: Present in lazy.lua for dependency plugins

## Issue: Filetype/Language Not Detected

### Diagnosis

If filetype and language aren't showing in your statusline, the likely causes are:

1. **Parsers not installed yet** (async installation may still be running)
2. **Neovim needs restart** after nixswitch
3. **Parsers failed to compile**
4. **Treesitter not starting for the filetype**

## Step-by-Step Fix

### Step 1: Restart Neovim

After `nixswitch`, you need to restart Neovim (not just `:source`):

```bash
# Close all Neovim instances
pkill nvim

# Start fresh
nvim
```

### Step 2: Sync Lazy Plugins

In Neovim:
```vim
:Lazy sync
```

Wait for it to complete. It will:
- Clone/update nvim-treesitter from main branch
- Run `:TSUpdate` automatically

### Step 3: Check Installation

```vim
:TSInstallInfo
```

This should show a list of parsers. Look for:
- Green checkmarks ✓ = installed
- Red X = failed or not installed

### Step 4: Manually Install Core Parsers

If parsers aren't installed:
```vim
:TSInstall lua python javascript typescript rust go
```

### Step 5: Test Highlighting

Open a test file:
```vim
:e /tmp/test.lua
```

Type some Lua code:
```lua
local function hello()
  print("Hello world")
end
```

Check if highlighting works:
```vim
:Inspect
```

Should show treesitter highlight groups like `@function.lua`, `@string.lua`, etc.

### Step 6: Check Autocmds

Verify autocmds are created:
```vim
:autocmd TreesitterHighlight
:autocmd TreesitterIndent
:autocmd TreesitterFold
```

Should show autocmds for various filetypes.

### Step 7: Check Statusline

Your lualine config shows filetype at line 224:
```lua
{
  "filetype",
  icon_only = true,
  separator = "",
  padding = { left = 1, right = 0 },
},
```

The filetype should appear. If it doesn't, check:
```vim
:set filetype?
```

Should show the current filetype (e.g., `filetype=lua`).

## Debugging Commands

### Check if nvim-treesitter loaded:
```vim
:lua print(vim.inspect(require("nvim-treesitter")))
```

### Check if parser exists:
```vim
:lua print(vim.fn.isdirectory(vim.fn.stdpath("data") .. "/site/parser"))
```

### List parsers:
```vim
:lua print(vim.fn.glob(vim.fn.stdpath("data") .. "/site/parser/*.so", false, true))
```

### Force enable highlighting:
```vim
:lua vim.treesitter.start()
```

### Check for errors:
```vim
:messages
```

## Common Issues and Solutions

### Issue 1: "nvim-treesitter not available"
**Cause**: Plugin not loaded  
**Fix**: 
```vim
:Lazy reload nvim-treesitter
```

### Issue 2: No parsers installed
**Cause**: Async installation hasn't completed  
**Fix**: Wait a minute, then run:
```vim
:TSInstallInfo
```

### Issue 3: Parser compilation failed
**Cause**: Missing C compiler or tree-sitter-cli  
**Fix**: Check health:
```vim
:checkhealth nvim-treesitter
```

### Issue 4: Highlighting not working
**Cause**: Autocmd not triggering or parser missing  
**Fix**: 
```vim
:lua vim.treesitter.start()  -- Force start
:TSInstall <language>        -- Install parser
```

### Issue 5: Filetype not detected
**Cause**: Filetype detection failing  
**Fix**: Check filetype:
```vim
:set filetype?
:filetype detect
```

## Expected Behavior

After successful setup:

1. **Opening a Lua file**:
   - Syntax highlighting appears immediately
   - Statusline shows filetype icon + "lua"
   - `:Inspect` shows treesitter groups

2. **Opening a Python file**:
   - Syntax highlighting appears
   - Statusline shows filetype icon + "python"
   - `:TSInstallInfo` shows python parser installed

3. **Folding**:
   - In supported languages, `za` toggles folds
   - `zM` closes all folds
   - `zR` opens all folds

## Verification Checklist

Run these commands and check for ✅:

```vim
" 1. Plugin loaded?
:lua print(pcall(require, "nvim-treesitter") and "✅" or "❌")

" 2. Parsers directory exists?
:lua print(vim.fn.isdirectory(vim.fn.stdpath("data") .. "/site/parser") == 1 and "✅" or "❌")

" 3. Autocmds created?
:autocmd TreesitterHighlight

" 4. Current filetype?
:set filetype?

" 5. Treesitter active?
:lua print(vim.treesitter.highlighter.active[0] and "✅" or "❌")
```

## Next Steps

1. **Restart Neovim** after nixswitch
2. **Run `:Lazy sync`** to install plugins
3. **Open a test file** (test.lua, test.py, etc.)
4. **Verify highlighting** with `:Inspect`
5. **Check statusline** for filetype display

If issues persist, run `:checkhealth nvim-treesitter` and share the output.
