local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

local lua_snippets = {
  -- Neovim plugin structure
  s(
    "nvimplugin",
    fmt(
      [[
return {{
  "{}",
  version = "*",
  dependencies = {{
    {}
  }},
  config = function()
    require("{}").setup({{
      {}
    }})
  end,
}}]],
      {
        i(1, "author/plugin"),
        i(2, "-- dependencies"),
        i(3, "plugin"),
        i(4, "-- configuration"),
      }
    )
  ),

  -- Lazy plugin spec with lazy loading
  s(
    "nvimplazy",
    fmt(
      [[
return {{
  "{}",
  lazy = {},
  event = "{}",
  keys = {{
    {{ "{}", function() {} end, desc = "{}" }},
  }},
  config = function()
    {}
  end,
}}]],
      {
        i(1, "author/plugin"),
        i(2, "true"),
        i(3, "VeryLazy"),
        i(4, "<leader>key"),
        i(5, "-- action"),
        i(6, "Description"),
        i(7, "-- setup"),
      }
    )
  ),

  -- Autocommand
  s(
    "nvimau",
    fmt(
      [[
vim.api.nvim_create_autocmd("{}", {{
  group = vim.api.nvim_create_augroup("{}", {{ clear = true }}),
  pattern = "{}",
  callback = function(event)
    {}
  end,
}})]],
      {
        i(1, "BufEnter"),
        i(2, "group-name"),
        i(3, "*"),
        i(4, "-- callback"),
      }
    )
  ),

  -- Keymap
  s(
    "nvimmap",
    fmt('vim.keymap.set("{}", "{}", {}, {{ desc = "{}" }})', {
      i(1, "n"),
      i(2, "<leader>key"),
      i(3, "function"),
      i(4, "Description"),
    })
  ),

  -- User command
  s(
    "nvimcmd",
    fmt(
      [[
vim.api.nvim_create_user_command("{}", function(opts)
  {}
end, {{
  desc = "{}",
  {}
}})]],
      {
        i(1, "CommandName"),
        i(2, "-- implementation"),
        i(3, "Command description"),
        i(4, "-- options"),
      }
    )
  ),

  -- LSP on_attach
  s(
    "lspattach",
    fmt(
      [[
vim.api.nvim_create_autocmd("LspAttach", {{
  group = vim.api.nvim_create_augroup("lsp-attach-{}", {{ clear = true }}),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    local map = function(keys, func, desc)
      vim.keymap.set("n", keys, func, {{ buffer = event.buf, desc = "LSP: " .. desc }})
    end

    {}
  end,
}})]],
      {
        i(1, "custom"),
        i(2, "-- keymaps"),
      }
    )
  ),

  -- Module pattern
  s(
    "luamod",
    fmt(
      [[
local M = {{}}

function M.{}({})
  {}
end

function M.setup(opts)
  opts = opts or {{}}
  {}
end

return M]],
      {
        i(1, "function_name"),
        i(2, "args"),
        i(3, "-- implementation"),
        i(4, "-- setup logic"),
      }
    )
  ),

  -- Protected call
  s(
    "pcall",
    fmt(
      [[
local ok, {} = pcall(require, "{}")
if not ok then
  vim.notify("{} not found", vim.log.levels.{})
  return
end

{}]],
      {
        i(1, "module"),
        f(function(args)
          return args[1][1]
        end, { 1 }),
        f(function(args)
          return args[1][1]
        end, { 1 }),
        i(2, "ERROR"),
        i(3, "-- use module"),
      }
    )
  ),
}

return lua_snippets
