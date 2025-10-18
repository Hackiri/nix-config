local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

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

return ts_snippets
