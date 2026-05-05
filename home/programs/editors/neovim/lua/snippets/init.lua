local M = {}

local configured = false
local loaded_modules = {}

local snippet_modules = {
  -- Programming languages
  { filetypes = { "markdown" }, module = "snippets.markdown" },
  { filetypes = { "python" }, module = "snippets.python" },
  { filetypes = { "rust" }, module = "snippets.rust" },
  {
    filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    module = "snippets.typescript",
  },
  { filetypes = { "go" }, module = "snippets.go" },
  { filetypes = { "javascript", "typescript" }, module = "snippets.node" },
  { filetypes = { "nix" }, module = "snippets.nix" },
  { filetypes = { "lua" }, module = "snippets.lua_nvim" },
  { filetypes = { "sql" }, module = "snippets.sql" },
  { filetypes = { "bash", "sh", "zsh" }, module = "snippets.bash" },

  -- DevOps & Infrastructure
  { filetypes = { "yaml", "yml" }, module = "snippets.kubernetes" },
  { filetypes = { "yaml", "yml" }, module = "snippets.docker_compose" },
  { filetypes = { "dockerfile", "docker" }, module = "snippets.docker" },
}

local function matches_filetype(snippet_config, filetype)
  for _, configured_filetype in ipairs(snippet_config.filetypes) do
    if configured_filetype == filetype then
      return true
    end
  end

  return false
end

local function load_module(snippet_config)
  if loaded_modules[snippet_config.module] then
    return
  end

  local ok, snippets = pcall(require, snippet_config.module)
  if not ok or not snippets then
    vim.notify(
      string.format("Failed to load %s snippets: %s", snippet_config.module, tostring(snippets)),
      vim.log.levels.WARN
    )
    return
  end

  local ls = require("luasnip")
  for _, filetype in ipairs(snippet_config.filetypes) do
    ls.add_snippets(filetype, snippets)
  end
  loaded_modules[snippet_config.module] = true
end

function M.load_for_filetype(filetype)
  if not filetype or filetype == "" then
    return
  end

  for _, snippet_config in ipairs(snippet_modules) do
    if matches_filetype(snippet_config, filetype) then
      load_module(snippet_config)
    end
  end
end

function M.setup()
  if configured then
    return
  end

  configured = true

  pcall(function()
    require("luasnip.loaders.from_vscode").lazy_load()
  end)

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("user_luasnip_filetype_snippets", { clear = true }),
    callback = function(event)
      M.load_for_filetype(vim.bo[event.buf].filetype)
    end,
  })

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      M.load_for_filetype(vim.bo[bufnr].filetype)
    end
  end
end

M.load_snippets = M.setup

return M
