local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

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

return go_snippets
