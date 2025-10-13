# Keymap Quick Reference

## Updated Keymaps After Conflict Resolution

### 🎯 Changed Mappings

| Function | Old Keymap | New Keymap | Notes |
|----------|-----------|------------|-------|
| **Format Buffer** | `<leader>f` | `<leader>lf` | Moved to LSP prefix |
| **Lazy Plugin Manager** | `<leader>l` | `<leader>L` | Freed up for LSP operations |
| **Replace Word** | `<leader>s` | `<leader>sR` | Moved to search prefix (capital R) |
| **Toggle Outline** | `<leader>a` | `<leader>o` | Freed up for Avante AI |
| **Swap Parameter Next** | `<leader>a` | `<leader>sa` | Moved to search prefix |
| **Swap Parameter Prev** | `<leader>A` | `<leader>sA` | Moved to search prefix |

---

## 🗂️ Organized Prefix Groups

### `<leader>f` - Find/File Operations
- `<leader>ff` - Find files
- `<leader>fg` - Find text (grep)
- `<leader>fb` - Find buffers
- `<leader>fh` - Find help
- `<leader>fr` - Recent files
- `<leader>fc` - Commands
- `<leader>fk` - Keymaps
- `<leader>fs` - Find symbols
- `<leader>fd` - Diagnostics
- `<leader>fy` - Clipboard history
- `<leader>fw` - Find word under cursor
- `<leader>fgb` - Git branches
- `<leader>fgf` - Git files
- `<leader>fgc` - Git commits
- `<leader>fgs` - Git status

### `<leader>l` - LSP Operations
- `<leader>lf` - **Format** (changed from `<leader>f`)
- `<leader>la` - Code action
- `<leader>lr` - Rename
- `<leader>ld` - Go to definition
- `<leader>lD` - Go to declaration
- `<leader>li` - Go to implementation
- `<leader>lt` - Go to type definition
- `<leader>lh` - Hover documentation
- `<leader>ls` - Signature help
- `<leader>lR` - Find references
- `<leader>ll` - Line diagnostics

### `<leader>g` - Git Operations
- `<leader>gg` - LazyGit
- `<leader>gl` - Git log
- `<leader>gb` - Toggle git blame
- `<leader>gd` - Git diff
- `<leader>gp` - Preview git hunk
- `<leader>gc` - LazyGit config
- `<leader>gf` - LazyGit current file

### `<leader>s` - Search/Replace Operations
- `<leader>sR` - **Replace word** (changed from `<leader>s`, capital R)
- `<leader>sr` - Replace surrounding (mini.surround)
- `<leader>sg` - Grep (root dir)
- `<leader>sw` - Visual selection/word
- `<leader>sa` - **Swap parameter next** (changed from `<leader>a`)
- `<leader>sA` - **Swap parameter previous** (changed from `<leader>A`)
- `<leader>sd` - Delete surrounding
- `<leader>sf` - Find surrounding
- `<leader>sh` - Highlight surrounding
- `<leader>st` - Todo
- `<leader>su` - Undotree
- `<leader>sp` - Search for plugin spec
- `<leader>sn*` - Noice operations

### `<leader>a` - Avante AI Operations
*Now conflict-free!*
- `<leader>aa` - Ask
- `<leader>ae` - Edit code suggestions
- `<leader>ac` - Add current buffer to context
- `<leader>af` - Focus
- `<leader>at` - Toggle
- `<leader>as` - Toggle suggestion
- `<leader>an` - Create new ask
- `<leader>ar` - Refresh
- `<leader>ap` - Switch AI provider
- `<leader>aw` - Web search
- `<leader>aT` - Tools menu
- Plus more...

### `<leader>o` - Outline Operations
- `<leader>o` - **Toggle outline** (changed from `<leader>a`)
- `<leader>os` - Toggle outline sidebar

### `<leader>b` - Buffer Operations
- `<leader>bb` - Browse buffers
- `<leader>bn` - Next buffer
- `<leader>bp` - Previous buffer
- `<leader>bx` - Close buffer

### `<leader>w` - Window Management
- `<leader>wv` - Split vertically
- `<leader>ws` - Split horizontally
- `<leader>we` - Make splits equal
- `<leader>wx` - Close split

### `<leader>t` - Tab Management
- `<leader>tn` - New tab
- `<leader>tx` - Close tab
- `<leader>tj` - Next tab
- `<leader>tk` - Previous tab
- `<leader>tf` - Move buffer to new tab
- `<leader>tt` - Search incomplete tasks
- `<leader>tc` - Search completed tasks

### `<leader>h` - Harpoon Marks
- `<leader>ha` - Add file
- `<leader>hh` - Show menu
- `<leader>h1-4` - Navigate to file 1-4
- `<leader>hp` - Previous mark
- `<leader>hn` - Next mark

### `<leader>e` - Explorer
- `<leader>e` - Toggle Neo-tree

### Other Important Keys
- `<leader>L` - **Lazy plugin manager** (changed from `<leader>l`)
- `<leader>ch` - Clear search highlights
- `<leader>+` - Increment number
- `<leader>-` - Decrement number
- `<leader><space>` - Find files (Snacks picker)
- `<M-k>` - Show keymaps picker
- `<M-b>` - Git branches
- `<S-h>` - Buffer picker

---

## 🔧 Verification Commands

After restarting Neovim, run:
```vim
:checkhealth which-key
```

Expected results:
- ✅ No duplicate mappings for `<leader>ua`
- ✅ Reduced prefix conflicts
- ⚠️ Normal overlaps only (g, gc, text objects - these are expected)

View all keymaps:
```vim
:Telescope keymaps
" or
<M-k>
```

---

## 📁 Files Modified

1. `lua/config/lazy.lua` - Disabled mini-animate import
2. `lua/plugins/conform.lua` - Removed `<leader>f` keymap
3. `lua/plugins/lazy-override.lua` - **NEW**: Override LazyVim defaults
4. `lua/config/keymaps.lua` - Removed `<leader>a` and `<leader>s` conflicts
5. `lua/plugins/treesitter.lua` - Changed swap keymaps to `<leader>sa/sA`

---

## 💡 Tips

1. **Formatting**: Use `<leader>lf` (LSP format) instead of old `<leader>f`
2. **Lazy Plugin Manager**: Now at `<leader>L` (uppercase) instead of `<leader>l`
3. **Outline/Aerial**: Use `<leader>o` instead of old `<leader>a`
4. **AI Operations**: `<leader>a*` is now exclusively for Avante AI
5. **Search/Replace Word**: Use `<leader>sR` (capital R) for word replacement
6. **Replace Surrounding**: Use `<leader>sr` (lowercase r) for surrounding text
7. **Swap Parameters**: Use `<leader>sa` (next) and `<leader>sA` (previous)

---

## 🎓 Prefix Philosophy

All keymaps now follow a consistent pattern:
- Direct prefix mappings are **avoided** when they have submappings
- Each major feature gets its own prefix
- Related operations stay together
- LazyVim compatibility maintained through overrides
