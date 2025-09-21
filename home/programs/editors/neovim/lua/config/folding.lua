-- Store which buffers should use LSP folding
local M = {}
local lsp_fold_buffers = {}
local current_method = {}

-- Check if treesitter is available for the current buffer
function M.has_treesitter()
  local ok, parsers = pcall(require, "nvim-treesitter.parsers")
  if not ok or type(parsers) ~= "table" then
    return false
  end

  -- Determine the buffer language safely across versions
  local lang
  local ok_lang, res = pcall(function()
    if type(parsers.get_buf_lang) == "function" then
      return parsers.get_buf_lang(0)
    end
    -- Fallback: derive from filetype
    local ft = vim.bo.filetype
    if type(parsers.ft_to_lang) == "function" then
      return parsers.ft_to_lang(ft)
    end
    return ft
  end)
  lang = ok_lang and res or nil
  if not lang or lang == "" then
    return false
  end

  -- Check parser availability guards
  if type(parsers.has_parser) == "function" then
    local ok_has, has = pcall(parsers.has_parser, lang)
    return ok_has and has or false
  end
  if type(parsers.get_parser) == "function" then
    local ok_get = pcall(parsers.get_parser, 0, lang)
    return ok_get
  end
  return false
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
    -- Prefer the new API available on modern Neovim
    if vim.treesitter and type(vim.treesitter.foldexpr) == "function" then
      vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    else
      -- Fallback to legacy expr if present
      vim.opt_local.foldexpr = "nvim_treesitter#foldexpr()"
    end
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
