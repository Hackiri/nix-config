return {
  {
    "neovim/nvim-lspconfig",
    version = "*",
    dependencies = {
      "saghen/blink.cmp",
      -- Useful status updates for LSP
      { "j-hui/fidget.nvim", version = "*", opts = {} },
      -- Automatically install LSPs and related tools to stdpath for neovim
      { "mason-org/mason-lspconfig.nvim", version = "*" },
      { "WhoIsSethDaniel/mason-tool-installer.nvim", version = "*" },
    },
    config = function()
      -- Get enhanced LSP capabilities from blink.cmp
      local capabilities = require("blink.cmp").get_lsp_capabilities()
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

      -- Setup servers with enhanced capabilities
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              runtime = { version = "LuaJIT" },
              workspace = {
                checkThirdParty = false,
                library = {
                  "${3rd}/luv/library",
                  unpack(vim.api.nvim_get_runtime_file("", true)),
                },
              },
              completion = {
                callSnippet = "Replace",
              },
              telemetry = { enable = false },
              diagnostics = { disable = { "missing-fields" } },
            },
          },
        },
        nixd = {
          cmd = { "nixd" },
          filetypes = { "nix" },
          root_dir = function(fname)
            return lspconfig.util.root_pattern(".git", "flake.nix", "shell.nix")(fname)
              or lspconfig.util.find_git_ancestor(fname)
              or vim.fn.getcwd()
          end,
          single_file_support = true,
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
        -- Add other servers with basic setup
        rust_analyzer = {},
        pylsp = {},
        ts_ls = {},
        html = {},
        dockerls = {},
        docker_compose_language_service = {},
        ruff = {},
        tailwindcss = {},
        taplo = {},
        jsonls = {},
        sqlls = {},
        terraformls = {},
        yamlls = {},
        bashls = {},
        graphql = {},
        cssls = {},
        texlab = {},
      }

      -- Define servers that are installed via Nix and should not be managed by Mason
      local nix_installed_servers = {
        nixd = true,
        -- Add other servers installed via Nix here
      }

      -- Filter out servers installed via Nix
      local mason_servers = {}
      for server_name, _ in pairs(servers) do
        if not nix_installed_servers[server_name] then
          mason_servers[server_name] = true
        end
      end

      -- Setup mason-lspconfig: ensure servers are installed. We'll configure via vim.lsp.config
      require("mason-lspconfig").setup({
        ensure_installed = vim.tbl_keys(mason_servers),
        automatic_installation = false,
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

      -- Configure all servers using native Neovim API
      for server_name, server in pairs(servers) do
        server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
        vim.lsp.config(server_name, server)
      end

      -- Enable all configured servers
      for server_name, _ in pairs(servers) do
        vim.lsp.enable(server_name)
      end

      -- Ensure non-LSP tools are installed (LSP servers handled by mason-lspconfig)
      local ensure_installed = {
        "stylua", -- Lua formatter
        "shfmt", -- Shell formatter
        "shellcheck", -- Shell linter
        "prettier", -- JS/TS formatter
        "ruff", -- Python linter/formatter CLI
        "js-debug-adapter", -- DAP adapter for JS/TS
        "templ", -- Go template formatter
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
          map("<leader>ld", require("telescope.builtin").lsp_definitions, "[L]SP [D]efinition")
          map("<leader>lr", require("telescope.builtin").lsp_references, "[L]SP [R]eferences")
          map("<leader>li", require("telescope.builtin").lsp_implementations, "[L]SP [I]mplementation")
          map("<leader>lt", require("telescope.builtin").lsp_type_definitions, "[L]SP [T]ype Definition")
          map("<leader>ls", require("telescope.builtin").lsp_document_symbols, "[L]SP Document [S]ymbols")
          map("<leader>lw", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[L]SP [W]orkspace Symbols")
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

          -- Document highlight
          if client and client.server_capabilities.documentHighlightProvider then
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })

      -- Configure diagnostics
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
        },
        signs = true,
        update_in_insert = false,
      })
    end,
  },
}
