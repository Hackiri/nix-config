local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

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
      s("shfor", fmt("for {} in {}; do\n  {}\ndone", { i(1, "item"), i(2, "items"), i(3, "# body") })),

      -- While read loop
      s(
        "shwhile",
        fmt("while IFS= read -r {}; do\n  {}\ndone < {}", { i(1, "line"), i(2, "# process line"), i(3, "file") })
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

return bash_snippets
