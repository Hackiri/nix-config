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

  -- Use LSP foldtext if available (Neovim 0.10+)
  if vim.lsp.foldtext then
    vim.opt_local.foldtext = "v:lua.vim.lsp.foldtext()"
  end

  -- Auto-fold imports if supported (Neovim 0.10+)
  if vim.lsp.foldclose then
    local clients = vim.lsp.get_clients({ bufnr = bufnr })
    if clients and #clients > 0 then
      local client = vim.lsp.get_client_by_id(clients[1].id)
      if client and client.server_capabilities.foldingRangeProvider then
        -- Delay fold close to ensure LSP has sent folding ranges
        vim.defer_fn(function()
          -- Gracefully handle case where folds don't exist yet
          pcall(function()
            vim.lsp.foldclose("imports", bufnr)
          end)
        end, 200) -- Wait 200ms for LSP to provide folding ranges
      end
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

-- Folding autocmds disabled — nvim-ufo handles fold management (see plugins/ufo.lua)
-- The utility functions above are kept available for manual use or statusline integration.

return M
