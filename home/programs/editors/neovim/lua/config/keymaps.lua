local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

-- Quick Exits and Navigation
map("i", "kj", "<ESC>", { desc = "Exit insert mode" })
map("n", "<M-h>", "^", { desc = "Go to line start" })
map("n", "<M-l>", "$", { desc = "Go to line end" })
-- Visual mode: go to line start/end (minus one for end to avoid newline)
map("v", "<M-h>", "^", { desc = "Go to line start" })
map("v", "<M-l>", "$h", { desc = "Go to line end (minus one)" })

-- Quick Save & Quit
map("n", "<C-s>", "<cmd>w<CR>", { desc = "Save file" })
map("n", "<C-q>", "<cmd>q<CR>", { desc = "Quit file" })

-- Search Improvements
-- Note: Auto-nohlsearch is handled by autocmds.lua (auto-nohl with search count)
map("n", "n", "nzzzv", { desc = "Next result and center" })
map("n", "N", "Nzzzv", { desc = "Previous result and center" })

-- Window Management (<leader>w prefix)
map("n", "<leader>wv", "<C-w>v", { desc = "Split window vertically" })
map("n", "<leader>ws", "<C-w>s", { desc = "Split window horizontally" })
map("n", "<leader>we", "<C-w>=", { desc = "Make splits equal size" })
map("n", "<leader>wx", "<cmd>close<CR>", { desc = "Close current split" })

-- Tab Management (<leader>t prefix)
map("n", "<leader>tn", "<cmd>tabnew<CR>", { desc = "New tab" })
map("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close tab" })
map("n", "<leader>tj", "<cmd>tabn<CR>", { desc = "Next tab" })
map("n", "<leader>tk", "<cmd>tabp<CR>", { desc = "Previous tab" })
map("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Move buffer to new tab" })

-- fzf-lua (<leader>f prefix) - Override LazyVim defaults
-- Note: These keymaps load immediately to override LazyVim's Snacks picker defaults
-- The plugin config is in lua/plugins/fzf-lua.lua
-- Using `nowait = true` on frequently-used mappings to reduce timeout lag
map("n", "<leader>ff", "<cmd>FzfLua files<CR>", { desc = "Find Files", nowait = true })
map("n", "<leader>fg", "<cmd>FzfLua live_grep<CR>", { desc = "Find Text (Live Grep)", nowait = true })
map("n", "<leader>fw", "<cmd>FzfLua grep_cword<CR>", { desc = "Find Word Under Cursor", nowait = true })
map("v", "<leader>fv", "<cmd>FzfLua grep_visual<CR>", { desc = "Find Visual Selection", nowait = true })
map("n", "<leader>fh", "<cmd>FzfLua help_tags<CR>", { desc = "Find Help", nowait = true })
map("n", "<leader>fo", "<cmd>FzfLua oldfiles<CR>", { desc = "Find Recent Files", nowait = true })
map("n", "<leader>fb", "<cmd>FzfLua buffers<CR>", { desc = "Find Buffers", nowait = true })
map("n", "<leader>fr", "<cmd>FzfLua resume<CR>", { desc = "Resume Last Search", nowait = true })
map("n", "<leader>fc", "<cmd>FzfLua commands<CR>", { desc = "Find Commands" })
map("n", "<leader>fk", "<cmd>FzfLua keymaps<CR>", { desc = "Find Keymaps" })
map("n", "<leader>fm", "<cmd>FzfLua marks<CR>", { desc = "Find Marks" })
map("n", "<leader>fj", "<cmd>FzfLua jumps<CR>", { desc = "Find Jump List" })
map("n", "<leader>fy", "<cmd>FzfLua registers<CR>", { desc = "Find Registers" })
map("n", "<leader>fz", "<cmd>FzfLua spell_suggest<CR>", { desc = "Spelling Suggestions" })
map("n", "<leader>f/", "<cmd>FzfLua blines<CR>", { desc = "Find in Current Buffer" })
map("n", "<leader>f?", "<cmd>FzfLua search_history<CR>", { desc = "Find Search History" })
map("n", "<leader>f:", "<cmd>FzfLua command_history<CR>", { desc = "Find Command History" })

-- fzf-lua Git (<leader>fg prefix)
map("n", "<leader>fgf", "<cmd>FzfLua git_files<CR>", { desc = "Find Git Files" })
map("n", "<leader>fgc", "<cmd>FzfLua git_commits<CR>", { desc = "Find Git Commits" })
map("n", "<leader>fgB", "<cmd>FzfLua git_bcommits<CR>", { desc = "Find Git Buffer Commits" })
map("n", "<leader>fgb", "<cmd>FzfLua git_branches<CR>", { desc = "Find Git Branches" })
map("n", "<leader>fgs", "<cmd>FzfLua git_status<CR>", { desc = "Find Git Status" })

