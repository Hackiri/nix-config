# Treesitter Language Loading and Status Display

## ✅ Configuration Applied

### 1. Language Loading System

Your Neovim now has **multiple layers** of language detection and loading:

#### Layer 1: Filetype Detection (Core)
Location: `/Users/wm/nix-config/home/programs/editors/neovim/lua/plugins/treesitter.lua` (lines 22-39)

```lua
local filetypes = {
  terraform = { "tf", "tfvars", "terraform" },
  groovy = { "pipeline", "Jenkinsfile", "groovy" },
  python = { "py", "pyi", "pyx", "pxd" },
  yaml = { "yaml", "yml" },
  dockerfile = { "Dockerfile", "dockerfile" },
  ruby = { "rb", "rake", "gemspec" },
  javascript = { "js", "jsx", "mjs" },
  typescript = { "ts", "tsx" },
  rust = { "rs", "rust" },
  nix = { "nix" },
}
```

**What it does**: Maps file extensions to filetypes automatically when you open a file.

#### Layer 2: Treesitter Highlighting Autocmd (treesitter.lua)
Location: `treesitter.lua` (lines 102-109)

```lua
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("TreesitterHighlight", { clear = true }),
  pattern = highlight_filetypes,  -- 30+ languages
  callback = function()
    vim.treesitter.start()  -- Starts treesitter for this buffer
  end,
})
```

**What it does**: When a FileType is detected, automatically starts treesitter highlighting.

**Languages covered**: lua, python, javascript, typescript, tsx, jsx, rust, go, java, c, cpp, ruby, php, html, css, scss, json, yaml, toml, bash, fish, markdown, vim, nix, terraform, dockerfile, sql, graphql, vue, svelte

#### Layer 3: Global Treesitter Fallback (autocmds.lua)
Location: `/Users/wm/nix-config/home/programs/editors/neovim/lua/config/autocmds.lua` (lines 202-212)

```lua
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("treesitter_start"),
  callback = function(ev)
    pcall(function()
      if not vim.treesitter.highlighter.active[ev.buf] then
        vim.treesitter.start(ev.buf)
      end
    end)
  end,
})
```

**What it does**: Fallback that tries to start treesitter for ANY FileType, even if not in the explicit list.

### 2. Statusline Language Indicator

**NEW**: Added to lualine configuration (lines 238-261)

```lua
{
  function()
    local buf = vim.api.nvim_get_current_buf()
    local ft = vim.bo[buf].filetype
    
    -- Check if treesitter is active
    local ts_active = vim.treesitter.highlighter.active[buf] ~= nil
    if ts_active then
      local lang = vim.treesitter.language.get_lang(ft) or ft
      return " " .. lang  -- Shows "󰘧 lua", "󰘧 python", etc.
    end
    
    return ""
  end,
  color = { fg = "#7aa2f7", gui = "bold" },
}
```

**What it shows**:
- ` lua` - Treesitter icon + language name
- Blue color, bold text
- Only shows when treesitter is **actively running**

### 3. Statusline Display

Your statusline now shows (left to right):

```
[Mode] [Git Branch] [Diagnostics] [Icon] [Filename] [󰘧 lua] [Navic] ...
                                                      ^^^^^^^
                                                   Language indicator!
```

## How It Works: Complete Flow

### When You Open a File

1. **File opened**: `nvim test.py`

2. **Extension detected**: `.py` → Neovim detects filetype

3. **Filetype set**: `filetype=python`

4. **FileType event fires**: Multiple autocmds trigger:
   - `TreesitterHighlight` autocmd: Starts treesitter for python
   - `treesitter_start` fallback: Ensures treesitter starts
   - Lualine updates: Language indicator appears

5. **Parser loads**: 
   - Checks: `~/.local/share/nvim/site/parser/python.so`
   - If exists: Loads and starts highlighting
   - If missing: Falls back to vim syntax or installs async

6. **Statusline updates**: Shows ` python` in blue

7. **Syntax highlighting**: Treesitter colors appear immediately

