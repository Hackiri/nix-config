local M = {}

local skip_filetypes = {
  DiffviewFiles = true,
  fugitive = true,
  git = true,
}

local skip_buftypes = {
  nofile = true,
  prompt = true,
  quickfix = true,
  terminal = true,
}

local function should_skip(bufnr)
  local filetype = vim.bo[bufnr].filetype
  local buftype = vim.bo[bufnr].buftype
  local name = vim.api.nvim_buf_get_name(bufnr)

  return skip_filetypes[filetype] or skip_buftypes[buftype] or name:match("^diffview:") or name:match("^fugitive:")
end

local function map(bufnr, mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, {
    buffer = bufnr,
    silent = true,
    desc = desc,
  })
end

local function conform_format(bufnr)
  require("conform").format({
    bufnr = bufnr,
    async = true,
    lsp_format = "never",
  })
end

local function lsp_format(bufnr)
  vim.lsp.buf.format({
    bufnr = bufnr,
    async = true,
  })
end

function M.setup_gq(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) or should_skip(bufnr) then
    return
  end

  map(bufnr, { "n", "x" }, "gQ", function()
    conform_format(bufnr)
  end, "format with conform")

  local has_lsp_format = false
  local has_lsp_range_format = false

  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if client:supports_method("textDocument/formatting", { bufnr = bufnr }) then
      has_lsp_format = true
    end

    if client:supports_method("textDocument/rangeFormatting", { bufnr = bufnr }) then
      has_lsp_range_format = true
    end
  end

  map(bufnr, "n", "gq", function()
    if has_lsp_format then
      lsp_format(bufnr)
    else
      conform_format(bufnr)
    end
  end, has_lsp_format and "format with LSP" or "format with conform")

  map(bufnr, "x", "gq", function()
    if has_lsp_range_format then
      lsp_format(bufnr)
    else
      conform_format(bufnr)
    end
  end, has_lsp_range_format and "format range with LSP" or "format range with conform")
end

function M.setup()
  vim.api.nvim_create_autocmd({ "FileType", "LspAttach" }, {
    group = vim.api.nvim_create_augroup("user_gq_formatting", { clear = true }),
    desc = "Prefer LSP formatting for gq and keep conform on gQ",
    callback = function(args)
      M.setup_gq(args.buf)
    end,
  })
end

return M
