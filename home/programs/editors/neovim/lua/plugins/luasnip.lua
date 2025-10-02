return {
  "L3MON4D3/LuaSnip",
  version = "v2.*",
  -- jsregexp is provided via Nix extraLuaPackages in default.nix
  -- This is required for LSP snippet transformations
  dependencies = {
    "rafamadriz/friendly-snippets",
  },
  enabled = true,
  lazy = true,
  config = function()
    local ls = require("luasnip")
    local s = ls.snippet
    local t = ls.text_node
    local i = ls.insert_node
    local f = ls.function_node
    local fmt = require("luasnip.extras.fmt").fmt

    -- Define languages for code blocks
    local languages = {
      "txt",
      "lua",
      "sql",
      "go",
      "regex",
      "bash",
      "markdown",
      "markdown_inline",
      "yaml",
      "json",
      "jsonc",
      "cpp",
      "csv",
      "java",
      "javascript",
      "python",
      "dockerfile",
      "html",
      "css",
      "templ",
      "php",
    }

    -- Helper function to create code block snippets
    local function create_code_block_snippet(lang)
      return s({
        trig = lang,
        name = "Codeblock",
        desc = lang .. " codeblock",
      }, {
        t({ "```" .. lang, "" }),
        i(1),
        t({ "", "```" }),
      })
    end

    -- Create code block snippets for each language
    local markdown_snippets = {}
    for _, lang in ipairs(languages) do
      table.insert(markdown_snippets, create_code_block_snippet(lang))
    end

    -- Add useful markdown snippets
    table.insert(
      markdown_snippets,
      s({
        trig = "linkt",
        name = "Add link with target blank",
        desc = 'Add this -> [](){:target="_blank"}',
      }, {
        t("["),
        i(1),
        t("]("),
        i(2),
        t('){:target="_blank"}'),
      })
    )

    table.insert(
      markdown_snippets,
      s({
        trig = "todo",
        name = "Add TODO comment",
        desc = "Add TODO: item",
      }, {
        t("<!-- TODO: "),
        i(1),
        t(" -->"),
      })
    )

    table.insert(
      markdown_snippets,
      s({
        trig = "chirpy",
        name = "Disable markdownlint and prettier for chirpy",
        desc = "Disable markdownlint and prettier for chirpy",
      }, {
        t({
          " ",
          "<!-- markdownlint-disable -->",
          "<!-- prettier-ignore-start -->",
          " ",
          "<!-- tip=green, info=blue, warning=yellow, danger=red -->",
          " ",
          "> ",
        }),
        i(1),
        t({
          "",
          "{: .prompt-",
        }),
        i(2),
        t({
          " }",
          " ",
          "<!-- prettier-ignore-end -->",
          "<!-- markdownlint-restore -->",
        }),
      })
    )

    table.insert(
      markdown_snippets,
      s({
        trig = "markdownlint",
        name = "Add markdownlint disable/restore",
        desc = "Add markdownlint disable and restore headings",
      }, {
        t({
          " ",
          "<!-- markdownlint-disable -->",
          " ",
          "> ",
        }),
        i(1),
        t({
          " ",
          " ",
          "<!-- markdownlint-restore -->",
        }),
      })
    )

    table.insert(
      markdown_snippets,
      s({
        trig = "prettierignore",
        name = "Add prettier ignore blocks",
        desc = "Add prettier ignore start and end headings",
      }, {
        t({
          " ",
          "<!-- prettier-ignore-start -->",
          " ",
          "> ",
        }),
        i(1),
        t({
          " ",
          " ",
          "<!-- prettier-ignore-end -->",
        }),
      })
    )

    -- Add common markdown elements
    table.insert(
      markdown_snippets,
      s(
        "meta",
        fmt(
          [[
---
title: {}
date: {}
tags: [{}]
---

{}]],
          {
            i(1, "Title"),
            f(function()
              return os.date("%Y-%m-%d")
            end),
            i(2, "tags"),
            i(3, "content"),
          }
        )
      )
    )

    table.insert(
      markdown_snippets,
      s(
        "link",
        fmt("[{}]({})", {
          i(1, "text"),
          i(2, "url"),
        })
      )
    )

    table.insert(
      markdown_snippets,
      s(
        "img",
        fmt("![{}]({})", {
          i(1, "alt text"),
          i(2, "url"),
        })
      )
    )

    -- Headers
    table.insert(markdown_snippets, s("h1", fmt("# {}", { i(1) })))
    table.insert(markdown_snippets, s("h2", fmt("## {}", { i(1) })))
    table.insert(markdown_snippets, s("h3", fmt("### {}", { i(1) })))

    -- Lists
    table.insert(markdown_snippets, s("ul", fmt("- {}", { i(1) })))
    table.insert(markdown_snippets, s("ol", fmt("1. {}", { i(1) })))
    table.insert(markdown_snippets, s("cl", fmt("- [ ] {}", { i(1) })))

    -- Tables
    table.insert(
      markdown_snippets,
      s(
        "table2",
        fmt(
          [[
| {} | {} |
|---|---|
| {} | {} |]],
          {
            i(1, "Header 1"),
            i(2, "Header 2"),
            i(3, "Row 1"),
            i(4, "Row 1"),
          }
        )
      )
    )

    -- Callouts
    table.insert(markdown_snippets, s("note", fmt("> **Note**\n> {}", { i(1) })))
    table.insert(markdown_snippets, s("warn", fmt("> **Warning**\n> {}", { i(1) })))
    table.insert(markdown_snippets, s("info", fmt("> **Info**\n> {}", { i(1) })))

    -- Python Snippets
    local python_snippets = {
      -- Main script template
      s(
        "pymain",
        fmt(
          [[
#!/usr/bin/env python3

def main():
    {}

if __name__ == '__main__':
    main()
]],
          {
            i(1, "pass"),
          }
        )
      ),

      -- Class template
      s(
        "pyclass",
        fmt(
          [[
class {}:
    def __init__(self{}):
        {}
    
    def __str__(self):
        return f"{}"
]],
          {
            i(1, "ClassName"),
            i(2, ", *args"),
            i(3, "# Initialize attributes"),
            i(4, "String representation"),
          }
        )
      ),

      -- Function with docstring
      s(
        "pyfunc",
        fmt(
          [[
def {}({}):
    """
    {}

    Args:
        {}: {}
    
    Returns:
        {}: {}
    """
    {}
]],
          {
            i(1, "function_name"),
            i(2, "args"),
            i(3, "Function description"),
            i(4, "param"),
            i(5, "param description"),
            i(6, "return_type"),
            i(7, "return description"),
            i(8, "pass"),
          }
        )
      ),

      -- FastAPI endpoint
      s(
        "pyapi",
        fmt(
          [[
@router.{}("{}")
async def {}({}):
    """
    {}
    """
    try:
        {}
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=str(e)
        )
]],
          {
            i(1, "get"),
            i(2, "/path"),
            i(3, "endpoint_name"),
            i(4, "request: Request"),
            i(5, "Endpoint description"),
            i(6, "return {}"),
          }
        )
      ),

      -- Testing template
      s(
        "pytest",
        fmt(
          [[
import pytest

def test_{}():
    # Arrange
    {}
    
    # Act
    {}
    
    # Assert
    {}
]],
          {
            i(1, "function_name"),
            i(2, "# Setup test data"),
            i(3, "# Execute function"),
            i(4, "# Verify results"),
          }
        )
      ),
    }

    -- Rust Snippets
    local rust_snippets = {
      -- Basic main
      s(
        "rsmain",
        fmt(
          [[
fn main() {{
    {}
}}
]],
          {
            i(1, "// Your code here"),
          }
        )
      ),

      -- Struct with implementation
      s(
        "rsstruct",
        fmt(
          [[
#[derive(Debug{})]
struct {} {{
    {}
}}

impl {} {{
    pub fn new({}) -> Self {{
        Self {{
            {}
        }}
    }}
    
    {}
}}
]],
          {
            i(1, ", Clone"),
            i(2, "StructName"),
            i(3, "field: Type"),
            f(function(args)
              return args[1][1]
            end, { 2 }),
            i(4, "params"),
            i(5, "field"),
            i(6, "// Additional methods"),
          }
        )
      ),

      -- Test module
      s(
        "rstest",
        fmt(
          [[
#[cfg(test)]
mod tests {{
    use super::*;

    #[test]
    fn test_{}() {{
        {}
    }}
}}
]],
          {
            i(1, "function_name"),
            i(2, "// Test implementation"),
          }
        )
      ),
    }

    -- TypeScript/JavaScript Snippets
    local ts_snippets = {
      -- React component
      s(
        "tsreact",
        fmt(
          [[
import React from 'react'

interface {}Props {{
  {}
}}

export const {}: React.FC<{}Props> = ({{ {} }}) => {{
  return (
    {}
  )
}}
]],
          {
            i(1, "Component"),
            i(2, "// Props"),
            f(function(args)
              return args[1][1]
            end, { 1 }),
            f(function(args)
              return args[1][1]
            end, { 1 }),
            i(3, "props"),
            i(4, "<div>Component</div>"),
          }
        )
      ),

      -- API endpoint
      s(
        "tsapi",
        fmt(
          [[
export async function {}(
  req: NextApiRequest,
  res: NextApiResponse
) {{
  try {{
    {}
  }} catch (error) {{
    res.status(500).json({{ error: error.message }})
  }}
}}
]],
          {
            i(1, "handler"),
            i(2, "// Implementation"),
          }
        )
      ),

      -- Interface
      s(
        "tsinterface",
        fmt(
          [[
interface {} {{
  {}: {}
  {}
}}
]],
          {
            i(1, "InterfaceName"),
            i(2, "property"),
            i(3, "type"),
            i(4, "// Additional properties"),
          }
        )
      ),
    }

    -- Go Snippets
    local go_snippets = {
      -- Main package
      s(
        "gomain",
        fmt(
          [[
package main

import (
    {}
)

func main() {{
    {}
}}
]],
          {
            i(1, '"fmt"'),
            i(2, "// Implementation"),
          }
        )
      ),

      -- Struct with methods
      s(
        "gostruct",
        fmt(
          [[
type {} struct {{
    {}
}}

func ({} *{}) {}({}) {} {{
    {}
}}
]],
          {
            i(1, "StructName"),
            i(2, "// Fields"),
            i(3, "s"),
            f(function(args)
              return args[1][1]
            end, { 1 }),
            i(4, "MethodName"),
            i(5, "params"),
            i(6, "returnType"),
            i(7, "// Implementation"),
          }
        )
      ),

      -- Test function
      s(
        "gotest",
        fmt(
          [[
func Test{}(t *testing.T) {{
    tests := []struct{{
        name string
        {}
        want {}
    }}{{
        {{
            name: "{}",
            {}: {},
            want: {},
        }},
    }}

    for _, tt := range tests {{
        t.Run(tt.name, func(t *testing.T) {{
            {}
        }})
    }}
}}
]],
          {
            i(1, "Function"),
            i(2, "input Type"),
            i(3, "Type"),
            i(4, "test case"),
            i(5, "input"),
            i(6, "value"),
            i(7, "expected"),
            i(8, "// Test implementation"),
          }
        )
      ),
    }

    -- Node.js Snippets
    local node_snippets = {
      -- Express server setup
      s(
        "exserver",
        fmt(
          [[
const express = require('express');
const app = express();
const port = process.env.PORT || {};

app.use(express.json());

{}

app.listen(port, () => {{
  console.log(`Server running on port ${{port}}`);
}});
]],
          {
            i(1, "3000"),
            i(2, "// Routes here"),
          }
        )
      ),

      -- Express route
      s(
        "exroute",
        fmt(
          [[
app.{}('{}', async (req, res) => {{
  try {{
    {}
  }} catch (error) {{
    console.error('Error:', error);
    res.status(500).json({{ error: error.message }});
  }}
}});
]],
          {
            i(1, "get"),
            i(2, "/path"),
            i(3, "// Route handler code"),
          }
        )
      ),

      -- Express middleware
      s(
        "exmid",
        fmt(
          [[
const {} = (req, res, next) => {{
  try {{
    {}
    next();
  }} catch (error) {{
    next(error);
  }}
}};
]],
          {
            i(1, "middlewareName"),
            i(2, "// Middleware logic"),
          }
        )
      ),

      -- Node.js class with async methods
      s(
        "nodeclass",
        fmt(
          [[
class {} {{
  constructor({}) {{
    {}
  }}

  async {}({}) {{
    try {{
      {}
    }} catch (error) {{
      throw new Error(`{} failed: ${{error.message}}`);
    }}
  }}
}}

module.exports = {};
]],
          {
            i(1, "ClassName"),
            i(2, "options = {}"),
            i(3, "// Initialize properties"),
            i(4, "methodName"),
            i(5, "params"),
            i(6, "// Method implementation"),
            f(function(args)
              return args[1][1]
            end, { 4 }),
            f(function(args)
              return args[1][1]
            end, { 1 }),
          }
        )
      ),

      -- MongoDB schema
      s(
        "mongoschema",
        fmt(
          [[
const mongoose = require('mongoose');

const {}Schema = new mongoose.Schema({{
  {}: {{
    type: {},
    required: {},
    {}
  }},
}}, {{
  timestamps: true,
}});

{}Schema.methods.{} = async function() {{
  {}
}};

module.exports = mongoose.model('{}', {}Schema);
]],
          {
            i(1, "Model"),
            i(2, "field"),
            i(3, "String"),
            i(4, "true"),
            i(5, "// Additional field options"),
            f(function(args)
              return args[1][1]
            end, { 1 }),
            i(6, "methodName"),
            i(7, "// Method implementation"),
            f(function(args)
              return args[1][1]
            end, { 1 }),
            f(function(args)
              return args[1][1]
            end, { 1 }),
          }
        )
      ),

      -- Jest test
      s(
        "jtest",
        fmt(
          [[
describe('{}', () => {{
  beforeEach(() => {{
    {}
  }});

  it('should {}', async () => {{
    // Arrange
    {}

    // Act
    {}

    // Assert
    {}
  }});
}});
]],
          {
            i(1, "Test suite name"),
            i(2, "// Setup"),
            i(3, "expected behavior"),
            i(4, "// Test setup"),
            i(5, "// Execute the code"),
            i(6, "// Verify the results"),
          }
        )
      ),

      -- API route handler
      s(
        "apihandler",
        fmt(
          [[
const {} = async (req, res) => {{
  const {{ {} }} = req.{};
  
  try {{
    {}
    
    return res.status({}).json({{
      success: true,
      data: {},
    }});
  }} catch (error) {{
    console.error('Error in {}:', error);
    return res.status(500).json({{
      success: false,
      error: error.message,
    }});
  }}
}};
]],
          {
            i(1, "handlerName"),
            i(2, "params"),
            i(3, "body"),
            i(4, "// Handler implementation"),
            i(5, "200"),
            i(6, "result"),
            f(function(args)
              return args[1][1]
            end, { 1 }),
          }
        )
      ),

      -- Environment config
      s(
        "envconfig",
        fmt(
          [[
require('dotenv').config();

const config = {{
  nodeEnv: process.env.NODE_ENV || 'development',
  port: process.env.PORT || {},
  {}: process.env.{},
  database: {{
    url: process.env.DATABASE_URL,
    options: {{
      useNewUrlParser: true,
      useUnifiedTopology: true,
    }},
  }},
  jwt: {{
    secret: process.env.JWT_SECRET,
    expiresIn: process.env.JWT_EXPIRES_IN || '1d',
  }},
}};

module.exports = config;
]],
          {
            i(1, "3000"),
            i(2, "configKey"),
            f(function(args)
              return args[1][1]:upper()
            end, { 2 }),
          }
        )
      ),
    }

    -- Nix Snippets
    local nix_snippets = {
      -- Basic flake
      s(
        "nixflake",
        fmt(
          [[
{{
  description = "{}";

  inputs = {{
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    {}
  }};

  outputs = {{ self, nixpkgs, ... }}@inputs: {{
    {}
  }};
}}]],
          {
            i(1, "A very basic flake"),
            i(2, "# Additional inputs"),
            i(3, "# Outputs"),
          }
        )
      ),

      -- Home Manager module
      s(
        "nixhm",
        fmt(
          [[
{{ config, lib, pkgs, ... }}:

{{
  home.packages = with pkgs; [
    {}
  ];

  programs.{} = {{
    enable = true;
    {}
  }};
}}]],
          {
            i(1, "# packages"),
            i(2, "program"),
            i(3, "# configuration"),
          }
        )
      ),

      -- NixOS module
      s(
        "nixmodule",
        fmt(
          [[
{{ config, lib, pkgs, ... }}:

with lib;

let
  cfg = config.{};
in {{
  options.{} = {{
    enable = mkEnableOption "{}";

    {} = mkOption {{
      type = types.{};
      default = {};
      description = "{}";
    }};
  }};

  config = mkIf cfg.enable {{
    {}
  }};
}}]],
          {
            i(1, "services.myservice"),
            f(function(args)
              return args[1][1]
            end, { 1 }),
            i(2, "my service"),
            i(3, "package"),
            i(4, "package"),
            i(5, "pkgs.hello"),
            i(6, "Package to use"),
            i(7, "# Module configuration"),
          }
        )
      ),

      -- Shell script with Nix
      s(
        "nixscript",
        fmt(
          [[
{{ pkgs ? import <nixpkgs> {{}} }}:

pkgs.writeScriptBin "{}" ''
  #!${{pkgs.bash}}/bin/bash
  set -euo pipefail

  {}
'']],
          {
            i(1, "script-name"),
            i(2, "# Script content"),
          }
        )
      ),

      -- Package derivation
      s(
        "nixpkg",
        fmt(
          [[
{{ lib
, stdenv
, fetchFromGitHub
, {}
}}:

stdenv.mkDerivation rec {{
  pname = "{}";
  version = "{}";

  src = fetchFromGitHub {{
    owner = "{}";
    repo = "{}";
    rev = "v${{version}}";
    sha256 = "{}";
  }};

  buildInputs = [ {} ];

  installPhase = ''
    {}
  '';

  meta = with lib; {{
    description = "{}";
    homepage = "https://github.com/{}/{}";
    license = licenses.{};
    maintainers = with maintainers; [ {} ];
  }};
}}]],
          {
            i(1, "dependencies"),
            i(2, "package-name"),
            i(3, "0.1.0"),
            i(4, "owner"),
            i(5, "repo"),
            i(6, "sha256-AAAA..."),
            i(7, "dependencies"),
            i(8, "# Install commands"),
            i(9, "Package description"),
            f(function(args)
              return args[1][1]
            end, { 4 }),
            f(function(args)
              return args[1][1]
            end, { 5 }),
            i(10, "mit"),
            i(11, "yourname"),
          }
        )
      ),

      -- Overlay
      s(
        "nixoverlay",
        fmt(
          [[
final: prev: {{
  {} = prev.{}.overrideAttrs (oldAttrs: {{
    {}
  }});
}}]],
          {
            i(1, "package-name"),
            f(function(args)
              return args[1][1]
            end, { 1 }),
            i(2, "# Attribute overrides"),
          }
        )
      ),

      -- Let binding
      s("nixlet", fmt("let\n  {} = {};\nin {}", { i(1, "name"), i(2, "value"), i(3, "expression") })),

      -- mkIf
      s("nixif", fmt("mkIf {} {{\n  {}\n}}", { i(1, "condition"), i(2, "# config") })),

      -- mkOption
      s(
        "nixopt",
        fmt(
          [[
{} = mkOption {{
  type = types.{};
  default = {};
  description = "{}";
}};]],
          {
            i(1, "optionName"),
            i(2, "str"),
            i(3, '""'),
            i(4, "Option description"),
          }
        )
      ),
    }

    -- Lua Snippets (Neovim plugin development)
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

    -- SQL Snippets
    local sql_snippets = {
      -- SELECT with JOIN
      s(
        "sqljoin",
        fmt(
          [[
SELECT {}
FROM {}
INNER JOIN {} ON {}.{} = {}.{}
WHERE {}
ORDER BY {}
LIMIT {};]],
          {
            i(1, "columns"),
            i(2, "table1"),
            i(3, "table2"),
            f(function(args)
              return args[1][1]
            end, { 2 }),
            i(4, "id"),
            f(function(args)
              return args[1][1]
            end, { 3 }),
            i(5, "foreign_id"),
            i(6, "condition"),
            i(7, "column"),
            i(8, "10"),
          }
        )
      ),

      -- CREATE TABLE
      s(
        "sqlcreate",
        fmt(
          [[
CREATE TABLE {} (
  id SERIAL PRIMARY KEY,
  {} {} {},
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);]],
          {
            i(1, "table_name"),
            i(2, "column_name"),
            i(3, "VARCHAR(255)"),
            i(4, "NOT NULL"),
          }
        )
      ),

      -- INSERT
      s(
        "sqlinsert",
        fmt(
          [[
INSERT INTO {} ({})
VALUES ({})
RETURNING *;]],
          {
            i(1, "table_name"),
            i(2, "columns"),
            i(3, "values"),
          }
        )
      ),

      -- UPDATE
      s(
        "sqlupdate",
        fmt(
          [[
UPDATE {}
SET {} = {},
    updated_at = CURRENT_TIMESTAMP
WHERE {}
RETURNING *;]],
          {
            i(1, "table_name"),
            i(2, "column"),
            i(3, "value"),
            i(4, "id = 1"),
          }
        )
      ),

      -- Transaction
      s(
        "sqltx",
        fmt(
          [[
BEGIN;

{}

COMMIT;]],
          {
            i(1, "-- SQL statements"),
          }
        )
      ),

      -- Index
      s(
        "sqlindex",
        fmt("CREATE INDEX idx_{}_ON {} ({});", {
          i(1, "name"),
          i(2, "table_name"),
          i(3, "column"),
        })
      ),

      -- Common aggregate query
      s(
        "sqlagg",
        fmt(
          [[
SELECT 
  {},
  COUNT(*) as count,
  {}
FROM {}
GROUP BY {}
HAVING COUNT(*) > {}
ORDER BY count DESC;]],
          {
            i(1, "column"),
            i(2, "aggregate_functions"),
            i(3, "table_name"),
            f(function(args)
              return args[1][1]
            end, { 1 }),
            i(4, "1"),
          }
        )
      ),
    }

    -- Bash/Shell Snippets
    local bash_snippets = {
      -- Script header
      s(
        "shheader",
        fmt(
          [[
#!/usr/bin/env bash
set -euo pipefail

# {}
# Author: {}
# Date: {}

{}]],
          {
            i(1, "Script description"),
            i(2, "Your Name"),
            f(function()
              return os.date("%Y-%m-%d")
            end),
            i(3, "# Script content"),
          }
        )
      ),

      -- Function
      s(
        "shfunc",
        fmt(
          [[
{}() {{
  local {}="{}"
  {}
}}]],
          {
            i(1, "function_name"),
            i(2, "param"),
            i(3, "default_value"),
            i(4, "# function body"),
          }
        )
      ),

      -- Error handling
      s(
        "sherr",
        fmt(
          [[
if [ {} ]; then
  echo "Error: {}" >&2
  exit 1
fi]],
          {
            i(1, "condition"),
            i(2, "error message"),
          }
        )
      ),

      -- Argument parsing
      s(
        "shargs",
        fmt(
          [=[
while [[ $# -gt 0 ]]; do
  case $1 in
    -{}|--{})
      {}="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 [OPTIONS]"
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done]=],
          {
            i(1, "o"),
            i(2, "option"),
            f(function(args)
              return args[1][1]:upper()
            end, { 2 }),
          }
        )
      ),

      -- For loop
      s("shfor", fmt('for {} in {}; do\n  {}\ndone', { i(1, "item"), i(2, "items"), i(3, "# body") })),

      -- While read loop
      s(
        "shwhile",
        fmt('while IFS= read -r {}; do\n  {}\ndone < {}', { i(1, "line"), i(2, "# process line"), i(3, "file") })
      ),

      -- Check if command exists
      s(
        "shcheck",
        fmt(
          [[
if ! command -v {} &> /dev/null; then
  echo "{} not found. Please install it first." >&2
  exit 1
fi]],
          {
            i(1, "command"),
            f(function(args)
              return args[1][1]
            end, { 1 }),
          }
        )
      ),

      -- Logging function
      s(
        "shlog",
        fmt(
          [[
log() {{
  local level="$1"
  shift
  local message="$@"
  echo "[${{level}}] $(date '+%Y-%m-%d %H:%M:%S') - ${{message}}"
}}

log "INFO" "{}"]],
          {
            i(1, "Log message"),
          }
        )
      ),

      -- Cleanup trap
      s(
        "shtrap",
        fmt(
          [[
cleanup() {{
  {}
}}

trap cleanup EXIT INT TERM]],
          {
            i(1, "# Cleanup commands"),
          }
        )
      ),
    }

    -- Kubernetes Snippets
    local kubernetes_snippets = {
      -- Deployment
      s(
        "k8sdeploy",
        fmt(
          [[
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {}
  namespace: {}
  labels:
    app: {}
spec:
  replicas: {}
  selector:
    matchLabels:
      app: {}
  template:
    metadata:
      labels:
        app: {}
    spec:
      containers:
      - name: {}
        image: {}:{}
        ports:
        - containerPort: {}
        env:
        - name: {}
          value: "{}"
        resources:
          requests:
            memory: "{}Mi"
            cpu: "{}m"
          limits:
            memory: "{}Mi"
            cpu: "{}m"]],
          {
            i(1, "app-deployment"),
            i(2, "default"),
            i(3, "myapp"),
            i(4, "3"),
            f(function(args)
              return args[1][1]
            end, { 3 }),
            f(function(args)
              return args[1][1]
            end, { 3 }),
            f(function(args)
              return args[1][1]
            end, { 3 }),
            i(5, "myapp"),
            i(6, "latest"),
            i(7, "8080"),
            i(8, "ENV_VAR"),
            i(9, "value"),
            i(10, "128"),
            i(11, "100"),
            i(12, "256"),
            i(13, "200"),
          }
        )
      ),

      -- Service
      s(
        "k8ssvc",
        fmt(
          [[
apiVersion: v1
kind: Service
metadata:
  name: {}
  namespace: {}
  labels:
    app: {}
spec:
  type: {}
  selector:
    app: {}
  ports:
  - port: {}
    targetPort: {}
    protocol: TCP
    name: {}]],
          {
            i(1, "app-service"),
            i(2, "default"),
            i(3, "myapp"),
            i(4, "ClusterIP"),
            f(function(args)
              return args[1][1]
            end, { 3 }),
            i(5, "80"),
            i(6, "8080"),
            i(7, "http"),
          }
        )
      ),

      -- ConfigMap
      s(
        "k8scm",
        fmt(
          [[
apiVersion: v1
kind: ConfigMap
metadata:
  name: {}
  namespace: {}
data:
  {}: {}
  {}: |
    {}]],
          {
            i(1, "app-config"),
            i(2, "default"),
            i(3, "key"),
            i(4, "value"),
            i(5, "config.yaml"),
            i(6, "# YAML content"),
          }
        )
      ),

      -- Secret
      s(
        "k8ssecret",
        fmt(
          [[
apiVersion: v1
kind: Secret
metadata:
  name: {}
  namespace: {}
type: {}
data:
  {}: {}]],
          {
            i(1, "app-secret"),
            i(2, "default"),
            i(3, "Opaque"),
            i(4, "key"),
            i(5, "base64encodedvalue"),
          }
        )
      ),

      -- Ingress
      s(
        "k8sing",
        fmt(
          [[
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {}
  namespace: {}
  annotations:
    {}: "{}"
spec:
  ingressClassName: {}
  rules:
  - host: {}
    http:
      paths:
      - path: {}
        pathType: {}
        backend:
          service:
            name: {}
            port:
              number: {}]],
          {
            i(1, "app-ingress"),
            i(2, "default"),
            i(3, "cert-manager.io/cluster-issuer"),
            i(4, "letsencrypt-prod"),
            i(5, "nginx"),
            i(6, "app.example.com"),
            i(7, "/"),
            i(8, "Prefix"),
            i(9, "app-service"),
            i(10, "80"),
          }
        )
      ),

      -- StatefulSet
      s(
        "k8ssts",
        fmt(
          [[
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: {}
  namespace: {}
spec:
  serviceName: {}
  replicas: {}
  selector:
    matchLabels:
      app: {}
  template:
    metadata:
      labels:
        app: {}
    spec:
      containers:
      - name: {}
        image: {}:{}
        ports:
        - containerPort: {}
        volumeMounts:
        - name: {}
          mountPath: {}
  volumeClaimTemplates:
  - metadata:
      name: {}
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: {}Gi]],
          {
            i(1, "app-statefulset"),
            i(2, "default"),
            i(3, "app"),
            i(4, "3"),
            i(5, "myapp"),
            f(function(args)
              return args[1][1]
            end, { 5 }),
            f(function(args)
              return args[1][1]
            end, { 5 }),
            i(6, "myapp"),
            i(7, "latest"),
            i(8, "8080"),
            i(9, "data"),
            i(10, "/data"),
            f(function(args)
              return args[1][1]
            end, { 9 }),
            i(11, "10"),
          }
        )
      ),

      -- PersistentVolumeClaim
      s(
        "k8spvc",
        fmt(
          [[
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {}
  namespace: {}
spec:
  accessModes:
  - {}
  resources:
    requests:
      storage: {}Gi
  storageClassName: {}]],
          {
            i(1, "app-pvc"),
            i(2, "default"),
            i(3, "ReadWriteOnce"),
            i(4, "10"),
            i(5, "standard"),
          }
        )
      ),

      -- Job
      s(
        "k8sjob",
        fmt(
          [[
apiVersion: batch/v1
kind: Job
metadata:
  name: {}
  namespace: {}
spec:
  backoffLimit: {}
  template:
    spec:
      containers:
      - name: {}
        image: {}:{}
        command: [{}]
        args: [{}]
      restartPolicy: {}]],
          {
            i(1, "job-name"),
            i(2, "default"),
            i(3, "3"),
            i(4, "job"),
            i(5, "busybox"),
            i(6, "latest"),
            i(7, '"/bin/sh"'),
            i(8, '"-c", "echo hello"'),
            i(9, "Never"),
          }
        )
      ),

      -- CronJob
      s(
        "k8scron",
        fmt(
          [[
apiVersion: batch/v1
kind: CronJob
metadata:
  name: {}
  namespace: {}
spec:
  schedule: "{}"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: {}
            image: {}:{}
            command: [{}]
          restartPolicy: OnFailure]],
          {
            i(1, "cronjob-name"),
            i(2, "default"),
            i(3, "0 * * * *"),
            i(4, "job"),
            i(5, "busybox"),
            i(6, "latest"),
            i(7, '"/bin/sh", "-c", "echo hello"'),
          }
        )
      ),

      -- Namespace
      s(
        "k8sns",
        fmt(
          [[
apiVersion: v1
kind: Namespace
metadata:
  name: {}
  labels:
    {}: {}]],
          {
            i(1, "namespace-name"),
            i(2, "environment"),
            i(3, "production"),
          }
        )
      ),

      -- HorizontalPodAutoscaler
      s(
        "k8shpa",
        fmt(
          [[
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {}
  namespace: {}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {}
  minReplicas: {}
  maxReplicas: {}
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: {}]],
          {
            i(1, "app-hpa"),
            i(2, "default"),
            i(3, "app-deployment"),
            i(4, "2"),
            i(5, "10"),
            i(6, "80"),
          }
        )
      ),

      -- ServiceAccount
      s(
        "k8ssa",
        fmt(
          [[
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {}
  namespace: {}]],
          {
            i(1, "app-sa"),
            i(2, "default"),
          }
        )
      ),
    }

    -- Docker Snippets (Dockerfiles)
    local docker_snippets = {
      -- Multi-stage Node.js
      s(
        "dfnode",
        fmt(
          [[
# Build stage
FROM node:{}-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .
{}

# Production stage
FROM node:{}-alpine

WORKDIR /app

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nodejs:nodejs /app/package.json ./
{}

USER nodejs

EXPOSE {}

CMD ["{}"]
]],
          {
            i(1, "20"),
            i(2, "RUN npm run build"),
            f(function(args)
              return args[1][1]
            end, { 1 }),
            i(3, "COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist"),
            i(4, "3000"),
            i(5, "node", "server.js"),
          }
        )
      ),

      -- Python with Poetry
      s(
        "dfpython",
        fmt(
          [[
FROM python:{}-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    {} \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY . .

# Create non-root user
RUN useradd -m -u 1001 appuser && \
    chown -R appuser:appuser /app

USER appuser

EXPOSE {}

CMD ["python", "{}"]
]],
          {
            i(1, "3.11"),
            i(2, "gcc"),
            i(3, "8000"),
            i(4, "main.py"),
          }
        )
      ),

      -- Go multi-stage
      s(
        "dfgo",
        fmt(
          [[
# Build stage
FROM golang:{}-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

# Production stage
FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /root/

COPY --from=builder /app/main .

EXPOSE {}

CMD ["./main"]
]],
          {
            i(1, "1.21"),
            i(2, "8080"),
          }
        )
      ),

      -- Rust multi-stage
      s(
        "dfrust",
        fmt(
          [[
# Build stage
FROM rust:{}-alpine AS builder

WORKDIR /app

COPY Cargo.toml Cargo.lock ./
RUN mkdir src && \
    echo "fn main() {{}}" > src/main.rs && \
    cargo build --release && \
    rm -rf src

COPY . .
RUN cargo build --release

# Production stage
FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /root/

COPY --from=builder /app/target/release/{} .

EXPOSE {}

CMD ["./{}"]
]],
          {
            i(1, "1.75"),
            i(2, "app"),
            i(3, "8080"),
            f(function(args)
              return args[1][1]
            end, { 2 }),
          }
        )
      ),

      -- Nginx static site
      s(
        "dfnginx",
        fmt(
          [[
FROM nginx:{}-alpine

# Copy custom nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Copy static files
COPY {} /usr/share/nginx/html

EXPOSE {}

CMD ["nginx", "-g", "daemon off;"]
]],
          {
            i(1, "alpine"),
            i(2, "dist"),
            i(3, "80"),
          }
        )
      ),

      -- Development Dockerfile
      s(
        "dfdev",
        fmt(
          [[
FROM {}:{}

WORKDIR /app

# Install development dependencies
{}

# Copy dependency files
COPY {} .

# Install dependencies
{}

# Copy source code
COPY . .

# Expose ports
EXPOSE {}

# Development command with hot reload
CMD [{}]
]],
          {
            i(1, "node"),
            i(2, "20-alpine"),
            i(3, "RUN apk add --no-cache git"),
            i(4, "package*.json"),
            i(5, "RUN npm install"),
            i(6, "3000"),
            i(7, '"npm", "run", "dev"'),
          }
        )
      ),

      -- Basic Dockerfile template
      s(
        "dfbasic",
        fmt(
          [[
FROM {}:{}

WORKDIR /app

COPY . .

{}

EXPOSE {}

CMD [{}]
]],
          {
            i(1, "ubuntu"),
            i(2, "22.04"),
            i(3, "# Build commands"),
            i(4, "8080"),
            i(5, '"./app"'),
          }
        )
      ),

      -- .dockerignore file
      s(
        "dockerignore",
        fmt(
          [[
# Git
.git
.gitignore
.gitattributes

# CI/CD
.github
.gitlab-ci.yml

# Dependencies
node_modules
vendor
__pycache__
*.pyc

# Environment
.env
.env.*
!.env.example

# Build artifacts
dist
build
target
*.log

# Documentation
README.md
docs
*.md

# IDE
.vscode
.idea
*.swp
*.swo

{}
]],
          {
            i(1, "# Additional ignores"),
          }
        )
      ),
    }

    -- Docker Compose Snippets
    local docker_compose_snippets = {
      -- Basic compose file
      s(
        "dcbase",
        fmt(
          [[
version: '3.8'

services:
  {}:
    image: {}
    container_name: {}
    restart: unless-stopped
    ports:
      - "{}:{}"]],
          {
            i(1, "app"),
            i(2, "image-name"),
            f(function(args)
              return args[1][1]
            end, { 1 }),
            i(3, "8080"),
            f(function(args)
              return args[1][1]
            end, { 3 }),
          }
        )
      ),

      -- Node.js service
      s(
        "dcnode",
        fmt(
          [[
  {}:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: {}
    restart: unless-stopped
    environment:
      - NODE_ENV={}
      - PORT={}
    ports:
      - "{}:${}"
    volumes:
      - .:/usr/src/app
      - /usr/src/app/node_modules
    depends_on:
      - {}]],
          {
            i(1, "node-app"),
            f(function(args)
              return args[1][1]
            end, { 1 }),
            i(2, "development"),
            i(3, "3000"),
            f(function(args)
              return args[1][1]
            end, { 3 }),
            f(function(args)
              return args[1][1]
            end, { 3 }),
            i(4, "mongodb"),
          }
        )
      ),

      -- Database service (MongoDB)
      s(
        "dcmongo",
        fmt(
          [[
  mongodb:
    image: mongo:{}
    container_name: mongodb
    restart: unless-stopped
    environment:
      - MONGO_INITDB_ROOT_USERNAME={}
      - MONGO_INITDB_ROOT_PASSWORD={}
      - MONGO_INITDB_DATABASE={}
    ports:
      - "27017:27017"
    volumes:
      - mongodb_data:/data/db

volumes:
  mongodb_data:]],
          {
            i(1, "latest"),
            i(2, "root"),
            i(3, "password"),
            i(4, "mydatabase"),
          }
        )
      ),

      -- Database service (PostgreSQL)
      s(
        "dcpostgres",
        fmt(
          [[
  postgres:
    image: postgres:{}
    container_name: postgres
    restart: unless-stopped
    environment:
      - POSTGRES_USER={}
      - POSTGRES_PASSWORD={}
      - POSTGRES_DB={}
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:]],
          {
            i(1, "latest"),
            i(2, "postgres"),
            i(3, "password"),
            i(4, "mydatabase"),
          }
        )
      ),

      -- Redis service
      s(
        "dcredis",
        fmt(
          [[
  redis:
    image: redis:{}
    container_name: redis
    restart: unless-stopped
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    command: redis-server --appendonly yes{}

volumes:
  redis_data:]],
          {
            i(1, "alpine"),
            i(2, " --requirepass mypassword"),
          }
        )
      ),

      -- Nginx reverse proxy
      s(
        "dcnginx",
        fmt(
          [[
  nginx:
    image: nginx:{}
    container_name: nginx
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./certs:/etc/nginx/certs:ro
    depends_on:
      - {}]],
          {
            i(1, "alpine"),
            i(2, "app"),
          }
        )
      ),

      -- Development environment
      s(
        "dcdev",
        fmt(
          [[
version: '3.8'

services:
  {}:
    build:
      context: .
      dockerfile: Dockerfile.dev
    container_name: {}
    restart: unless-stopped
    environment:
      - NODE_ENV=development
    ports:
      - "{}:${}"
    volumes:
      - .:/app
      - /app/node_modules
    command: {}]],
          {
            i(1, "dev"),
            f(function(args)
              return args[1][1]
            end, { 1 }),
            i(2, "3000"),
            f(function(args)
              return args[1][1]
            end, { 2 }),
            i(3, "npm run dev"),
          }
        )
      ),

      -- Full stack setup
      s(
        "dcfullstack",
        fmt(
          [[
version: '3.8'

services:
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: frontend
    restart: unless-stopped
    ports:
      - "{}:${}"
    environment:
      - VITE_API_URL=http://backend:{}

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: backend
    restart: unless-stopped
    ports:
      - "{}:${}"
    environment:
      - DATABASE_URL=postgres://{}:{}@postgres:5432/{}
    depends_on:
      - postgres

  postgres:
    image: postgres:alpine
    container_name: postgres
    restart: unless-stopped
    environment:
      - POSTGRES_USER=${{POSTGRES_USER:-{}}}
      - POSTGRES_PASSWORD=${{POSTGRES_PASSWORD:-{}}}
      - POSTGRES_DB=${{POSTGRES_DB:-{}}}
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:]],
          {
            i(1, "3000"),
            f(function(args)
              return args[1][1]
            end, { 1 }),
            i(2, "5000"),
            f(function(args)
              return args[1][1]
            end, { 2 }),
            f(function(args)
              return args[1][1]
            end, { 2 }),
            i(3, "postgres"),
            i(4, "password"),
            i(5, "myapp"),
            f(function(args)
              return args[1][1]
            end, { 3 }),
            f(function(args)
              return args[1][1]
            end, { 4 }),
            f(function(args)
              return args[1][1]
            end, { 5 }),
          }
        )
      ),
    }

    -- Add snippets to their respective filetypes
    ls.add_snippets("python", python_snippets)
    ls.add_snippets("rust", rust_snippets)
    ls.add_snippets("typescript", ts_snippets)
    ls.add_snippets("typescriptreact", ts_snippets)
    ls.add_snippets("javascript", ts_snippets)
    ls.add_snippets("javascriptreact", ts_snippets)
    ls.add_snippets("go", go_snippets)
    ls.add_snippets("javascript", node_snippets)
    ls.add_snippets("typescript", node_snippets)
    ls.add_snippets("yaml", docker_compose_snippets)
    ls.add_snippets("yml", docker_compose_snippets)
    ls.add_snippets("yaml", kubernetes_snippets)
    ls.add_snippets("yml", kubernetes_snippets)
    ls.add_snippets("dockerfile", docker_snippets)
    ls.add_snippets("docker", docker_snippets)
    ls.add_snippets("markdown", markdown_snippets)
    ls.add_snippets("nix", nix_snippets)
    ls.add_snippets("lua", lua_snippets)
    ls.add_snippets("sql", sql_snippets)
    ls.add_snippets("bash", bash_snippets)
    ls.add_snippets("sh", bash_snippets)
    ls.add_snippets("zsh", bash_snippets)

    -- Configure snippet options
    ls.config.set_config({
      history = true,
      updateevents = "TextChanged,TextChangedI",
      delete_check_events = "TextChanged",
      enable_autosnippets = true,
    })
  end,
}