-- fzf-lua LSP (<leader>f prefix)
map("n", "<leader>fR", "<cmd>FzfLua lsp_references<CR>", { desc = "Find References" })
map("n", "<leader>fd", "<cmd>FzfLua lsp_definitions<CR>", { desc = "Find Definitions" })
map("n", "<leader>fi", "<cmd>FzfLua lsp_implementations<CR>", { desc = "Find Implementations" })
map("n", "<leader>ft", "<cmd>FzfLua lsp_typedefs<CR>", { desc = "Find Type Definitions" })
map("n", "<leader>fs", "<cmd>FzfLua lsp_document_symbols<CR>", { desc = "Find Document Symbols" })
map("n", "<leader>fws", "<cmd>FzfLua lsp_workspace_symbols<CR>", { desc = "Find Workspace Symbols" })
map("n", "<leader>fwd", "<cmd>FzfLua diagnostics_workspace<CR>", { desc = "Find Workspace Diagnostics" })

-- Buffer Management
map("n", "<leader>bn", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bp", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<leader>bx", "<cmd>bdelete<CR>", { desc = "Close buffer" })

-- Quick Buffer Navigation
map("n", "<Tab>", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })

-- Neovim 0.11+ Default LSP Keymaps
-- Override the built-in gr* mappings to use FzfLua for better UI
-- These mappings are set by Neovim 0.11+ by default, but we override them here
map("n", "grn", vim.lsp.buf.rename, { desc = "LSP Rename" })
map("n", "grr", "<cmd>FzfLua lsp_references<cr>", { desc = "LSP References" })
map("n", "gri", "<cmd>FzfLua lsp_implementations<cr>", { desc = "LSP Implementations" })
map("n", "gra", vim.lsp.buf.code_action, { desc = "LSP Code Actions" })
map("n", "grt", "<cmd>FzfLua lsp_typedefs<cr>", { desc = "LSP Type Definition" })
map("n", "gO", "<cmd>FzfLua lsp_document_symbols<cr>", { desc = "LSP Document Symbols" })

-- Signature help in insert mode (Neovim 0.11+ default)
-- Using <C-k> instead of <C-s> to avoid terminal flow control (XOFF) conflicts
map("i", "<C-k>", vim.lsp.buf.signature_help, { desc = "LSP Signature Help" })

-- Diagnostics Navigation (LSP-independent)
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>dt", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle diagnostics" })

-- Toggle virtual text diagnostics mode (all lines vs current line only)
-- Neovim 0.11+ feature to reduce clutter
map("n", "<leader>dv", function()
  local current_config = vim.diagnostic.config()
  local current_virt_text = current_config.virtual_text

  if type(current_virt_text) == "table" and current_virt_text.only_current_line then
    -- Currently showing only current line, switch to all lines
    vim.diagnostic.config({
      virtual_text = vim.tbl_extend("force", current_virt_text, { only_current_line = false }),
    })
    vim.notify("Virtual text: All lines", vim.log.levels.INFO)
  else
    -- Currently showing all lines, switch to current line only
    local virt_text_config = type(current_virt_text) == "table" and current_virt_text or {}
    vim.diagnostic.config({
      virtual_text = vim.tbl_extend("force", virt_text_config, { only_current_line = true }),
    })
    vim.notify("Virtual text: Current line only", vim.log.levels.INFO)
  end
end, { desc = "Toggle virtual text mode (all/current line)" })

-- Trouble.nvim (<leader>x prefix for diagnostics/trouble)
map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Toggle Diagnostics (Trouble)" })
map(
  "n",
  "<leader>xX",
  "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
  { desc = "Toggle Buffer Diagnostics (Trouble)" }
)
map("n", "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", { desc = "Toggle Symbols (Trouble)" })
map(
  "n",
  "<leader>xl",
  "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
  { desc = "Toggle LSP References (Trouble)" }
)
map("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", { desc = "Toggle Location List (Trouble)" })
map("n", "<leader>xQ", "<cmd>Trouble quickfix toggle<cr>", { desc = "Toggle Quickfix List (Trouble)" })
map("n", "<leader>xr", "<cmd>Trouble lsp_references toggle<cr>", { desc = "Toggle LSP References (Trouble)" })
map("n", "<leader>xd", "<cmd>Trouble lsp_definitions toggle<cr>", { desc = "Toggle LSP Definitions (Trouble)" })
map("n", "<leader>xi", "<cmd>Trouble lsp_implementations toggle<cr>", { desc = "Toggle LSP Implementations (Trouble)" })
map(
  "n",
  "<leader>xt",
  "<cmd>Trouble lsp_type_definitions toggle<cr>",
  { desc = "Toggle LSP Type Definitions (Trouble)" }
)

