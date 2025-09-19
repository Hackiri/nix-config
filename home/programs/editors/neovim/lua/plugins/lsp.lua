return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "saghen/blink.cmp",
      -- Useful status updates for LSP
      { "j-hui/fidget.nvim", opts = {} },
      -- Automatically install LSPs and related tools to stdpath for neovim
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    config = function()
      -- Get enhanced LSP capabilities from blink.cmp
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      local lspconfig = require("lspconfig")

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

      -- Setup mason-lspconfig
      require("mason-lspconfig").setup({
        ensure_installed = vim.tbl_keys(mason_servers),
        automatic_installation = false,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for ts_ls)
            server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
            require("lspconfig")[server_name].setup(server)
          end,
        },
      })

      -- Setup Nix-installed servers manually
      for server_name, _ in pairs(nix_installed_servers) do
        if servers[server_name] then
          local server = servers[server_name]
          server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
          require("lspconfig")[server_name].setup(server)
        end
      end

      -- Ensure the tools are installed
      local ensure_installed = {
        "stylua", -- Used to format Lua code
        -- Don't include nixpkgs-fmt as it's managed by Nix
      }
      require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

      -- LSP handlers
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = "rounded",
      })

      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
        border = "rounded",
      })

      -- LSP Attach Keybindings
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)

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
          if client.supports_method("textDocument/formatting") then
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
