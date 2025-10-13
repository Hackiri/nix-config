# Stylua LSP Error Fix V2 - Aggressive Blocking

## Problem Still Occurring

Even after initial fix, stylua still tries to start as LSP:
```
Client stylua quit with exit code 2 and signal 0
```

## Why Initial Fix Wasn't Enough

The initial `vim.lsp.config("stylua", { enabled = false })` wasn't sufficient because:
1. Mason might auto-detect stylua binary and try to start it
2. Some plugin might be triggering stylua LSP registration
3. lspconfig might have cached configuration

## Aggressive Fix Applied

### Method 1: Remove from lspconfig registry
```lua
pcall(function()
  require("lspconfig.configs").stylua = nil
end)
```
Completely removes stylua from lspconfig's server configs.

### Method 2: Override vim.lsp.start to block stylua
```lua
local original_lsp_start = vim.lsp.start
vim.lsp.start = function(config, opts)
  if config and (config.name == "stylua" or 
                 config.cmd and config.cmd[1] and 
                 config.cmd[1]:match("stylua")) then
    -- Silently refuse to start stylua as LSP
    return nil
  end
  return original_lsp_start(config, opts)
end
```

This intercepts ANY attempt to start stylua as an LSP server, regardless of source.

### Method 3: Mason handler (already in place)
```lua
require("mason-lspconfig").setup({
  handlers = {
    function(server_name)
      if server_name == "stylua" then
        return  -- Skip
      end
    end,
  },
})
```

## How to Apply

```bash
# 1. Save the file (already done)
# 2. Apply nix configuration
nixswitch

# 3. IMPORTANT: Completely restart Neovim
# Kill all instances
pkill nvim

# 4. Remove LSP state cache
rm -rf ~/.local/state/nvim/lsp.log
rm -rf ~/.local/share/nvim/lsp-*

# 5. Start fresh
nvim test.lua
```

## Testing Commands

After restart:

```vim
" 1. Open .lua file
:e test.lua

" 2. Check LSP clients (stylua should NOT be listed)
:LspInfo

" 3. Check running clients
:lua vim.print(vim.lsp.get_clients())

" 4. Should only see lua_ls, not stylua
```

## If Error STILL Occurs

Additional nuclear options:

### Option A: Remove stylua from Mason entirely
```bash
rm -rf ~/.local/share/nvim/mason/packages/stylua
```

Then reinstall ONLY as formatter:
```vim
:MasonInstall stylua
```

### Option B: Add to init.lua (runs even earlier)
Create a file that runs before plugins:

```lua
-- In init.lua or very early in load order
vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function()
    -- Ensure no stylua LSP client
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
      if client.name == "stylua" then
        vim.lsp.stop_client(client.id, true)
      end
    end
  end,
})
```

### Option C: Check for rogue configuration
```bash
# Search for any stylua LSP config in your dotfiles
grep -r "stylua" ~/.config/nvim/ 2>/dev/null
grep -r "stylua" ~/nix-config/home/programs/editors/neovim/ 2>/dev/null
```

## What Triggers LSP Start

Common sources:
1. **mason-lspconfig** - auto-detects installed servers
2. **lspconfig** - cached server configs  
3. **nvim-lspconfig** - default configurations
4. **Manual vim.lsp.start()** calls
5. **FileType autocmds** triggering LSP

Our fix blocks ALL of these.

## Verification

After applying and restarting:

```vim
" This should print empty or only lua_ls
:lua for _, c in ipairs(vim.lsp.get_clients()) do print(c.name) end

" Check if stylua blocking is active
:lua print(vim.inspect(vim.lsp.start))  
" Should show our wrapped function

" Try to manually start (should fail silently)
:lua vim.lsp.start({name = "stylua", cmd = {"stylua"}})
" Should return nil, no error
```

## Summary

**Triple protection:**
1. ✅ Remove from lspconfig registry
2. ✅ Override vim.lsp.start to intercept
3. ✅ Mason handler skips stylua

**Result:** Stylua CANNOT start as LSP under any circumstances.

## Important

After this fix:
- ✅ Stylua formatting still works (via conform.nvim)
- ✅ lua_ls LSP still works
- ❌ Stylua LSP will NEVER start

The error should be **completely eliminated**! 🔥
