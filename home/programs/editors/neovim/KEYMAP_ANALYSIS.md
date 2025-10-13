# Neovim Keymap Analysis

## Summary
Analysis of keymap conflicts and overlaps from `:checkhealth which-key` output.

---

## 🚨 Critical Issues

### 1. Duplicate Mapping: `<leader>ua`
**Status**: ❌ Needs fixing
**Location**: LazyVim extras (mini-animate)
**Issue**: Two identical mappings for "Disable Animations"
- Mapping 1: Disable Mini Animate
- Mapping 2: Disable Animations

**Solution**: Remove the mini-animate extra import from `lua/config/lazy.lua` line 375, or disable one of the duplicate keymaps.

---

## ⚠️ Prefix Conflicts (High Priority)

These are the most problematic conflicts where a direct mapping interferes with a prefix group:

### 2. `<leader>f` Conflict
**Status**: ⚠️ Problematic
**Files**:
- `lua/plugins/conform.lua:38` - Direct mapping to "Format buffer"
- `lua/config/keymaps.lua:37-47` - Prefix for Find/File operations

**Problem**: Pressing `<leader>f` immediately triggers formatting instead of waiting for the next key (e.g., `ff`, `fg`, `fb`). This creates a delay when trying to use any `<leader>f*` commands.

**Recommended Fix**: Move format mapping to a different key
```lua
-- Option 1: Use a different prefix
map("n", "<leader>cf", vim.lsp.buf.format, { desc = "Format" })

-- Option 2: Use existing LSP prefix (most consistent)
-- Already have <leader>lf defined in keymaps.lua, so remove the <leader>f mapping
```

### 3. `<leader>l` Conflict
**Status**: ⚠️ Problematic  
**Source**: LazyVim default (shows "Lazy" plugin manager)
**Conflicts with**: All LSP operations (`<leader>l*` in `lua/config/keymaps.lua:68-79`)

**Problem**: Opening the Lazy plugin manager interferes with LSP keymaps.

**Recommended Fix**: Disable LazyVim's default `<leader>l` mapping
```lua
-- In lua/config/lazy.lua or a plugin override:
{
  "folke/lazy.nvim",
  keys = {
    { "<leader>l", false }, -- Disable default Lazy keymap
    { "<leader>L", "<cmd>Lazy<cr>", desc = "Lazy Plugin Manager" }, -- Use uppercase instead
  },
}
```

### 4. `<leader>e` Conflict
**Status**: ✅ Already handled  
**Files**: 
- `lua/plugins/snacks.lua:18` - Explicitly disabled with `{ "<leader>e", false }`
- `lua/config/keymaps.lua:35` - Used for Neo-tree toggle

**Note**: This is correctly handled; the snacks mapping is disabled to prevent conflicts.

### 5. `<leader>a` Conflict
**Status**: ⚠️ Moderate
**Files**:
- `lua/config/keymaps.lua:84` - Direct mapping to "Toggle code outline"
- Multiple Avante AI mappings use `<leader>a*` prefix

**Problem**: Direct `<leader>a` mapping creates delay for Avante commands.

**Recommended Fix**: 
```lua
-- Option 1: Use a different key for aerial toggle
map("n", "<leader>o", "<cmd>AerialToggle<CR>", { desc = "Toggle code outline" })

-- Option 2: Keep <leader>a for Avante, use <leader>oa for aerial
map("n", "<leader>oa", "<cmd>AerialToggle<CR>", { desc = "Toggle code outline" })
```

### 6. `<leader>s` Conflict  
**Status**: ⚠️ Moderate
**Files**:
- `lua/config/keymaps.lua:89` - Direct mapping to "Replace word under cursor"
- Many search operations use `<leader>s*` prefix

**Problem**: The direct mapping for search/replace interferes with the search prefix.

**Recommended Fix**:
```lua
-- Move to a more specific key under the same prefix
map("n", "<leader>sr", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>\>/gI<Left><Left><Left>]], 
  { desc = "Replace word under cursor" })
-- Note: This already exists as <leader>sr in the search prefix
-- Simply remove the direct <leader>s mapping
```

### 7. `<leader>o` Conflict
**Status**: ⚠️ Minor
**Currently**: Direct mapping to "Toggle outline"
**Conflicts with**: `<leader>os` (Toggle outline sidebar)

**Recommended Fix**: This is less problematic since there are only 2 mappings. Consider keeping as-is or consolidating to one outline toggle command.

---

## ℹ️ Normal Overlaps (No Action Needed)

These are expected vim behavior and not actual conflicts:

