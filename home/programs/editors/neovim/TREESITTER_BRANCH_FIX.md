# Critical Fix: Switch to Master Branch

## The Issue

You were using nvim-treesitter's `main` branch, which is a **complete, incompatible rewrite**. The `main` branch:

- ❌ Has NO `nvim-treesitter.configs` module
- ❌ Has NO `highlight.enable` configuration
- ❌ Has NO automatic module management
- ❌ Requires manual `vim.treesitter.start()` calls

## The Solution

**Switch to the `master` branch** - the stable, frozen, backward-compatible version.

## What Changed

### `/Users/wm/nix-config/home/programs/editors/neovim/lua/plugins/treesitter.lua`

```lua
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master", -- ← CRITICAL: Use master branch
  build = ":TSUpdate",
  lazy = false,
  -- ... rest of config
}
```

## Next Steps

1. **Restart Neovim** or run:
   ```vim
   :Lazy sync
   ```
   
   This will:
   - Switch from `main` to `master` branch
   - Re-download the correct version
   - Install the traditional API

2. **Verify the branch**:
   ```vim
   :Lazy
   ```
   Look for nvim-treesitter - should show `master` branch

3. **Test syntax highlighting**:
   - Open any code file
   - Colors should appear immediately
   - Run `:Inspect` to see treesitter highlight groups

4. **Check status**:
   ```vim
   :TSModuleInfo
   ```
   Should show modules as enabled

## Why This Happened

The LazyVim documentation mentions "nvim-treesitter to main branch" as a breaking change, but this refers to **migrating TO the new API**, not using it by default. For traditional configurations, `master` is the correct choice.

## References

From nvim-treesitter README:
> This is a full, incompatible, rewrite. If you can't or don't want to update, check out the master branch (which is locked but will remain available for backward compatibility).

The `master` branch is:
- ✅ Stable and tested
- ✅ Feature-complete with all modules
- ✅ Backward compatible
- ✅ Recommended for most users
