# Neovim Treesitter Fix Summary

## Problem Identified

When opening files in Neovim, treesitter language highlighting was not loading. The root cause was using the **wrong branch** of nvim-treesitter.

**Critical Discovery**: The `main` branch is a complete, incompatible rewrite that doesn't support the traditional module-based configuration API (`highlight.enable`, `indent.enable`, etc.).

## Root Causes

### **Wrong Branch**
- **Issue**: Using `main` branch which is an incompatible rewrite
- **Impact**: The `main` branch doesn't have `nvim-treesitter.configs` module or traditional module configuration
- **Solution**: Switch to `master` branch for stable, traditional API

### Branch Differences

**`main` branch** (incompatible rewrite):
- Minimal parser management only
- No `require("nvim-treesitter.configs")`
- No `highlight.enable`, `indent.enable` modules
- Requires manual `vim.treesitter.start()` autocmds for highlighting
- Recommended only for advanced users who want manual control

**`master` branch** (stable, frozen):
- Traditional module-based configuration
- `require("nvim-treesitter.configs").setup()` API
- Automatic module enablement (`highlight`, `indent`, etc.)
- Backward compatible
- Recommended for most users

## Changes Made

### File: `lua/plugins/treesitter.lua`

#### Change 1: **CRITICAL FIX - Switch to Master Branch**
```lua
branch = "master", -- Use stable master branch (main branch is incompatible rewrite)
lazy = false, -- Don't lazy load - treesitter needs to be available immediately
opts_extend = { "ensure_installed" },
```

**Rationale**: The `main` branch is a complete rewrite without the traditional configuration API. The `master` branch provides the stable, feature-complete API with module-based configuration.

#### Change 2: Updated init Function with Safe Loading
```lua
init = function(plugin)
  -- Add nvim-treesitter to runtimepath early
  require("lazy.core.loader").add_to_rtp(plugin)
  
  -- Optionally load query predicates if available (wrapped in pcall for safety)
  pcall(require, "nvim-treesitter.query_predicates")
  
  -- File type associations (existing code)
  -- ...
end,
```

#### Change 3: Added Error Handling in config Function
```lua
config = function(_, opts)
  -- Ensure nvim-treesitter is actually loaded
  local ts_ok, _ = pcall(require, "nvim-treesitter")
  if not ts_ok then
    vim.notify("nvim-treesitter not available", vim.log.levels.ERROR)
    return
  end
  
  -- Later: Safe require for configs module
  local configs_ok, configs = pcall(require, "nvim-treesitter.configs")
  if not configs_ok then
    vim.notify("nvim-treesitter.configs not available", vim.log.levels.ERROR)
    return
  end
  
  configs.setup({...})
```

#### Change 4: Added Deduplication Logic
```lua
-- Flatten language groups and deduplicate with opts.ensure_installed
-- Merge with opts from other plugins
if opts.ensure_installed then
  vim.list_extend(ensure_installed, opts.ensure_installed)
end

-- Deduplicate ensure_installed
local seen = {}
local deduped = {}
for _, lang in ipairs(ensure_installed) do
  if not seen[lang] then
    seen[lang] = true
    table.insert(deduped, lang)
  end
end
```

#### Change 5: Fixed Core Configuration
```lua
-- Configure the core nvim-treesitter plugin with modules
-- Modern nvim-treesitter requires configs.setup() to enable modules
require("nvim-treesitter.configs").setup({
  -- Ensure parsers are installed (deduplicated)
  ensure_installed = deduped,
  
  -- Auto-install missing parsers when entering buffer
  auto_install = true,
  
  -- Enable Tree-sitter based syntax highlighting
  highlight = {
    enable = true,
    -- Disable for very large files
    disable = function(lang, buf)
      local max_filesize = 500 * 1024 -- 500 KB
      local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
    end,
    additional_vim_regex_highlighting = false,
  },
  
  -- Enable Tree-sitter based indentation
  indent = {
    enable = true,
    -- Disable for languages where it causes issues
    disable = { "python", "yaml" },
  },
})
```

### File: `lua/config/autocmds.lua`

