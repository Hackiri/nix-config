local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

-- Quick Exits and Navigation
map("i", "kj", "<ESC>", { desc = "Exit insert mode" })
map({ "n", "v" }, "<M-h>", "^", { desc = "Go to line start" })
map({ "n", "v" }, "<M-l>", "$", { desc = "Go to line end" })
map("v", "<M-l>", "$h", { desc = "Go to line end minus one" })

-- Quick Save & Quit
map("n", "<C-s>", "<cmd>w<CR>", { desc = "Save file" })
map("n", "<C-q>", "<cmd>q<CR>", { desc = "Quit file" })

-- Search Improvements
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })
map("n", "n", "nzzzv", { desc = "Next result and center" })
map("n", "N", "Nzzzv", { desc = "Previous result and center" })

-- Window Management (<leader>w prefix)
map("n", "<leader>wv", "<C-w>v", { desc = "Split window vertically" })
map("n", "<leader>ws", "<C-w>s", { desc = "Split window horizontally" })
map("n", "<leader>we", "<C-w>=", { desc = "Make splits equal size" })
map("n", "<leader>wx", "<cmd>close<CR>", { desc = "Close current split" })

-- Remove conflicting window movement keys (handled by vim-tmux-navigator)
-- map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
-- map("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
-- map("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
-- map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Tab Management (<leader>t prefix)
map("n", "<leader>tn", "<cmd>tabnew<CR>", { desc = "New tab" })
map("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close tab" })
map("n", "<leader>tj", "<cmd>tabn<CR>", { desc = "Next tab" })
map("n", "<leader>tk", "<cmd>tabp<CR>", { desc = "Previous tab" })
map("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Move buffer to new tab" })

-- fzf-lua (<leader>f prefix) - Override LazyVim defaults
-- Note: These keymaps load immediately to override LazyVim's Snacks picker defaults
-- The plugin config is in lua/plugins/fzf-lua.lua
map("n", "<leader>ff", "<cmd>FzfLua files<CR>", { desc = "Find Files" })
map("n", "<leader>fg", "<cmd>FzfLua live_grep<CR>", { desc = "Find Text (Live Grep)" })
map("n", "<leader>fw", "<cmd>FzfLua grep_cword<CR>", { desc = "Find Word Under Cursor" })
map("v", "<leader>fv", "<cmd>FzfLua grep_visual<CR>", { desc = "Find Visual Selection" })
map("n", "<leader>fh", "<cmd>FzfLua help_tags<CR>", { desc = "Find Help" })
map("n", "<leader>fo", "<cmd>FzfLua oldfiles<CR>", { desc = "Find Recent Files" })
map("n", "<leader>fb", "<cmd>FzfLua buffers<CR>", { desc = "Find Buffers" })
map("n", "<leader>fr", "<cmd>FzfLua resume<CR>", { desc = "Resume Last Search" })
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
map("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })
map("n", "<leader>bx", ":bdelete<CR>", { desc = "Close buffer" })

-- Quick Buffer Navigation
map("n", "<Tab>", ":bnext<CR>", { desc = "Next buffer" })
map("n", "<S-Tab>", ":bprevious<CR>", { desc = "Previous buffer" })

-- Diagnostics Navigation (LSP-independent)
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>dt", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle diagnostics" })

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
--   - File explorer: lua/plugins/neo-tree.lua
--   - Fuzzy finder: lua/plugins/fzf-lua.lua
--   - Git operations: lua/plugins/gitsigns.lua and lua/plugins/lazygit.lua
--   - LSP operations: lua/plugins/lsp.lua (in LspAttach autocmd)
--   - Harpoon marks: lua/plugins/harpoon.lua
--   - Aerial outline: lua/plugins/aerial.lua
map("n", "<leader>ch", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" }) -- Changed from <leader>h to <leader>ch
map("n", "<leader>+", "<C-a>", { desc = "Increment number" })
map("n", "<leader>-", "<C-x>", { desc = "Decrement number" })

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
