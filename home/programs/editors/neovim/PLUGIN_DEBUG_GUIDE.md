# Plugin Debug Guide - Identify Hanging Plugin

## Essential Plugins (Keep These)

These are core LazyVim dependencies that should NOT be removed:

1. **LazyVim Core:**
   - `lazy.lua` or `config/lazy.lua` - Plugin manager bootstrap
   - `lsp.lua` - LSP configuration
   - `mason.lua` - LSP/tool installer

2. **Completion:**
   - `blink-cmp.lua` - Completion engine (LazyVim 14.x+ default)

3. **UI Essentials:**
   - `noice.lua` - Command line UI
   - `which-key.lua` - Keymap helper

4. **Colorscheme:**
   - One colorscheme file from `colorschemes/` directory

## Likely Culprits (Test These First)

### High Risk - Remove/Disable First:

1. **`treesitter.lua`** ⚠️ HIGH RISK
   - Already identified as causing hangs
   - Disable completely for now

2. **`conform.lua`** ⚠️ MEDIUM RISK
   - Auto-format on BufLeave can hang
   - Has LazyVim dependency

3. **`copilot.lua`** / **`avante.lua`** ⚠️ MEDIUM RISK
   - AI plugins can hang waiting for network
   - Require authentication

4. **`lazygit.lua`** ⚠️ LOW-MEDIUM RISK
   - Requires lazygit binary installed
   - Git operations can be slow

5. **`neo-tree.lua`** / **`oil.lua`** / **`yazi.lua`** ⚠️ LOW RISK
   - File explorers can hang on large directories
   - Usually only when opened

6. **`dap.lua`** / **`debug.lua`** ⚠️ LOW RISK
   - Debugger setup can be slow
   - Usually lazy-loaded

## Safe Plugins (Low Risk)

These typically don't cause hangs:
- `flash.lua` - Motion plugin
- `gitsigns.lua` - Git signs (lazy-loaded)
- `mini-*.lua` - Mini plugins (usually fast)
- `bufferline.lua` - Buffer tabs
- `lualine.lua` - Status line
- `comment.lua` - Commenting
- `dial.lua` - Increment/decrement
- `inc-rename.lua` - LSP rename
- `zen-mode.lua` - Distraction-free mode
- `colorscheme.lua` - Theme selector

## Debugging Process

### Step 1: Create Minimal Config

```bash
# Backup current plugins
cd /Users/wm/nix-config/home/programs/editors/neovim/lua/plugins
mkdir -p ../plugins-backup
cp *.lua ../plugins-backup/
cp -r colorschemes ../plugins-backup/

# Keep only essential plugins
mkdir -p ../plugins-minimal
```

### Step 2: Start with Absolute Minimum

Keep ONLY these files:
```
plugins/
├── colorschemes/
│   └── nightfox.lua (or your preferred theme)
└── (empty - no other plugins)
```

Test: `nvim`
- If it works → plugins are the issue
- If it hangs → issue is in config/ directory

### Step 3: Add Plugins One by One

Add in this order (test after each):

1. `lsp.lua` - Test: `nvim test.lua`
2. `mason.lua` - Test: `:Mason`
3. `blink-cmp.lua` - Test: Type something, see completion
4. `which-key.lua` - Test: Press `<space>` see menu
5. `noice.lua` - Test: Run `:messages`
6. `lualine.lua` - Test: See status line
7. `bufferline.lua` - Test: Open multiple files

If any plugin causes a hang, that's your culprit!

### Step 4: Test Suspected Plugins

Once core works, test high-risk plugins:

1. `treesitter.lua` - Already disabled auto-install
2. `conform.lua` - Has VeryLazy wrapper
3. `copilot.lua` - Requires network
4. `fzf-lua.lua` - File finder

## Quick Disable Method

To temporarily disable a plugin without deleting:

```lua
-- At the top of any plugin file, add:
return {} -- DISABLED FOR TESTING

-- Original config below...
```

## Commands to Test After Each Plugin

```vim
:checkhealth
:Lazy
:messages
:LspInfo
```

## Common Hang Patterns

### Pattern 1: Hangs on Startup
**Cause:** Plugin loading in `init` or `config` function  
**Culprits:** treesitter, conform, copilot

### Pattern 2: Hangs When Opening File
**Cause:** FileType autocmd or LSP attach  
**Culprits:** treesitter, LSP, conform

### Pattern 3: Hangs When Switching Buffers
**Cause:** BufLeave/BufEnter autocmd  
**Culprits:** conform, auto-save plugins

### Pattern 4: Hangs After Idle
**Cause:** CursorHold autocmd  
**Culprits:** LSP diagnostics, git plugins

## Nuclear Option - Fresh Start

If nothing works:

```bash
# Remove ALL Neovim data
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim

# Start with minimal config
nvim
```

## Report Back

After testing, note:
1. Which plugins were removed when it started working?
2. Which plugin caused the hang when added back?
3. Any error messages in `:messages`?
