-- Snippets loader - imports all snippet modules
-- This modular approach improves startup time and maintainability

local M = {}

-- Load snippet modules lazily
function M.load_snippets()
  local ls = require("luasnip")

  -- Define all snippet modules with their associated filetypes
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
    { filetypes = { "javascript", "typescript" }, module = "snippets.node" }, -- Node.js specific snippets
    { filetypes = { "nix" }, module = "snippets.nix" },
    { filetypes = { "lua" }, module = "snippets.lua_nvim" },
    { filetypes = { "sql" }, module = "snippets.sql" },
    { filetypes = { "bash", "sh", "zsh" }, module = "snippets.bash" },

    -- DevOps & Infrastructure
    { filetypes = { "yaml", "yml" }, module = "snippets.kubernetes" },
    { filetypes = { "yaml", "yml" }, module = "snippets.docker_compose" },
    { filetypes = { "dockerfile", "docker" }, module = "snippets.docker" },
  }

  -- Load each snippet module
  for _, snippet_config in ipairs(snippet_modules) do
    local ok, snippets = pcall(require, snippet_config.module)
    if ok and snippets then
      for _, filetype in ipairs(snippet_config.filetypes) do
        ls.add_snippets(filetype, snippets)
      end
    else
      vim.notify(
        string.format("Failed to load %s snippets: %s", snippet_config.module, tostring(snippets)),
        vim.log.levels.WARN
      )
    end
  end

  -- Load friendly-snippets (VSCode-style community snippets)
  pcall(function()
    require("luasnip.loaders.from_vscode").lazy_load()
  end)

  -- Report successful load
  vim.notify("LuaSnip: All snippet modules loaded successfully", vim.log.levels.INFO)
end

return M
