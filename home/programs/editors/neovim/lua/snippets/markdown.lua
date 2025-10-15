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

return markdown_snippets
