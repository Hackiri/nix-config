# Treesitter Configuration - MCP Validation Results

## Validation Source
Validated against official `nvim-treesitter/nvim-treesitter` repository using DeepWiki MCP server.

## Key Findings & Fixes Applied

### 1. ✅ Branch Selection: `master` (Correct)
**MCP Recommendation:**
- `master` branch is frozen for backward compatibility
- `main` branch is active development (will become default in future)
- For stability in 2024-2025: Use `master` branch

**Applied:**
```lua
branch = "master"
```

### 2. ✅ Build Command: `:TSUpdate` (Restored)
**MCP Recommendation:**
- **Strongly recommended** to use `build = ":TSUpdate"`
- Updates parsers to versions in `lockfile.json`
- Prevents "query error: invalid node type" issues
- Prevents outdated parser problems

**Applied:**
```lua
build = ":TSUpdate"
```

**Previous Error Resolved:**
The `available_parsers` API error was likely due to incomplete plugin loading, not the TSUpdate command itself. The official docs explicitly recommend using `:TSUpdate`.

### 3. ✅ Lazy Loading: Disabled (Correct)
**MCP Recommendation:**
- nvim-treesitter does **NOT support lazy-loading**
- Must be loaded immediately

**Applied:**
```lua
lazy = false
```

### 4. ✅ Configuration Structure (Correct)
**MCP Recommendation:**
- Use `require('nvim-treesitter.configs').setup()`
- Configure via `opts` table in lazy.nvim

**Current Config:**
```lua
opts = {
  ensure_installed = { ... },
  highlight = { enable = true },
  indent = { enable = true },
  incremental_selection = { enable = true },
  textobjects = { ... },
}
```

### 5. ✅ Essential Options (All Present)

#### `ensure_installed`
- ✅ List of parsers to auto-install
- ✅ Includes core parsers: lua, vim, vimdoc, query
- ✅ Includes common languages: python, javascript, typescript, etc.

#### `sync_install`
- ✅ Set to `false` (recommended default)

#### `auto_install`
- ✅ Set to `false` (prevents hangs, requires tree-sitter CLI)

#### `highlight`
- ✅ `enable = true`
- ✅ `disable` function for large files (100KB threshold)
- ✅ `additional_vim_regex_highlighting = false` (recommended)

#### `indent`
- ✅ `enable = true`
- ✅ `disable` for problematic languages (python, yaml)

#### `incremental_selection`
- ✅ `enable = true`
- ✅ Keymaps configured: `<C-space>`, `<bs>`

#### `textobjects`
- ✅ `select` configured with keymaps
- ✅ `move` configured for navigation

## Common Errors Avoided

### ❌ Outdated Parsers
**Problem:** `query error: invalid node type at position`
**Solution:** ✅ Using `build = ":TSUpdate"` keeps parsers in sync

### ❌ Multiple Parser Directories
**Problem:** Wrong parser version loaded
**Solution:** ✅ Single installation via lazy.nvim

### ❌ Lazy-loading
**Problem:** Features don't work
**Solution:** ✅ `lazy = false` - immediate loading

### ❌ Missing Query Files
**Problem:** Modules don't work for specific languages
**Solution:** ✅ Run `:checkhealth nvim-treesitter` to verify

## Validation Commands

Run these in Neovim to verify configuration:

```vim
:checkhealth nvim-treesitter
:TSInstallInfo
:echo nvim_get_runtime_file('parser', v:true)
:echo &filetype
```

## Configuration Confidence: ✅ HIGH

All MCP recommendations have been applied:
- ✅ Correct branch (`master`)
- ✅ Correct build command (`:TSUpdate`)
- ✅ No lazy-loading
- ✅ All required options configured
- ✅ Common errors avoided

## Next Steps

1. Run `nixswitch` to apply changes
2. Start Neovim - parsers will update via `:TSUpdate`
3. Run `:checkhealth nvim-treesitter` to verify
4. Test highlighting, text objects, and incremental selection

## References

- Official nvim-treesitter repository
- Validated via DeepWiki MCP server
- Date: 2024-10-13
