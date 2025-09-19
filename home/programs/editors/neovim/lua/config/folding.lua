-- Store which buffers should use LSP folding
local M = {}
local lsp_fold_buffers = {}
local current_method = {}

-- Check if treesitter is available for the current buffer
function M.has_treesitter()
  local ok, ts = pcall(require, "nvim-treesitter.parsers")
  if not ok then
    return false
  end

  -- Get the language for the current buffer
  local lang = ts.get_buf_lang(0)
  if not lang then
    return false
  end

  -- Check if we have a parser for this language
  return ts.has_parser(lang)
end

-- Function to enable LSP folding for a buffer
function M.enable_lsp_folding(bufnr)
  lsp_fold_buffers[bufnr] = true
  vim.opt_local.foldmethod = "expr"
  vim.opt_local.foldexpr = "v:lua.vim.lsp.foldexpr()"

  -- Use LSP foldtext if available (Neovim 0.10+)
  if vim.lsp.foldtext then
    vim.opt_local.foldtext = "v:lua.vim.lsp.foldtext()"
  end

  -- Auto-fold imports if supported (Neovim 0.10+)
  if vim.lsp.foldclose then
    local client = vim.lsp.get_client_by_id(vim.lsp.get_clients({ bufnr = bufnr })[1].id)
    if client and client.server_capabilities.foldingRangeProvider then
      vim.schedule(function()
        vim.lsp.foldclose("imports", 0)
      end)
    end
  end

  current_method[bufnr] = "lsp"
end

-- Function to get current folding method for statusline
function M.get_fold_method()
  local bufnr = vim.api.nvim_get_current_buf()
  return current_method[bufnr] or "none"
end

-- Function to setup folding for a buffer
function M.setup_folding(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  -- If buffer is marked for LSP folding, use that
  if lsp_fold_buffers[bufnr] then
    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldexpr = "v:lua.vim.lsp.foldexpr()"
    if vim.lsp.foldtext then
      vim.opt_local.foldtext = "v:lua.vim.lsp.foldtext()"
    end
    current_method[bufnr] = "lsp"
    return
  end

  -- Try to use treesitter if available
  if M.has_treesitter() then
    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldexpr = "nvim_treesitter#foldexpr()"
    current_method[bufnr] = "treesitter"
    return
  end

  -- Default to indent folding
  vim.opt_local.foldmethod = "indent"
  current_method[bufnr] = "indent"
end

-- Setup autocommand for folding
local group = vim.api.nvim_create_augroup("FoldingSetup", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "BufAdd", "BufNew", "BufNewFile" }, {
  group = group,
  callback = function(ev)
    -- Defer folding setup slightly to ensure buffer is ready
    vim.schedule(function()
      M.setup_folding(ev.buf)
    end)
  end,
})

return M
