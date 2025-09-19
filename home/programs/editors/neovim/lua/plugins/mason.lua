-- Mason and LSP configuration
return {
  -- Mason package manager for external tools
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    -- Load Mason earlier in the startup process
    lazy = false,
    priority = 100,
    opts = {
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
      -- Configure path to Nix Python installation
      PATH = "append",
      -- Add your nix-darwin Python path
      -- This will make Mason use the Python from nix-darwin
      registries = {
        -- Override the default registry
        "github:mason-org/mason-registry",
      },
      -- We'll handle installation through mason-tool-installer instead
      auto_install = false,
      -- Ensure Mason can find the right installation paths
      install_root_dir = vim.fn.stdpath("data") .. "/mason",
    },
    -- Set up Mason to use the nix-darwin Python
    config = function(_, opts)
      require("mason").setup(opts)

      -- Get the path to the nix-darwin Python
      local handle = io.popen("which python3")
      local python_path = handle:read("*a"):gsub("\n$", "")
      handle:close()

      -- Set the Python path for Mason
      vim.g.mason_python_executable = python_path

      -- Configure Mason to use python3 -m pip instead of direct pip command
      -- This is more reliable in Nix environments
      vim.g.mason_pip_cmd = python_path .. " -m pip"

      -- Check if pip module is available
      local pip_check_cmd = python_path .. " -c 'import pip; print(pip.__version__)' 2>/dev/null || echo 'not found'"
      local pip_check = io.popen(pip_check_cmd)
      local pip_result = pip_check:read("*a")
      pip_check:close()

      if not pip_result:match("not found") then
        -- Pip module is available, we can use python3 -m pip
        return
      end

      -- Check for pip3 executable as fallback
      local pip3_check = io.popen("which pip3 2>/dev/null || echo 'not found'")
      local pip3_path = pip3_check:read("*a"):gsub("\n$", "")
      pip3_check:close()

      if pip3_path ~= "not found" then
        -- Use pip3 directly if available
        vim.g.mason_pip_cmd = pip3_path
        return
      end

      -- If we get here, pip is not available in any form
      vim.notify(
        "Mason: pip not found in nix Python. Some Python-based tools may not install correctly.\n"
          .. "Consider adding 'python3Packages.pip' to your nix packages.",
        vim.log.levels.WARN
      )
    end,
  },

  -- Mason LSP configuration - bridges Mason with Neovim's LSP
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    -- Load earlier in the startup process
    lazy = false,
    priority = 90,
    config = function()
      local lspconfig = require("lspconfig")

      -- First, set up the server mappings for mason-lspconfig
      -- This ensures mason-lspconfig knows how to map package names to lspconfig names
      local mason_lspconfig = require("mason-lspconfig")

      -- The mason registry uses different names than lspconfig for some servers
      -- We need to register these mappings
      require("mason-lspconfig.mappings.server").lspconfig_to_package.tsserver = "typescript-language-server"

      -- Setup mason-lspconfig with autoload handlers
      mason_lspconfig.setup({
        -- Automatically install LSP servers
        automatic_installation = true,
      })

      -- Set up handlers separately after the mappings are established
      mason_lspconfig.setup_handlers({
        -- Default handler for all servers
        function(server_name)
          lspconfig[server_name].setup({})
        end,

        -- Special configuration for specific servers
        ["tsserver"] = function()
          lspconfig.tsserver.setup({
            -- TypeScript-specific settings
            settings = {
              typescript = {
                inlayHints = {
                  includeInlayParameterNameHints = "all",
                  includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                  includeInlayFunctionParameterTypeHints = true,
                  includeInlayVariableTypeHints = true,
                  includeInlayPropertyDeclarationTypeHints = true,
                  includeInlayFunctionLikeReturnTypeHints = true,
                  includeInlayEnumMemberValueHints = true,
                },
              },
              javascript = {
                inlayHints = {
                  includeInlayParameterNameHints = "all",
                  includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                  includeInlayFunctionParameterTypeHints = true,
                  includeInlayVariableTypeHints = true,
                  includeInlayPropertyDeclarationTypeHints = true,
                  includeInlayFunctionLikeReturnTypeHints = true,
                  includeInlayEnumMemberValueHints = true,
                },
              },
            },
          })
        end,

        -- Add custom handler for lua_ls as shown in the article
        ["lua_ls"] = function()
          lspconfig.lua_ls.setup({
            settings = {
              Lua = {
                diagnostics = {
                  globals = { "vim" },
                },
              },
            },
          })
        end,
      })
    end,
  },

  -- Mason Tool Installer - automatically installs and manages LSP servers, DAP servers, linters, and formatters
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    -- Load earlier in the startup process instead of VeryLazy
    lazy = false,
    priority = 80,
    config = function()
      require("mason-tool-installer").setup({
        -- Automatically install listed tools
        auto_install = true,
        -- Run installations when this plugin loads
        run_on_start = true,
        -- Reduce delay to ensure tools are installed quickly
        start_delay = 0, -- No delay
        -- Disable automatic updates to avoid the nil primary_source error
        update_installed = false,
        -- Don't check for new versions
        check_outdated_packages = false,
        ensure_installed = {
          -- Language servers
          "templ",
          "harper-ls",
          "typescript-language-server",
          "html-lsp",
          "css-lsp",
          "json-lsp",
          "eslint-lsp",
          "prettier",
          "tailwindcss-language-server",
          "yaml-language-server",
          "bash-language-server",
          "dockerfile-language-server",

          -- DAP adapters
          "js-debug-adapter",

          -- Language servers for programming languages previously in Nix
          -- "gopls",              -- Go language server
          --"delve",              -- Go debugger
          "intelephense", -- PHP language server
          "rust-analyzer", -- Rust language server
          "lua-language-server", -- Lua language server
          "jdtls", -- Java language server

          -- Additional useful tools
          "stylua",
          "shfmt",
          "shellcheck",

          -- Formatters
          "prettier", -- JavaScript/TypeScript formatter
          "ruff", -- Python formatter and linter
        },
      })

      -- Run the installer when this plugin loads
      vim.api.nvim_create_autocmd("User", {
        pattern = "MasonToolsUpdateCompleted",
        callback = function()
          vim.schedule(function()
            -- Safe notification with pcall to avoid errors
            pcall(function()
              vim.notify("mason-tool-installer: All tools installed! ✓", vim.log.levels.INFO)
            end)
          end)
        end,
      })
    end,
  },
}
