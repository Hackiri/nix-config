-- Compatibility shim for Neovim 0.11+ to support plugins that still
-- `require("nvim-treesitter.query")`. Prefer the native
-- `vim.treesitter.query` API and fall back gracefully.
-- Safe to remove once all plugins migrate.

local M = {}

local q = nil
local ok = pcall(function()
  q = vim.treesitter and vim.treesitter.query or nil
end)

if not ok or type(q) ~= "table" then
  -- last resort: try nvim-treesitter's internal ts_query module
  local ok_tsq, tsq = pcall(require, "nvim-treesitter.ts_query")
  if ok_tsq then
    q = tsq
  else
    q = {}
  end
end

-- get_query(lang, name): old API
function M.get_query(lang, name)
  if q.get_query then
    return q.get_query(lang, name)
  end
  if q.get then
    return q.get(lang, name)
  end
  return nil
end

-- get(lang, name): new API – expose for callers that expect it on this module
function M.get(lang, name)
  if q.get then
    return q.get(lang, name)
  end
  if q.get_query then
    return q.get_query(lang, name)
  end
  return nil
end

-- get_files(lang, name, is_included?) – used by some plugins
function M.get_files(lang, name, is_included)
  if q.get_files then
    return q.get_files(lang, name, is_included)
  end
  return {}
end

-- parse(lang, query_string)
function M.parse(lang, query_string)
  if q.parse then
    return q.parse(lang, query_string)
  end
  return nil
end

-- Provide get_node_text via the modern API, with a fallback
local function _get_node_text(node, bufnr)
  if vim.treesitter and vim.treesitter.get_node_text then
    return vim.treesitter.get_node_text(node, bufnr)
  end
  local ok_ts_utils, ts_utils = pcall(require, "nvim-treesitter.ts_utils")
  if ok_ts_utils and ts_utils.get_node_text then
    return ts_utils.get_node_text(node, bufnr)
  end
  return ""
end

M.get_node_text = _get_node_text

return M