-- Code Navigation and Editing
-- Note: Aerial outline toggle is now at <leader>o (defined in plugins/aerial.lua)
-- Removed <leader>a mapping to prevent conflict with Avante AI prefix
map("v", "<", "<gv", { desc = "Unindent line" })
map("v", ">", ">gv", { desc = "Indent line" })
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Better delete and yank
map("n", "x", '"_x', { desc = "Delete char without yank" })
map({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
map("n", "<leader>Y", '"+Y', { desc = "Yank line to system clipboard" })

-- Search and Replace Operations
-- Note: <leader>sr is "replace surrounding" (mini.surround), not search/replace
-- Using <leader>sR for search/replace word under cursor
map("n", "<leader>sR", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>\>/gI<Left><Left><Left>]], { desc = "Replace word under cursor" })

-- Misc Operations
-- Note: Plugin-specific keymaps are defined in their respective plugin files:
--   - File explorers: lua/plugins/snacks.lua, lua/plugins/mini-files.lua, lua/plugins/oil.lua
--   - Fuzzy finder: lua/plugins/fzf-lua.lua
--   - Git operations: lua/plugins/gitsigns.lua and lua/plugins/lazygit.lua
--   - LSP operations: lua/plugins/lsp.lua (in LspAttach autocmd)
--   - Harpoon marks: lua/plugins/harpoon.lua
--   - Aerial outline: lua/plugins/aerial.lua
-- Note: <leader>ch removed - auto-nohlsearch is handled by autocmds.lua

-- Improved scrolling
local scroll_percentage = 0.35
map("n", "<C-d>", function()
  local lines = math.floor(vim.api.nvim_win_get_height(0) * scroll_percentage)
  vim.cmd("normal! " .. lines .. "jzz")
end, { desc = "Scroll down" })

map("n", "<C-u>", function()
  local lines = math.floor(vim.api.nvim_win_get_height(0) * scroll_percentage)
  vim.cmd("normal! " .. lines .. "kzz")
end, { desc = "Scroll up" })

-- Alt-file navigation (from v12 config)
map({ "n", "x" }, "<leader>aa", function()
  require("personal-plugins.alt-alt").gotoAltFile()
end, { desc = "Navigate: Goto alt file" })

map({ "n", "x" }, "<leader>am", function()
  require("personal-plugins.alt-alt").gotoMostChangedFile()
end, { desc = "Navigate: Goto most changed file" })

-- Smart duplicate (from v12 config) - remapped to avoid DAP conflict
map({ "n", "v" }, "<leader>D", function()
  require("personal-plugins.misc").smartDuplicate()
end, { desc = "Edit: Smart duplicate" })

-- Toggle or increment (from v12 config) - remapped to avoid Snacks conflict
map("n", "<leader>tg", function()
  require("personal-plugins.misc").toggleOrIncrement()
end, { desc = "Edit: Toggle word or increment" })

-- Toggle case (from v12 config) - remapped to avoid Snacks conflict
map("n", "<leader>tC", function()
  require("personal-plugins.misc").toggleTitleCase()
end, { desc = "Edit: Toggle lower/Title case" })

-- LSP utilities (from v12 config)
map("n", "<leader>lc", function()
  require("personal-plugins.misc").lspCapabilities()
end, { desc = "LSP: Show capabilities" })

-- LSP rename camel/snake - remapped to avoid FZF references conflict
map("n", "<leader>lR", function()
  require("personal-plugins.misc").camelSnakeLspRename()
end, { desc = "LSP: Rename (camel/snake)" })

-- Buffer utilities (from v12 config)
map("n", "<leader>bi", function()
  require("personal-plugins.misc").inspectBuffer()
end, { desc = "Buffer: Inspect info" })

-- Sticky yank (from v12 config) - cursor doesn't move after yank
map({ "n", "x" }, "gy", function()
  vim.b.cursorPreYank = vim.api.nvim_win_get_cursor(0)
  return "y"
end, { expr = true, desc = "Yank (sticky - cursor stays)" })

-- Cyclic paste (from v12 config) - paste through deletion history with u.u.u.
map("n", "<leader>p", '"1p', { desc = "Paste: Cyclic paste from history" })

-- Note: TextYankPost autocmds consolidated in autocmds.lua (yank_utilities group)
