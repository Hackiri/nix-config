local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

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

return rust_snippets
