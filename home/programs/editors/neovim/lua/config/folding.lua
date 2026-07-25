-- Store which buffers should use LSP folding
local M = {}
local lsp_fold_buffers = {}
local current_method = {}

-- Check if treesitter is available for the current buffer
function M.has_treesitter()
  local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
  if not lang or lang == "" then
    return false
  end
  -- In 0.12, get_parser returns nil instead of throwing
  return vim.treesitter.get_parser(0, lang) ~= nil
end

-- Function to enable LSP folding for a buffer
function M.enable_lsp_folding(bufnr)
  lsp_fold_buffers[bufnr] = true
  vim.opt_local.foldmethod = "expr"
  vim.opt_local.foldexpr = "v:lua.vim.lsp.foldexpr()"

  vim.opt_local.foldtext = "v:lua.vim.lsp.foldtext()"

  -- Auto-fold imports after the server has had time to publish folding ranges.
  local clients = vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/foldingRange" })
  if #clients > 0 then
    local winid = vim.fn.bufwinid(bufnr)
    vim.defer_fn(function()
      if winid ~= -1 and vim.api.nvim_win_is_valid(winid) and vim.api.nvim_win_get_buf(winid) == bufnr then
        pcall(vim.lsp.foldclose, "imports", winid)
      end
    end, 200)
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
    vim.opt_local.foldtext = "v:lua.vim.lsp.foldtext()"
    current_method[bufnr] = "lsp"
    return
  end

  -- Try to use treesitter if available
  if M.has_treesitter() then
    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    current_method[bufnr] = "treesitter"
    return
  end

  -- Default to indent folding
  vim.opt_local.foldmethod = "indent"
  current_method[bufnr] = "indent"
end

-- Folding autocmds disabled — nvim-ufo handles fold management (see plugins/ufo.lua)
-- The utility functions above are kept available for manual use or statusline integration.

return M
