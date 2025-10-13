# Disabled Plugins Summary

## Plugins Disabled (10 Total)

### From Migration (8 plugins from backup):
1. ✅ `close-buffers.lua` - Close hidden/nameless buffers
2. ✅ `dial.lua` - Enhanced increment/decrement
3. ✅ `git-nvim.lua` - Git blame and browse
4. ✅ `inc-rename.lua` - Incremental LSP rename
5. ✅ `mini-bracketed.lua` - Navigate with [] brackets
6. ✅ `nvim-highlight-colors.lua` - Inline color highlighting
7. ✅ `zen-mode.lua` - Distraction-free writing

Note: `incline.lua` was already deleted (not just disabled)

### Previously Disabled (3 plugins):
1. ✅ `avante.lua` - AI assistant (you disabled)
2. ✅ `copilot.lua` - GitHub Copilot (you disabled)
3. ✅ `conform.lua` - Formatter (you deleted, now disabled)

## Active Plugins Remaining: 46

These are your core plugins from before the migration.

## To Re-enable a Plugin

```bash
cd /Users/wm/nix-config/home/programs/editors/neovim/lua/plugins
mv <plugin-name>.lua.disabled <plugin-name>.lua
```

Or use the script:
```bash
./disable-plugin.sh enable <plugin-name>
```

## Next Steps

1. Test Neovim with the reduced plugin set
2. If it works, you're back to your pre-migration state
3. If you want any of the migration plugins back, re-enable them one by one

## Migration Plugins Features (Now Disabled)

If you want these features back later:

- **close-buffers**: `<leader>th` (close hidden), `<leader>tu` (close unnamed)
- **dial**: `<C-a>`/`<C-x>` on dates, booleans, semver
- **git-nvim**: `<leader>gb` (blame), `<leader>go` (browse)
- **inc-rename**: `<leader>rn` (incremental rename with preview)
- **mini-bracketed**: `[b`/`]b` (buffers), `[d`/`]d` (diagnostics), etc.
- **nvim-highlight-colors**: Auto-highlight hex/rgb/hsl colors
- **zen-mode**: `<leader>z` (distraction-free mode)
