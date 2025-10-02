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
    ls.add_snippets("markdown", markdown_snippets)

    -- Configure snippet options
    ls.config.set_config({
      history = true,
      updateevents = "TextChanged,TextChangedI",
      delete_check_events = "TextChanged",
      enable_autosnippets = true,
    })
  end,
}
