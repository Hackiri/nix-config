# Treesitter Main Branch - Official Improvements Applied

Based on the official [nvim-treesitter main branch README](https://github.com/nvim-treesitter/nvim-treesitter/blob/main/README.md), I've updated your configuration to follow best practices.

## ✅ Applied Improvements

### 1. **Build Command - Now Uses :TSUpdate**
```lua
build = ":TSUpdate"
```
**Source**: Official README recommendation  
**Why**: The main branch DOES support `:TSUpdate` - my earlier assumption was wrong!

### 2. **Simplified Parser Installation**
```lua
-- Cleaner async installation
vim.schedule(function()
  pcall(ts.install, languages)
end)
```
**Why**: No need for complex error handling - pcall is sufficient

### 3. **Highlighting - Official Pattern**
```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = highlight_filetypes,
  callback = function()
    vim.treesitter.start() -- Defaults to current buffer
  end,
})
```
**Source**: Main branch README, Highlighting section  
**Changes**:
- Removed unnecessary `args.buf` parameter
- Cleaner callback
- Official documentation pattern

### 4. **Indentation - Official Pattern (Experimental)**
```lua
vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
```
**Source**: Main branch README, Indentation section  
**Note**: Specific quotes are important per docs

### 5. **NEW: Treesitter Folding Support**
```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = fold_filetypes,
  callback = function()
    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.wo.foldmethod = "expr"
    vim.wo.foldenable = false -- Start with folds open
  end,
})
```
**Source**: Main branch README, Folds section  
**Why**: Treesitter-based folding is built into Neovim - now enabled for supported languages

## Configuration Summary

### Enabled Features

| Feature | Status | Languages | Notes |
|---------|--------|-----------|-------|
| **Highlighting** | ✅ Active | 30+ languages | Official pattern from docs |
| **Indentation** | ⚠️ Experimental | 15+ languages | May have edge cases |
| **Folding** | ✅ Optional | 12 languages | Native Neovim feature |
| **Injections** | ✅ Automatic | All | Multi-language docs (no setup needed) |
| **Textobjects** | ⚠️ Best effort | All | Plugin may need updates |

### Language Coverage

#### Highlighting (30+ languages)
```
lua, python, javascript, typescript, tsx, jsx, rust, go, java, c, cpp, ruby, php,
html, css, scss, json, yaml, toml, bash, fish, markdown, vim, nix, terraform,
dockerfile, sql, graphql, vue, svelte
```

#### Indentation (15+ languages)
```
lua, javascript, typescript, tsx, jsx, rust, go, java, c, cpp, ruby, php,
html, css, json, vim, nix
```

#### Folding (12 languages)
```
lua, python, javascript, typescript, tsx, jsx, rust, go, java, c, cpp, ruby
```

## Official Documentation References

All improvements are based on:
- [Main Branch README](https://github.com/nvim-treesitter/nvim-treesitter/blob/main/README.md)
- Official installation guide
- Highlighting section: `:h treesitter-highlight`
- Folding section: Native Neovim feature
- Indentation: Plugin-provided (experimental)

## Key Takeaways from Official Docs

### ✅ What Works Great
1. **Parser Management**: Rock solid, automatic updates
2. **Highlighting**: Native Neovim feature, very stable
3. **Query Distribution**: 200+ languages supported
4. **Folding**: Native Neovim, works well

### ⚠️ What's Experimental
1. **Indentation**: Plugin-provided, may have issues with some languages
2. **Textobjects**: Ecosystem plugin, may not fully support main yet

### ❌ What's Removed
1. **Module System**: No more `configs.setup()` with modules
2. **Automatic Enablement**: Everything must be explicit
3. **Incremental Selection**: Moved to flash.nvim (per LazyVim)

## Setup Instructions

### First Time
```bash
# Already done if you ran nixswitch
cd /Users/wm/nix-config
nixswitch
```

### In Neovim
```vim
# Sync plugins (switches to main branch)
:Lazy sync

# Verify parsers install
:TSInstallInfo

# Check health
:checkhealth nvim-treesitter

# Test in a file
:Inspect  " See treesitter highlights
```

### Testing Folding (NEW)
```vim
# Open a Lua/Python file
za   " Toggle fold under cursor
zR   " Open all folds
zM   " Close all folds
```

## Neovim Requirements

Per official docs:
- **Neovim**: 0.11.0+ (nightly)
- **tree-sitter-cli**: 0.25.0+
- **Node**: 23.0.0+ (for some parsers)
- **C compiler**: For building parsers

Check these with:
```vim
:checkhealth nvim-treesitter
```

## Comparison: Master vs Main Branch

| Aspect | Master (Old) | Main (New) |
|--------|-------------|------------|
| **API** | `configs.setup()` | `setup()` + autocmds |
| **Modules** | Automatic | Manual |
| **Highlighting** | `highlight.enable` | `vim.treesitter.start()` |
| **Indentation** | `indent.enable` | `vim.bo.indentexpr` |
| **Folding** | Not included | `vim.wo.foldexpr` |
| **Updates** | Frozen | Active |
| **Complexity** | Low (auto) | Medium (explicit) |
| **Control** | Limited | Full |

## Performance Notes

### From Official Docs
- Highlighting: Fast, native Neovim
- Folding: Fast, native Neovim  
- Indentation: Slower, plugin-provided
- Injections: Automatic, efficient

### Best Practices
1. Large files (>500KB): Highlighting disabled automatically (if you add that check)
2. Parsers: Compiled once, cached
3. Queries: Loaded on-demand

## Troubleshooting

### Issue: Highlighting doesn't work
**Check**: Is the filetype in `highlight_filetypes`?
```lua
-- Add to the list in treesitter.lua
local highlight_filetypes = {
  "lua", "python", ..., "your_language"
}
```

### Issue: Folding not working
**Check**: 
1. Is filetype in `fold_filetypes`?
2. Does the language have fold queries?
   ```vim
   :TSInstallInfo
   ```

### Issue: Indentation weird
**Solution**: Disable for that language
```lua
-- In indent_filetypes, remove the language
-- OR use manual indent for specific language
```

## Future Updates

The main branch is actively developed. To update:

```vim
:Lazy sync     " Update plugin
:TSUpdate      " Update all parsers
```

## Documentation

- **Official**: `:h nvim-treesitter`
- **Highlighting**: `:h treesitter-highlight`
- **Folding**: `:h vim.treesitter.foldexpr()`
- **README**: [Main Branch](https://github.com/nvim-treesitter/nvim-treesitter/blob/main/README.md)

## Summary

Your configuration now follows the official main branch patterns exactly:
- ✅ Uses `:TSUpdate` for builds (official recommendation)
- ✅ Simplified highlighting setup (official pattern)
- ✅ Correct indentation syntax (per docs)
- ✅ NEW: Treesitter folding support
- ✅ Clean, maintainable code structure

All improvements are sourced directly from the official nvim-treesitter main branch documentation!