### Single Key Prefixes
- `<g>` with `gs`, `gx`, `gc`, etc. - **Normal**: g is a prefix key in vim
- `<gc>` with `gcc`, `gco`, `gcO` - **Normal**: Comment plugin prefix
- `<\>` with `<\\>`, `<\\gS>` - **Normal**: Backslash is a prefix

### Text Objects
- `<a>` with `ai`, `a%`, `an`, `al` - **Normal**: "around" text object
- `<i>` with `ii`, `in`, `il` - **Normal**: "inside" text object

### Sub-prefixes (Already in Same Group)
These are all properly organized under parent prefixes:
- `<leader>fw` (Find Word) with `<leader>fwd`, `<leader>fws` ✅
- `<leader>fg` (Find Git) with `<leader>fgb`, `<leader>fgf`, etc. ✅
- `<leader>sd`, `<leader>sr`, `<leader>sf`, `<leader>sh`, `<leader>sF` with their `l`/`n` variants ✅
- `<leader>sn` (Noice) with multiple sub-commands ✅
- `<leader>dp` (Debug Profile) with sub-commands ✅

---

## 📋 Actions Taken

### ✅ Fixed Issues

1. **Removed duplicate `<leader>ua`**: 
   - **File**: `lua/config/lazy.lua:375-376`
   - **Action**: Commented out mini-animate import
   ```lua
   -- { import = "lazyvim.plugins.extras.ui.mini-animate" },
   ```

2. **Fixed `<leader>f` conflict**:
   - **File**: `lua/plugins/conform.lua:36-39`
   - **Action**: Removed direct `<leader>f` mapping
   - **Alternative**: Use `<leader>lf` instead (already exists in keymaps.lua)

3. **Fixed `<leader>l` conflict**:
   - **File**: `lua/plugins/lazy-override.lua` (NEW FILE)
   - **Action**: Created override to disable LazyVim's default `<leader>l`
   - **New mapping**: `<leader>L` opens Lazy plugin manager

4. **Fixed `<leader>s` conflict**:
   - **File**: `lua/config/keymaps.lua:91-94`
   - **Action**: Moved direct `<leader>s` to `<leader>sR` (capital R)
   - **Note**: `<leader>sr` (lowercase) is for "replace surrounding" (mini.surround)

5. **Fixed `<leader>a` conflicts**:
   - **File**: `lua/config/keymaps.lua:84-85`
   - **Action**: Removed `<leader>a` aerial toggle mapping
   - **Note**: Aerial already has `<leader>o` in `plugins/aerial.lua`
   - **File**: `lua/plugins/treesitter.lua:386-390`
   - **Action**: Changed treesitter swap from `<leader>a` to `<leader>sa`
   - **Keeps**: `<leader>a*` prefix exclusively for Avante AI operations

### 📝 Summary of Changes

| Old Mapping | New Mapping | Reason |
|------------|-------------|---------|
| `<leader>f` (format) | Use `<leader>lf` | Conflicts with find/file prefix |
| `<leader>l` (Lazy) | `<leader>L` | Conflicts with LSP operations |
| `<leader>s` (replace) | `<leader>sR` | Conflicts with search prefix |
| `<leader>a` (aerial) | Use `<leader>o` | Conflicts with Avante AI prefix |
| `<leader>a` (swap params) | `<leader>sa` | Conflicts with Avante AI prefix |
| `<leader>ua` duplicate | Removed | Duplicate mapping from mini-animate |

---

## 🔍 Testing Recommendations

After making changes, run:
```vim
:checkhealth which-key
```

And verify:
- ✅ No duplicate mappings remain
- ✅ Major prefix conflicts are resolved
- ✅ All keymaps still work as expected

You can also test keymap behavior:
```vim
:Telescope keymaps
```
or
```vim
<M-k>  " Your custom keymap picker
```

---

## 📝 Implementation Notes

When fixing these conflicts, keep in mind:

1. **LazyVim Integration**: Some mappings come from LazyVim defaults. Override them in your config rather than trying to edit LazyVim source files.

2. **Lazy Loading**: Some keymaps are defined in plugin specs with the `keys` property, which handles lazy loading. Maintain this pattern.

3. **Consistency**: Try to keep related operations under the same prefix:
   - `<leader>f*` for finding/files
   - `<leader>l*` for LSP operations
   - `<leader>g*` for git operations
   - `<leader>s*` for search/replace operations
   - `<leader>a*` for AI/Avante operations

4. **Documentation**: Update descriptions to be clear and consistent with existing patterns.
