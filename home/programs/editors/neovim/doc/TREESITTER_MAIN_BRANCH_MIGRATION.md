# nvim-treesitter Main Branch Migration Guide

## ✅ Migration Complete

Your configuration has been migrated from the `master` branch (frozen) to the `main` branch (active development).

## What Changed

### From (Master Branch - Old API)
```lua
branch = "master"
require("nvim-treesitter.configs").setup({
  highlight = { enable = true },
  indent = { enable = true },
  -- Automatic module management
})
```

### To (Main Branch - New API)
```lua
branch = "main"
require("nvim-treesitter").setup({
  install_dir = vim.fn.stdpath("data") .. "/site"
})

-- Manual highlighting setup
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lua", "python", ... },
  callback = function(args)
    vim.treesitter.start(args.buf)
  end,
})
```

## Key Differences

### What Main Branch DOES
- ✅ Parser installation and management
- ✅ Query file distribution
- ✅ `:TSInstall`, `:TSUpdate` commands

### What Main Branch DOES NOT
- ❌ No `nvim-treesitter.configs` module
- ❌ No automatic `highlight.enable` 
- ❌ No automatic `indent.enable`
- ❌ No module system
- ⚠️ Requires **manual** highlighting setup

## Configuration Structure

### 1. Parser Installation (Simple)
```lua
require("nvim-treesitter").setup({
  install_dir = vim.fn.stdpath("data") .. "/site"
})

-- Install languages
require("nvim-treesitter").install({ "lua", "python", "rust" })
```

### 2. Highlighting (Manual Autocmds)
```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lua", "python", "javascript", ... },
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})
```

### 3. Indentation (Manual Setup)
```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lua", "javascript", ... },
  callback = function()
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
```

## Backup Location

Your original `master` branch configuration is backed up at:
```
home/programs/editors/neovim/lua/plugins/treesitter-master-backup.lua
```

## Next Steps

1. **Sync Neovim plugins**:
   ```vim
   :Lazy sync
   ```
   This will switch from `master` to `main` branch

2. **Restart Neovim**

3. **Verify highlighting works**:
   ```vim
   :Inspect
   ```
   Should show treesitter highlight groups

4. **Check installed parsers**:
   ```vim
   :TSInstallInfo
   ```

5. **Run health check**:
   ```vim
   :checkhealth nvim-treesitter
   ```

## What to Expect

### ✅ Working
- Syntax highlighting (via manual autocmds)
- Parser management
- Basic treesitter queries
- Autotag (for HTML/JSX)
- Context commentstring

### ⚠️ May Need Updates
- **nvim-treesitter-textobjects**: May not fully support main branch yet
  - Basic textobjects should work
  - Advanced features may be limited
  
- **nvim-treesitter-context**: May need compatibility updates
  
- **Other treesitter plugins**: Check their documentation

### 📝 Manual Configuration Required
- You must list filetypes for highlighting in the autocmd
- You must list filetypes for indentation in the autocmd  
- No automatic module detection

## Troubleshooting

### Issue: No syntax highlighting
**Solution**: Check that your filetype is in the `highlight_filetypes` list in `treesitter.lua`

### Issue: Textobjects not working
**Solution**: The textobjects plugin may need to be updated for main branch compatibility. Check its repository for updates.

### Issue: Parser not found
**Solution**: Run `:TSInstall <language>` manually

### Issue: Want to go back to master
**Solution**: 
```lua
-- In treesitter.lua
branch = "master"
```
Then copy config from `treesitter-master-backup.lua`

## Philosophy of Main Branch

The main branch follows a **minimal, explicit** approach:

- **Parser management only** - Core responsibility
- **Manual feature setup** - You control what's enabled
- **Explicit is better** - No magic module system
- **Future-proof** - Aligns with Neovim's native treesitter evolution

This gives you:
- ✅ More control over features
- ✅ Better understanding of what's happening
- ✅ Easier debugging
- ✅ Future updates and improvements
- ❌ More manual configuration required

## Additional Resources

- [nvim-treesitter main branch README](https://github.com/nvim-treesitter/nvim-treesitter/blob/main/README.md)
- [Neovim treesitter documentation](`:h treesitter`)
- [vim.treesitter.start() docs](`:h vim.treesitter.start()`)

## Summary

You're now on the **active development branch** that will receive updates. The trade-off is more manual configuration, but you gain:

- 🔄 Continued updates
- 🐛 Bug fixes
- 🆕 New parser support
- 🎯 More control over features

The configuration is set up to work immediately, with highlighting and indentation configured for common languages.
