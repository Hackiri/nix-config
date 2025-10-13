# Treesitter Build Command Fix

## Issue
The main branch doesn't support the old `:TSUpdate` command in the build step, causing this error:
```
attempt to call field 'available_parsers' (a nil value)
```

## Fix Applied

### Changed Build Command
```lua
-- Old (doesn't work with main branch)
build = ":TSUpdate",

-- New (main branch compatible)
build = function()
  -- Main branch doesn't support :TSUpdate in build step
  -- Parsers are installed in config function instead
end,
```

### Why This Works
- Main branch has a different API structure
- `:TSUpdate` command doesn't exist in the same form
- Parsers are installed programmatically via `require("nvim-treesitter").install()`
- Installation happens in the `config` function, not the `build` step

## Next Steps

1. **Restart Neovim** or run:
   ```vim
   :Lazy sync
   ```

2. **Check for errors** - Should load without the build error now

3. **Verify parsers install**:
   ```vim
   :messages
   ```
   Look for parser installation messages

4. **Manual install if needed**:
   ```vim
   :TSInstall lua python javascript
   ```

## Additional Changes

- Removed `branch = "main"` from textobjects dependency (let it auto-detect)
- Added error handling for parser installation
- Installation runs asynchronously in background

## If Issues Persist

The main branch is still stabilizing. If you encounter more issues:

### Option 1: Wait for async installation
Parsers install in the background. Wait a minute, then check:
```vim
:TSInstallInfo
```

### Option 2: Manually install parsers
```vim
:TSInstall all
```

### Option 3: Revert to master branch
```bash
cd /Users/wm/nix-config
cp home/programs/editors/neovim/lua/plugins/treesitter-master-backup.lua \
   home/programs/editors/neovim/lua/plugins/treesitter.lua
nixswitch
```

Then in Neovim:
```vim
:Lazy sync
```