## Verification

### Check Language Detection

```vim
" 1. Open a file
:e test.lua

" 2. Check filetype
:set filetype?
" Should show: filetype=lua

" 3. Check if treesitter is active
:lua print(vim.treesitter.highlighter.active[0] ~= nil)
" Should show: true

" 4. Check parser language
:lua print(vim.treesitter.language.get_lang(vim.bo.filetype))
" Should show: lua

" 5. Check statusline
" Look at the statusline - should show: 󰘧 lua
```

### Test Different Languages

```bash
# Create test files
echo 'print("Hello")' > test.py
echo 'console.log("hi")' > test.js
echo 'fn main() {}' > test.rs

# Open each in Neovim
nvim test.py  # Should show 󰘧 python
nvim test.js  # Should show 󰘧 javascript
nvim test.rs  # Should show 󰘧 rust
```

## Debugging Language Loading

### Issue: Language not detected

**Check filetype**:
```vim
:set filetype?
```

If empty:
```vim
:filetype detect
```

### Issue: Treesitter not starting

**Check if parser exists**:
```vim
:lua print(vim.fn.filereadable(vim.fn.stdpath("data") .. "/site/parser/python.so"))
```

**Manually start treesitter**:
```vim
:lua vim.treesitter.start()
```

**Check for errors**:
```vim
:messages
```

### Issue: Language not showing in statusline

**Verify treesitter is active**:
```vim
:lua print(vim.inspect(vim.treesitter.highlighter.active))
```

Should show a table with buffer numbers as keys.

**Check lualine is loaded**:
```vim
:lua print(package.loaded["lualine"])
```

**Reload lualine**:
```vim
:Lazy reload lualine.nvim
```

## Adding More Languages

### Add to Filetype Detection

Edit `treesitter.lua`, add to the `filetypes` table:

```lua
local filetypes = {
  -- ... existing ...
  ocaml = { "ml", "mli", "ocaml" },
  elixir = { "ex", "exs" },
}
```

### Add to Highlighting List

Edit `treesitter.lua`, add to `highlight_filetypes`:

```lua
local highlight_filetypes = {
  -- ... existing ...
  "ocaml", "elixir",
}
```

### Install Parser

```vim
:TSInstall ocaml elixir
```

## Statusline Language Colors

You can customize the language indicator color in lualine config:

```lua
color = { fg = "#7aa2f7", gui = "bold" }, -- Blue
-- or
color = { fg = "#9ece6a", gui = "bold" }, -- Green  
color = { fg = "#bb9af7", gui = "bold" }, -- Purple
color = { fg = "#f7768e", gui = "bold" }, -- Red
```

## Complete Language List

Your configuration supports these languages with automatic loading:

### Web Development (9)
html, css, scss, javascript, typescript, tsx, jsx, vue, svelte

### Backend (11)
python, java, go, rust, ruby, php, c, cpp, c_sharp, kotlin, scala

### System/DevOps (9)
bash, fish, dockerfile, terraform, hcl, make, cmake, perl, awk

### Data/Config (6)
yaml, json, jsonc, toml, ini, sql

### Documentation (6)
markdown, markdown_inline, vim, vimdoc, rst, latex

### Version Control (5)
git_config, gitattributes, gitcommit, gitignore, diff

### Other (5)
nix, groovy, graphql, xml, proto

**Total**: 50+ languages

## Summary

### ✅ What's Working Now

1. **Automatic filetype detection** via file extension
2. **Automatic treesitter loading** via FileType autocmds
3. **Statusline language indicator** showing active language
4. **Fallback loading** ensures treesitter starts even for unlisted languages
5. **Visual feedback** - blue ` language` indicator when active

### Next Steps

1. **Restart Neovim** to apply lualine changes
2. **Run `:Lazy sync`** to ensure all plugins are updated
3. **Open a test file** and verify the language indicator appears
4. **Check `:TSInstallInfo`** to see installed parsers

The language will now load automatically when you open any supported file, and the statusline will clearly show which language is active!
