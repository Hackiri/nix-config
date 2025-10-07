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

-- File Explorer and Search (<leader>e, <leader>f prefix)
map("n", "<leader>e", "<cmd>Neotree toggle<CR>", { desc = "Toggle file explorer" })

-- Telescope (<leader>f prefix)
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Find text" })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Find buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "Find help" })
map("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>", { desc = "Recent files" })
map("n", "<leader>fc", "<cmd>Telescope commands<CR>", { desc = "Commands" })
map("n", "<leader>fk", "<cmd>Telescope keymaps<CR>", { desc = "Keymaps" })
map("n", "<leader>fs", "<cmd>Telescope lsp_document_symbols<CR>", { desc = "Find symbols" })
map("n", "<leader>fd", "<cmd>Telescope diagnostics<CR>", { desc = "Diagnostics" })
map("n", "<leader>fy", "<cmd>Telescope neoclip<CR>", { desc = "Clipboard history" })

-- Buffer Management (<leader>b prefix)
map("n", "<leader>bb", function()
  require("telescope.builtin").buffers(require("telescope.themes").get_ivy({
    sort_mru = true,
    sort_lastused = true,
    initial_mode = "normal",
    layout_config = { preview_width = 0.45 },
  }))
end, { desc = "Browse buffers" })
map("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })
map("n", "<leader>bx", ":bdelete<CR>", { desc = "Close buffer" })

-- Quick Buffer Navigation
map("n", "<Tab>", ":bnext<CR>", { desc = "Next buffer" })
map("n", "<S-Tab>", ":bprevious<CR>", { desc = "Previous buffer" })

-- Git Operations (<leader>g prefix)
map("n", "<leader>gg", "<cmd>LazyGit<CR>", { desc = "LazyGit" })
map("n", "<leader>gb", "<cmd>Gitsigns toggle_current_line_blame<CR>", { desc = "Toggle git blame" })
map("n", "<leader>gd", "<cmd>Gitsigns diffthis<CR>", { desc = "Git diff" })
map("n", "<leader>gp", "<cmd>Gitsigns preview_hunk<CR>", { desc = "Preview git hunk" })

-- LSP Operations (<leader>l prefix)
map("n", "<leader>lf", vim.lsp.buf.format, { desc = "Format" })
map("n", "<leader>la", vim.lsp.buf.code_action, { desc = "Code action" })
map("n", "<leader>lr", vim.lsp.buf.rename, { desc = "Rename" })
map("n", "<leader>ld", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "<leader>lD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
map("n", "<leader>li", vim.lsp.buf.implementation, { desc = "Go to implementation" })
map("n", "<leader>lt", vim.lsp.buf.type_definition, { desc = "Go to type definition" })
map("n", "<leader>lh", vim.lsp.buf.hover, { desc = "Hover documentation" })
map("n", "<leader>ls", vim.lsp.buf.signature_help, { desc = "Signature help" })
map("n", "<leader>lR", vim.lsp.buf.references, { desc = "Find references" })
map("n", "<leader>ll", vim.diagnostic.open_float, { desc = "Line diagnostics" })
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

-- Harpoon Marks (<leader>h prefix)
map("n", "<leader>ha", function()
  require("harpoon"):list():add()
end, { desc = "Add file to harpoon" })

map("n", "<leader>hh", function()
  local harpoon = require("harpoon")
  harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = "Show harpoon menu" })

map("n", "<leader>h1", function()
  require("harpoon"):list():select(1)
end, { desc = "Navigate to file 1" })

map("n", "<leader>h2", function()
  require("harpoon"):list():select(2)
end, { desc = "Navigate to file 2" })

map("n", "<leader>h3", function()
  require("harpoon"):list():select(3)
end, { desc = "Navigate to file 3" })

map("n", "<leader>h4", function()
  require("harpoon"):list():select(4)
end, { desc = "Navigate to file 4" })

map("n", "<leader>hp", function()
  require("harpoon"):list():prev()
end, { desc = "Navigate to previous mark" })

map("n", "<leader>hn", function()
  require("harpoon"):list():next()
end, { desc = "Navigate to next mark" })

-- Misc Operations
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
