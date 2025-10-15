# Snippet Modules

This directory contains modular LuaSnip snippets organized by language/framework for better maintainability and faster startup times.

## Structure

```
snippets/
├── init.lua           # Snippet loader (loads all modules)
├── bash.lua           # Shell/Bash snippets
├── docker.lua         # Dockerfile snippets
├── docker_compose.lua # Docker Compose snippets
├── go.lua             # Go snippets
├── kubernetes.lua     # Kubernetes YAML snippets
├── lua_nvim.lua       # Neovim/Lua plugin snippets
├── markdown.lua       # Markdown snippets
├── nix.lua            # Nix expression snippets
├── node.lua           # Node.js/Express snippets
├── python.lua         # Python snippets
├── rust.lua           # Rust snippets
├── sql.lua            # SQL snippets
├── typescript.lua     # TypeScript/JavaScript snippets
└── README.md          # This file
```

## All Implemented Modules

### Programming Languages
- ✅ **Markdown** (20+ snippets) - Code blocks, links, tables, callouts, frontmatter
- ✅ **Python** (5 snippets) - Main, class, function, FastAPI, pytest
- ✅ **Rust** (3 snippets) - Main, struct with impl, test module
- ✅ **TypeScript/JavaScript** (3 snippets) - React components, API handlers, interfaces
- ✅ **Go** (3 snippets) - Main, struct with methods, table tests
- ✅ **Node.js** (8 snippets) - Express server, routes, middleware, MongoDB, Jest
- ✅ **Lua/Neovim** (7 snippets) - Plugin specs, autocmds, keymaps, LSP attach
- ✅ **SQL** (7 snippets) - SELECT with JOIN, CREATE TABLE, INSERT, UPDATE, transactions
- ✅ **Bash/Shell** (9 snippets) - Script headers, functions, error handling, logging

### DevOps & Infrastructure
- ✅ **Nix** (9 snippets) - Flakes, modules, packages, overlays, scripts
- ✅ **Kubernetes** (12 snippets) - Deployments, Services, ConfigMaps, Ingress, StatefulSets
- ✅ **Docker** (8 snippets) - Multi-stage builds for Node/Python/Go/Rust, nginx, .dockerignore
- ✅ **Docker Compose** (7 snippets) - Full-stack setups, databases, dev environments

## To Add More Snippets

### 1. Create a new snippet module

Example: `lua/snippets/typescript.lua`

```lua
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

local typescript_snippets = {
  s("tsinterface", fmt([[
interface {} {{
  {}: {}
}}]], {
    i(1, "InterfaceName"),
    i(2, "property"),
    i(3, "type"),
  })),
}

return typescript_snippets
```

### 2. Register in `init.lua`

Add to the `snippet_modules` table:

```lua
{ filetypes = { "typescript", "typescriptreact" }, module = "snippets.typescript" },
```

### 3. Restart Neovim

Snippets will be loaded automatically on next startup.

## Migration from Old Format

The original `luasnip.lua` had 2,621 lines with all snippets inline. This has been refactored to:

1. **Reduce file size** - Main config is now ~30 lines
2. **Improve startup time** - Smaller files load faster
3. **Better organization** - Each language in its own file
4. **Easier maintenance** - Find and edit snippets quickly

## Available Snippet Triggers

### Markdown
- Code blocks: `bash`, `python`, `javascript`, `typescript`, etc.
- Headers: `h1`, `h2`, `h3`
- Lists: `ul`, `ol`, `cl` (checklist)
- Links: `link`, `linkt` (with target blank)
- Meta: `meta` (frontmatter)
- Callouts: `note`, `warn`, `info`

### Python
- `pymain` - Main script template
- `pyclass` - Class with __init__ and __str__
- `pyfunc` - Function with docstring
- `pyapi` - FastAPI endpoint
- `pytest` - Test function template

## Friendly Snippets

In addition to custom snippets, this setup loads `friendly-snippets` which provides VSCode-style community snippets for many languages.

## Snippet Trigger

**Important:** Custom snippets require the `;` prefix to trigger (configured in `blink-cmp.lua`).

Example:
- Type `;pymain` to expand Python main template
- Type `;bash` to create a bash code block in markdown

This prevents snippet noise during normal coding.
