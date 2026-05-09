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

  -- Module declaration
  s("rsmod", fmt("mod {};", { i(1, "module") })),

  -- Use statement
  s("rsuse", fmt("use {};", { i(1, "crate::module") })),

  -- Derive macro
  s("rsderive", fmt("#[derive({})]", { i(1, "Debug, Clone") })),

  -- Match expression
  s(
    "rsmatch",
    fmt(
      [[
match {} {{
    {} => {},
}}]],
      {
        i(1, "expression"),
        i(2, "pattern"),
        i(3, "result"),
      }
    )
  ),

  -- If let Some pattern
  s(
    "rsiflet",
    fmt(
      [[
if let Some({}) = {} {{
    {}
}}]],
      {
        i(1, "value"),
        i(2, "option"),
        i(3, "// body"),
      }
    )
  ),

  -- Enum definition
  s(
    "rsenum",
    fmt(
      [[
enum {} {{
    {},
}}]],
      {
        i(1, "Name"),
        i(2, "Variant"),
      }
    )
  ),

  -- Trait definition
  s(
    "rstrait",
    fmt(
      [[
trait {} {{
    fn {}(&self) -> {};
}}]],
      {
        i(1, "Name"),
        i(2, "method"),
        i(3, "ReturnType"),
      }
    )
  ),

  -- Function definition
  s(
    "rsfn",
    fmt(
      [[
fn {}({}) -> {} {{
    {}
}}]],
      {
        i(1, "name"),
        i(2, "params"),
        i(3, "()"),
        i(4, "// body"),
      }
    )
  ),

  -- Async function definition
  s(
    "rsasyncfn",
    fmt(
      [[
async fn {}({}) -> {} {{
    {}
}}]],
      {
        i(1, "name"),
        i(2, "params"),
        i(3, "()"),
        i(4, "// body"),
      }
    )
  ),

  -- Println for debugging
  s("rsprintln", fmt('println!("{{:?}}", {});', { i(1, "value") })),

  -- Basic custom error implementation
  s(
    "rserror",
    fmt(
      [[
#[derive(Debug)]
pub enum {}Error {{
    {}
}}

impl std::fmt::Display for {}Error {{
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {{
        match self {{
            {}
        }}
    }}
}}

impl std::error::Error for {}Error {{}}]],
      {
        i(1, "Type"),
        i(2, "Variant,"),
        f(function(args)
          return args[1][1]
        end, { 1 }),
        i(3, "// Display variants"),
        f(function(args)
          return args[1][1]
        end, { 1 }),
      }
    )
  ),
}

return rust_snippets
