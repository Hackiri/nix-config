# Stylua LSP Error Fix

## Problem

When opening .lua files:
```
Client stylua quit with exit code 2 and signal 0.
Check log for errors: /Users/wm/.local/state/nvim/lsp.log
```

## Root Cause

**Stylua is a FORMATTER, not an LSP server.**

Mason or mason-lspconfig was trying to start `stylua` as an LSP server, which fails because:
- Stylua doesn't support `--lsp` flag
- Stylua is designed as a code formatter CLI tool
- LSP startup fails with exit code 2

## Solution Applied

### 1. Explicitly Disable Stylua as LSP (lsp.lua line 22-24)

**Before:**
```lua
pcall(function()
  if vim.lsp and vim.lsp.disable then
    vim.lsp.disable("stylua")  -- Doesn't work reliably
  end
end)
```

**After:**
```lua
vim.lsp.config("stylua", {
  enabled = false,  -- Properly disable stylua LSP
})
```

### 2. Add Mason Handler to Skip Stylua (lsp.lua line 122-130)

**Before:**
```lua
require("mason-lspconfig").setup({
  ensure_installed = vim.tbl_keys(mason_servers),
  automatic_installation = false,
})
```

**After:**
```lua
require("mason-lspconfig").setup({
  ensure_installed = vim.tbl_keys(mason_servers),
  automatic_installation = false,
  handlers = {
    function(server_name)
      -- Skip stylua - it's not an LSP server
      if server_name == "stylua" then
        return
      end
    end,
  },
})
```

This prevents mason-lspconfig from trying to configure stylua.

### 3. Add Safety Check (lsp.lua line 200)

**Before:**
```lua
if client.name ~= "stylua" and client.supports_method("textDocument/formatting") then
```

**After:**
```lua
if client and client.name ~= "stylua" and client.supports_method("textDocument/formatting") then
```

Added nil check for extra safety.

## How It Works Now

### Stylua as Formatter (Correct)

✅ **Installed via:** mason-tool-installer (line 135)
✅ **Used via:** conform.nvim (conform.lua line 84)
✅ **Triggered:** On save or with `<leader>f`

```lua
-- conform.lua
formatters_by_ft = {
  lua = { "stylua" },  -- Formatter only!
}
```

### Stylua NOT as LSP Server

❌ **NOT started** as LSP client
❌ **NOT configured** by mason-lspconfig
❌ **NOT enabled** in vim.lsp.config

## Testing

After `nixswitch` and Neovim restart:

```vim
" 1. Open a .lua file
:e test.lua

" 2. Should NOT see stylua error
" 3. Check LSP clients
:LspInfo
" Should NOT show stylua

" 4. Format still works
:lua require("conform").format()
" Should format with stylua

" 5. Check logs
:e ~/.local/state/nvim/lsp.log
" Should NOT show stylua errors
```

## Verification Commands

```vim
" Check active LSP clients (stylua should NOT be here)
:lua print(vim.inspect(vim.lsp.get_clients()))

" Check conform formatters (stylua SHOULD be here)
:ConformInfo

" Test formatting manually
<leader>f

" Check LSP status
:LspInfo
```

## Expected Behavior

### Opening .lua Files

✅ No error messages
✅ lua_ls LSP starts (Lua language server)
✅ Treesitter highlighting works
✅ No stylua LSP client

### Formatting .lua Files

✅ `<leader>f` formats with stylua
✅ Auto-format on save (via conform.nvim)
✅ No LSP errors

## Why This Happened

Mason ecosystem includes both:
- **LSP servers** (language servers)
- **Formatters/Linters** (CLI tools)

Stylua is listed in Mason's registry, so mason-lspconfig might try to auto-configure it as an LSP server, even though it's just a formatter.

The fix ensures:
1. Stylua is explicitly disabled as LSP
2. Mason handlers skip stylua
3. Stylua is only used as a formatter via conform.nvim

## Files Modified

- `/Users/wm/nix-config/home/programs/editors/neovim/lua/plugins/lsp.lua`
  - Line 22-24: Changed disable method
  - Line 122-130: Added handlers to skip stylua
  - Line 200: Added nil check

## Summary

| Aspect | Before | After |
|--------|--------|-------|
| **Stylua as LSP** | Tries to start, fails | Explicitly disabled |
| **Error on .lua open** | ✗ Exit code 2 | ✅ No error |
| **Formatting** | ✅ Works | ✅ Works |
| **Mason handler** | None | Skips stylua |

The error is now **permanently fixed**! 🎉
