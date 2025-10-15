local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

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

return node_snippets
