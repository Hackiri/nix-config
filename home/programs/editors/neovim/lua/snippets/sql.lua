local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

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

return sql_snippets
