-- LSP Configuration
-- This config is compatible with Neovim 0.11+ which introduces:
--   - New vim.lsp.config() and vim.lsp.enable() APIs (used below)
--   - Default keymaps: grn, grr, gri, gra, grt, gO, <C-S> (overridden in keymaps.lua)
--   - Virtual text diagnostics now opt-in (explicitly enabled below)
--   - New diagnostic display options: only_current_line, virtual_lines
-- See: https://gpanders.com/blog/whats-new-in-neovim-0-11/

return {
  {
    "neovim/nvim-lspconfig",
    version = "*",
    event = { "BufReadPre", "BufNewFile" }, -- Load LSP when opening files
    dependencies = {
      "saghen/blink.cmp",
      "mason-org/mason.nvim",
      -- Automatically install LSPs and related tools to stdpath for neovim
      { "mason-org/mason-lspconfig.nvim", version = "2.*" }, -- LazyVim 15.x requires v2.x
      { "WhoIsSethDaniel/mason-tool-installer.nvim", version = "*" },
    },

    config = function()
      -- Get enhanced LSP capabilities from blink.cmp
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      -- Disable workspace file watching to prevent constant reloads
      -- LSP servers will still receive file change notifications from Neovim,
      -- but won't trigger full workspace reloads on every edit
      capabilities.workspace = capabilities.workspace or {}
      capabilities.workspace.didChangeWatchedFiles = {
        dynamicRegistration = false,
        relativePatternSupport = false,
      }

      local lspconfig = require("lspconfig")

      -- Stylua is a FORMATTER, not an LSP server.
      -- Mason might try to start it as LSP which causes "exit code 2" error.
      -- We format Lua via conform.nvim instead.
      -- Aggressively prevent stylua from being started as an LSP server.

      -- Method 1: Disable in lspconfig if it exists
      pcall(function()
        require("lspconfig.configs").stylua = nil
      end)

      -- Method 2: Override vim.lsp.start to block stylua
      local original_lsp_start = vim.lsp.start
      vim.lsp.start = function(config, opts)
        if config and (config.name == "stylua" or config.cmd and config.cmd[1] and config.cmd[1]:match("stylua")) then
          -- Silently refuse to start stylua as LSP
          return nil
        end
        return original_lsp_start(config, opts)
      end

      -- Configure servers using vim.lsp.config with root_markers
      -- This uses the new Neovim 0.11+ API which is simpler and more maintainable
      --
      -- Strategy: Only specify root_markers when:
      --   1. We need custom behavior beyond lspconfig defaults
      --   2. We want to prevent false positives (e.g., tailwindcss)
      --   3. We've improved the defaults (e.g., added go.work, shell.nix)
      --
      -- For simple servers, we omit root_markers to use lspconfig's well-tested defaults
      local servers = {
        lua_ls = {
          -- Use lspconfig defaults: .luarc.json, .luarc.jsonc, .luacheckrc, stylua.toml, .git
          settings = {
            Lua = {
              runtime = { version = "LuaJIT" },
              workspace = {
                checkThirdParty = false,
                ignoreDir = {
                  ".direnv/",
                  ".git/",
                  ".jj/",
                  "__pycache__/",
                  "_build",
                  "result",
                },
                useGitIgnore = true,
                library = vim.api.nvim_get_runtime_file("", true),
              },
              completion = {
                workspaceWord = true,
                callSnippet = "Both",
              },
              hint = {
                enable = true,
                setType = false,
                paramType = true,
                paramName = "Disable",
                semicolon = "Disable",
                arrayIndex = "Disable",
              },
              codeLens = {
                enable = true,
              },
              doc = {
                privateName = { "^_" },
              },
              type = {
                castNumberToInteger = true,
              },
              telemetry = { enable = false },
              diagnostics = {
                disable = { "incomplete-signature-doc", "trailing-space", "missing-fields" },
                groupSeverity = {
                  strong = "Warning",
                  strict = "Warning",
                },
                groupFileStatus = {
                  ["ambiguity"] = "Opened",
                  ["await"] = "Opened",
                  ["codestyle"] = "None",
                  ["duplicate"] = "Opened",
                  ["global"] = "Opened",
                  ["luadoc"] = "Opened",
                  ["redefined"] = "Opened",
                  ["strict"] = "Opened",
                  ["strong"] = "Opened",
                  ["type-check"] = "Opened",
                  ["unbalanced"] = "Opened",
                  ["unused"] = "Opened",
                },
                unusedLocalExclude = { "_*" },
              },
              format = {
                enable = false,
                defaultConfig = {
                  indent_style = "space",
                  indent_size = "2",
                  continuation_indent_size = "2",
                },
              },
            },
          },
        },
        -- Simple servers - use lspconfig defaults
        svelte = {},
        tinymist = {},
        emmet_ls = {},
        prismals = {}, -- Prisma ORM
        eslint = {}, -- JavaScript/TypeScript linter
        nixd = {
          cmd = { "nixd" },
          filetypes = { "nix" },
          -- Custom: Added shell.nix (lspconfig default: flake.nix, default.nix, .git)
          root_markers = { { "flake.nix", "shell.nix" }, ".git" },
          flags = {
            debounce_text_changes = 150,
          },
          settings = {
            nixd = {
              formatting = {
                command = "nixpkgs-fmt",
              },
              options = {
                enable = true,
                target = {
                  args = {},
                  installable = ".#",
                },
              },
              eval = {
                target = {
                  args = {},
                  installable = ".#",
                },
                depth = 0,
                workers = 3,
              },
            },
          },
        },
        rust_analyzer = {
          -- Use lspconfig defaults: Cargo.toml, rust-project.json, .git
          settings = {
            ["rust-analyzer"] = {
              cargo = {
                allFeatures = true, -- Load all cargo features into workspace
                loadOutDirsFromCheck = true, -- Load build script outputs
              },
              procMacro = {
                enable = true, -- Enable proc macro expansion in workspace
              },
              checkOnSave = {
                command = "clippy", -- Use clippy for workspace-wide diagnostics
              },
              workspace = {
                symbol = {
                  search = {
                    kind = "all_symbols", -- Search all symbols in workspace
                  },
                },
              },
            },
          },
        },
        pylsp = {
          -- Use lspconfig defaults: pyproject.toml, setup.py, setup.cfg, requirements.txt, Pipfile, .git
          settings = {
            pylsp = {
              plugins = {
                mypy = { enabled = true },
                jedi = {
                  environment = vim.env.VIRTUAL_ENV, -- Use active virtual environment
                  extra_paths = {}, -- Can add custom paths if needed
                },
                pylsp_mypy = {
                  enabled = true,
                  live_mode = true, -- Real-time type checking
                },
                rope_autoimport = {
                  enabled = true, -- Enable auto-import from workspace
                },
              },
            },
          },
        },
        gopls = {
          -- Custom: Added go.work for multi-module workspaces (lspconfig default: go.mod, .git)
          root_markers = { { "go.mod", "go.work" }, ".git" },
          settings = {
            gopls = {
              experimentalWorkspaceModule = true, -- Multi-module workspace support
              analyses = {
                unusedparams = true,
                shadow = true,
                unusedvariable = true,
              },
              staticcheck = true, -- Enable staticcheck for workspace
              gofumpt = true, -- Stricter formatting
              codelenses = {
                gc_details = true,
                generate = true,
                regenerate_cgo = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
              },
            },
          },
        },
        vtsls = {
          -- Custom: Explicit markers to prevent unwanted activation (matches lspconfig defaults)
          -- NOTE: single_file_support is intentionally NOT disabled here to allow flexibility
          root_markers = { { "package.json", "tsconfig.json", "jsconfig.json" }, ".git" },
          filetypes = {
            "javascript",
            "javascriptreact",
            "javascript.jsx",
            "typescript",
            "typescriptreact",
            "typescript.tsx",
          },
          settings = {
            vtsls = {
              -- Minimal settings for better performance
              typescript = {
                updateImportsOnFileMove = { enabled = "always" },
                suggest = {
                  completeFunctionCalls = false, -- Disable for better performance
                },
                inlayHints = {
                  parameterNames = { enabled = "none" }, -- Disable for performance
                  parameterTypes = { enabled = false },
                  variableTypes = { enabled = false },
                  propertyDeclarationTypes = { enabled = false },
                  functionLikeReturnTypes = { enabled = false },
                  enumMemberValues = { enabled = false },
                },
              },
              javascript = {
                updateImportsOnFileMove = { enabled = "always" },
                suggest = {
                  completeFunctionCalls = false,
                },
                inlayHints = {
                  parameterNames = { enabled = "none" },
                  parameterTypes = { enabled = false },
                  variableTypes = { enabled = false },
                  propertyDeclarationTypes = { enabled = false },
                  functionLikeReturnTypes = { enabled = false },
                  enumMemberValues = { enabled = false },
                },
              },
            },
          },
        },
        -- Simple servers - use lspconfig defaults
        html = {},
        jsonls = {},
        sqlls = {},
        taplo = {},
        bashls = {},
        cssls = {},
        graphql = {},

        -- Servers with specific project detection needs
        dockerls = {
          -- Custom: Detect Docker projects specifically
          root_markers = { { "Dockerfile", "docker-compose.yml", "docker-compose.yaml" }, ".git" },
        },
        docker_compose_language_service = {
          -- Custom: Detect Docker Compose projects
          root_markers = { { "docker-compose.yml", "docker-compose.yaml", "compose.yml", "compose.yaml" }, ".git" },
        },
        ruff = {
          -- Custom: Python linter with specific config detection
          root_markers = { { "pyproject.toml", "ruff.toml", ".ruff.toml" }, ".git" },
        },
        tailwindcss = {
          -- Custom: Prevent false positives - only activate with tailwind config
          root_markers = { { "tailwind.config.js", "tailwind.config.ts", "tailwind.config.cjs" }, ".git" },
        },
        terraformls = {
          -- Custom: Infrastructure as code project detection
          root_markers = { { ".terraform", "terraform.tfvars" }, ".git" },
        },
        yamlls = {
          settings = {
            yaml = {
              keyOrdering = false,
            },
            redhat = {
              telemetry = {
                enabled = false,
              },
            },
          },
        },
        texlab = {
          -- Use lspconfig defaults for LaTeX projects
        },
      }

      -- Define servers that are installed via Nix and should not be managed by Mason
      local nix_installed_servers = {
        nixd = true,
        -- Add other servers installed via Nix here
      }

      -- Filter out servers installed via Nix to create Mason's ensure_installed list
      -- This automatically includes all servers from the 'servers' table except Nix-managed ones
      -- Current Mason-managed servers: ts_ls→vtsls, html, cssls, tailwindcss, svelte,
      --   lua_ls, graphql, emmet_ls, prismals, pylsp, eslint, rust_analyzer, gopls,
      --   dockerls, docker_compose_language_service, ruff, terraformls, yamlls,
      --   jsonls, sqlls, taplo, bashls, texlab, tinymist
      local mason_servers = {}
      for server_name, _ in pairs(servers) do
        if not nix_installed_servers[server_name] then
          mason_servers[server_name] = true
        end
      end

      -- Setup mason-lspconfig: ensure servers are installed. We'll configure via vim.lsp.config
      -- mason-lspconfig bridges mason.nvim (package manager) with nvim-lspconfig
      -- It automatically installs LSP servers listed in ensure_installed using mason.nvim
      require("mason-lspconfig").setup({
        ensure_installed = vim.tbl_keys(mason_servers),
        automatic_installation = false, -- We control installation explicitly
        -- Explicitly prevent stylua from being configured as an LSP
        -- (it's a formatter, not an LSP server)
        handlers = {
          -- Default handler for all servers
          function(server_name)
            -- Skip stylua - it's not an LSP server
            if server_name == "stylua" then
              return
            end
          end,
        },
      })

      -- Configure all servers using vim.lsp.config (new 0.11+ API)
      -- This defines the configurations but doesn't start them yet
      for server_name, cfg in pairs(servers) do
        cfg.capabilities = vim.tbl_deep_extend("force", {}, capabilities, cfg.capabilities or {})
        vim.lsp.config(server_name, cfg)
      end

      -- Enable all configured LSP servers at once
      -- This tells Neovim to automatically start these servers when appropriate filetypes are opened
      -- Using vim.lsp.enable() with a list is more efficient than individual calls
      vim.lsp.enable(vim.tbl_keys(servers))

      -- Prevent nixd from attaching to shell scripts with nix shebangs
      -- (This section can be removed if not needed - currently it does nothing)
      -- local match_contents = require("vim.filetype.detect").match_contents
      -- require("vim.filetype.detect").match_contents = function(...)
      --   local result = match_contents(...)
      --   -- If you want to prevent nix filetype detection in certain cases, add logic here
      --   return result
      -- end

      -- Ensure non-LSP tools are installed (LSP servers handled by mason-lspconfig)
      -- NOTE: Formatters and linters are now managed via Nix (see default.nix)
      -- This ensures reproducible builds and avoids version conflicts
      local ensure_installed = {
        "js-debug-adapter", -- DAP adapter for JS/TS
        -- Note: The following are now installed via Nix:
        --   stylua, shfmt, shellcheck, prettier, ruff, templ
        -- Note: jsregexp for LuaSnip is provided via Nix extraLuaPackages
      }
      require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

      -- Provide keymaps for Mason Tools commands
      vim.keymap.set("n", "<leader>cmt", "<cmd>MasonToolsInstall<cr>", { desc = "Mason Tools Install" })
      vim.keymap.set("n", "<leader>cmu", function()
        local ok, err = pcall(function()
          vim.cmd("MasonToolsInstall")
        end)
        if not ok then
          vim.notify("Mason tools update failed: " .. tostring(err), vim.log.levels.ERROR)
        end
      end, { desc = "Mason Tools Update" })

      -- LSP Attach Keybindings
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)

          -- Enable LSP-based folding for this buffer
          pcall(function()
            require("config.folding").enable_lsp_folding(event.buf)
          end)

          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          -- Keep your existing keymaps but reorganize under <leader>l prefix
          -- Using fzf-lua for LSP navigation (LazyVim 14.x+ default)
          map("<leader>ld", "<cmd>FzfLua lsp_definitions<cr>", "[L]SP [D]efinition")
          map("<leader>lr", "<cmd>FzfLua lsp_references<cr>", "[L]SP [R]eferences")
          map("<leader>li", "<cmd>FzfLua lsp_implementations<cr>", "[L]SP [I]mplementation")
          map("<leader>lt", "<cmd>FzfLua lsp_typedefs<cr>", "[L]SP [T]ype Definition")
          map("<leader>ls", "<cmd>FzfLua lsp_document_symbols<cr>", "[L]SP Document [S]ymbols")
          map("<leader>lw", "<cmd>FzfLua lsp_workspace_symbols<cr>", "[L]SP [W]orkspace Symbols")
          map("<leader>ln", vim.lsp.buf.rename, "[L]SP Re[n]ame")
          map("<leader>la", vim.lsp.buf.code_action, "[L]SP Code [A]ction")
          map("<leader>lk", vim.lsp.buf.hover, "[L]SP Hover Documentation")
          map("<leader>lD", vim.lsp.buf.declaration, "[L]SP [D]eclaration")
          map("<leader>lwa", vim.lsp.buf.add_workspace_folder, "[L]SP [W]orkspace [A]dd Folder")
          map("<leader>lwr", vim.lsp.buf.remove_workspace_folder, "[L]SP [W]orkspace [R]emove Folder")
          map("<leader>lwl", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, "[L]SP [W]orkspace [L]ist Folders")

          -- Format on save if the client supports it
          -- Skip stylua (it's a formatter, not an LSP) and other non-LSP formatters
          if client and client.name ~= "stylua" and client.supports_method("textDocument/formatting") then
            vim.api.nvim_create_autocmd("BufWritePre", {
              group = vim.api.nvim_create_augroup("format_on_save" .. event.buf, { clear = true }),
              buffer = event.buf,
              callback = function()
                vim.lsp.buf.format({ async = false })
              end,
            })
          end

          -- Document highlight DISABLED - using Snacks.words instead
          -- Snacks.words provides better performance and doesn't cause cursor lag
          -- if client and client.server_capabilities.documentHighlightProvider then
          --   vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
          --     buffer = event.buf,
          --     callback = vim.lsp.buf.document_highlight,
          --   })
          --
          --   vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
          --     buffer = event.buf,
          --     callback = vim.lsp.buf.clear_references,
          --   })
          -- end
        end,
      })

      -- Configure diagnostics
      -- NOTE: Neovim 0.11+ changes:
      --   - Virtual text is now opt-in (disabled by default)
      --   - New 'only_current_line' option available to reduce clutter
      --   - Virtual lines option available (set virtual_lines = true)
      -- We explicitly enable virtual_text here and provide a toggle via <leader>dv
      vim.diagnostic.config({
        severity_sort = true,
        float = { border = "rounded", source = "if_many" },
        underline = { severity = vim.diagnostic.severity.ERROR },
        virtual_text = {
          prefix = "●",
          format = function(diagnostic)
            local code = diagnostic.code and string.format("[%s]", diagnostic.code) or ""
            return string.format("%s %s", code, diagnostic.message)
          end,
          source = "if_many",
          spacing = 2,
          -- Set only_current_line = true to show diagnostics only for the current line
          -- Toggle this via <leader>dv keymap
          only_current_line = false,
        },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.INFO] = " ",
            [vim.diagnostic.severity.HINT] = "󰌵 ",
          },
        },
        update_in_insert = false,
      })
    end,
  },
  -- Override LazyVim LSP keymaps to prevent window reuse on goto definition
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Apply this keymap to all LSP servers
        ["*"] = {
          keys = {
            {
              "gd",
              function()
                -- DO NOT REUSE WINDOW - opens in new split/window
                require("fzf-lua").lsp_definitions({ jump_to_single_result = true, reuse_win = false })
              end,
              desc = "Goto Definition",
              has = "definition",
            },
          },
        },
      },
    },
  },
}