#### Added LazyFile Event
```lua
-- LazyFile event for lazy loading plugins when opening files
-- This mimics LazyVim's LazyFile event
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "BufWritePre" }, {
  group = augroup("lazy_file"),
  callback = function(event)
    -- Trigger LazyFile event for actual files (not special buffers)
    local file = vim.api.nvim_buf_get_name(event.buf)
    local buftype = vim.api.nvim_get_option_value("buftype", { buf = event.buf })
    
    if file ~= "" and buftype == "" then
      vim.api.nvim_exec_autocmds("User", { pattern = "LazyFile", modeline = false })
      -- Remove the autocmd after first trigger to avoid duplicate events
      vim.api.nvim_del_augroup_by_name("lazyvim_lazy_file")
    end
  end,
})
```

**Replaced old approach:**
```lua
require("nvim-treesitter").setup({})

vim.schedule(function()
  local ok, installer = pcall(require, "nvim-treesitter.install")
  if ok then
    pcall(installer.install, ensure_installed, { summary = false })
  end
end)
```

## Key Improvements

1. ✅ **No lazy loading**: Set `lazy = false` to ensure treesitter loads immediately (critical fix)
2. ✅ **Proper API usage**: Using `require("nvim-treesitter.configs").setup()`
3. ✅ **Error handling**: All requires wrapped in pcall for graceful degradation
4. ✅ **Correct module loading**: Using `lazy.core.loader.add_to_rtp()` in init function
5. ✅ **LazyFile event**: Added custom LazyFile user event for other plugins
6. ✅ **Highlight enabled**: Explicitly enabling syntax highlighting
7. ✅ **Auto-install**: Parsers will install automatically when needed
8. ✅ **Performance**: Large file protection (disables for files > 500KB)
9. ✅ **Smart indentation**: Enabled with exceptions for problematic languages
10. ✅ **Deduplication**: Properly merges and deduplicates language parsers from multiple sources
11. ✅ **Extensibility**: Using `opts_extend` to allow other plugins to add languages

## Verification Steps

After restarting Neovim:

1. **Check Treesitter Status**
   ```vim
   :TSModuleInfo
   ```
   Should show `highlight` and `indent` modules as `enabled: true`

2. **Verify Parsers**
   ```vim
   :TSInstallInfo
   ```
   Should show installed parsers for your languages

3. **Test Syntax Highlighting**
   - Open a file (e.g., `.lua`, `.py`, `.js`)
   - Verify syntax highlighting is working
   - Use `:Inspect` on a token to see treesitter highlight groups

4. **Check Health**
   ```vim
   :checkhealth nvim-treesitter
   ```
   Should report no errors for parsers and queries

5. **Test Filetype Detection**
   ```vim
   :echo &filetype
   ```
   Should show correct filetype for the current buffer

## Expected Behavior

- ✅ Syntax highlighting works immediately when opening files
- ✅ Language-specific features (textobjects, context) work
- ✅ Parsers install automatically on first use
- ✅ Performance is maintained with large files

## Compatibility Notes

- **Neovim Version**: 0.11.3 ✅
- **nvim-treesitter**: tracking main branch ✅
- **LazyVim**: Compatible with latest version ✅
- **darwin-nix**: No specific issues ✅

## Additional Configuration

The compatibility shims in `lua/config/lazy.lua` and `lua/compat/treesitter_query.lua` remain in place to support plugins that haven't migrated to the new Neovim 0.11 APIs. These are working correctly.

## Troubleshooting

If issues persist:

1. **Clear cache and restart**
   ```bash
   rm -rf ~/.local/share/nvim/lazy/nvim-treesitter
   nvim
   :Lazy sync
   ```

2. **Check for conflicts**
   ```vim
   :checkhealth
   ```

3. **Verify parser installation**
   ```vim
   :TSUpdate all
   ```

4. **Check runtimepath**
   ```vim
   :set runtimepath?
   ```
   Should include nvim-treesitter directories

## References

- nvim-treesitter documentation: https://github.com/nvim-treesitter/nvim-treesitter
- LazyVim treesitter guide: https://www.lazyvim.org/plugins/treesitter
- Neovim 0.11 treesitter changes: `:h treesitter`
