return {
  "nvim-treesitter/nvim-treesitter",
  version = false, -- track main branch; queries/parsers evolve together
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" }, -- Load on buffer read/new
  priority = 1000, -- Give it high priority to load early
  dependencies = {
    { "nvim-treesitter/nvim-treesitter-textobjects", version = false },
    { "nvim-treesitter/nvim-treesitter-refactor", version = false },
    { "nvim-treesitter/nvim-treesitter-context", version = false },
    { "windwp/nvim-ts-autotag", version = "*" },
    { "JoosepAlviste/nvim-ts-context-commentstring", version = "*" },
    { "nvim-treesitter/playground", version = false },
    { "RRethy/nvim-treesitter-endwise", version = "*" }, -- Auto-add end in Ruby, Lua, etc.
    { "RRethy/nvim-treesitter-textsubjects", version = false }, -- Text objects for text
  },
  config = function()
    -- Skip ts_context_commentstring module
    vim.g.skip_ts_context_commentstring_module = true

    -- Set up ts_context_commentstring
    require("ts_context_commentstring").setup({})

    -- Define language groups for better organization
    local language_groups = {
      -- Web Development
      web = {
        "html",
        "css",
        "scss", -- Added scss
        "javascript",
        "typescript",
        "tsx",
        "vue",
        "svelte",
        "graphql",
        "json",
        "jsonc",
        "xml",
      },
      -- Backend Development
      backend = {
        "python",
        "java",
        "go",
        "rust",
        "ruby",
        "php",
        "c",
        "cpp",
        "c_sharp",
        "kotlin",
        "scala",
      },
      -- System and DevOps
      system = {
        "bash",
        "fish",
        "dockerfile",
        "terraform",
        "hcl",
        "make",
        "cmake",
        "perl",
        "regex",
        "toml",
        "awk",
      },
      -- Data and Config
      data = {
        "yaml",
        "json",
        "toml",
        "ini",
        "sql",
        "graphql",
        "proto",
      },
      -- Documentation and Markup
      docs = {
        "markdown",
        "markdown_inline",
        "vimdoc",
        "rst",
        "latex",
        "bibtex",
        "norg", -- Added norg (Neorg)
        "typst", -- Added typst
      },
      -- Version Control
      vcs = {
        "git_config",
        "gitattributes",
        "gitcommit",
        "gitignore",
        "diff",
      },
      -- Scripting and Config
      scripting = {
        "lua",
        "vim",
        "query",
        "regex",
        "jq",
        "nix",
        "groovy",
      },
    }

    -- Flatten language groups into a single list
    local ensure_installed = {}
    for _, group in pairs(language_groups) do
      for _, lang in ipairs(group) do
        table.insert(ensure_installed, lang)
      end
    end

    require("nvim-treesitter.configs").setup({
      -- Basic Setup
      ensure_installed = ensure_installed,
      auto_install = true,
      sync_install = false,
      ignore_install = {},

      -- Required modules field
      modules = {},

      -- Highlighting
      highlight = {
        enable = true,
        disable = {},
        additional_vim_regex_highlighting = false,
      },

      -- Indentation
      indent = {
        enable = true,
        disable = { "python", "c", "cpp" }, -- Languages where treesitter indent might be problematic
      },

      -- Incremental selection (disabled in favor of flash.nvim Treesitter mode)
      incremental_selection = {
        enable = false,
        keymaps = {
          init_selection = "<Leader>ts",
          node_incremental = "<Leader>ti",
          node_decremental = "<Leader>td",
          scope_incremental = "<Leader>tc",
        },
      },

      textsubjects = {
        enable = true,
        keymaps = {
          ["."] = "textsubjects-smart",
          [";"] = "textsubjects-container-outer",
        },
      },

      -- Text objects
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            -- Parameter/Argument text objects
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",

            -- Function text objects
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",

            -- Class text objects
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",

            -- Conditional text objects
            ["ai"] = "@conditional.outer",
            ["ii"] = "@conditional.inner",

            -- Loop text objects
            ["al"] = "@loop.outer",
            ["il"] = "@loop.inner",

            -- Block text objects
            ["ab"] = "@block.outer",
            ["ib"] = "@block.inner",

            -- Call text objects
            ["a/"] = "@call.outer",
            ["i/"] = "@call.inner",

            -- Comment text objects
            ["ac"] = "@comment.outer",
            ["ic"] = "@comment.inner",
          },
        },

        -- Moving between text objects
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            ["]m"] = "@function.outer",
            ["]]"] = "@class.outer",
            ["]i"] = "@conditional.outer",
            ["]l"] = "@loop.outer",
            ["]s"] = "@statement.outer",
            ["]z"] = "@fold.outer",
          },
          goto_next_end = {
            ["]M"] = "@function.outer",
            ["]["] = "@class.outer",
            ["]Z"] = "@fold.outer",
          },
          goto_previous_start = {
            ["[m"] = "@function.outer",
            ["[["] = "@class.outer",
            ["[i"] = "@conditional.outer",
            ["[l"] = "@loop.outer",
            ["[s"] = "@statement.outer",
            ["[z"] = "@fold.outer",
          },
          goto_previous_end = {
            ["[M"] = "@function.outer",
            ["[]"] = "@class.outer",
            ["[Z"] = "@fold.outer",
          },
        },

        -- Swapping elements
        swap = {
          enable = true,
          swap_next = {
            ["<leader>a"] = "@parameter.inner",
            ["<leader>f"] = "@function.outer",
            ["<leader>e"] = "@element",
          },
          swap_previous = {
            ["<leader>A"] = "@parameter.inner",
            ["<leader>F"] = "@function.outer",
            ["<leader>E"] = "@element",
          },
        },

        -- LSP interop
        lsp_interop = {
          enable = true,
          border = "rounded",
          floating_preview_opts = {},
          peek_definition_code = {
            ["<leader>df"] = "@function.outer",
            ["<leader>dF"] = "@class.outer",
          },
        },
      },

      -- Additional modules
      matchup = {
        enable = true, -- mandatory, false will disable the whole extension
        disable = {}, -- optional, list of language that will be disabled
        disable_virtual_text = false,
        include_match_words = true,
      },

      autotag = {
        enable = true,
        filetypes = {
          "html",
          "javascript",
          "typescript",
          "javascriptreact",
          "typescriptreact",
          "svelte",
          "vue",
          "tsx",
          "jsx",
          "rescript",
          "xml",
          "php",
          "markdown",
          "astro",
          "glimmer",
          "handlebars",
          "hbs",
        },
      },

      context_commentstring = {
        enable = false,
      },

      endwise = {
        enable = true,
      },

      -- Playground configuration
      playground = {
        enable = true,
        disable = {},
        updatetime = 25,
        persist_queries = true,
        keybindings = {
          toggle_query_editor = "o",
          toggle_hl_groups = "i",
          toggle_injected_languages = "t",
          toggle_anonymous_nodes = "a",
          toggle_language_display = "I",
          focus_language = "f",
          unfocus_language = "F",
          update = "R",
          goto_node = "<cr>",
          show_help = "?",
        },
      },
    })

    -- File type associations
    local filetypes = {
      terraform = { "tf", "tfvars", "terraform" },
      groovy = { "pipeline", "Jenkinsfile", "groovy" },
      python = { "py", "pyi", "pyx", "pxd" },
      yaml = { "yaml", "yml" },
      dockerfile = { "Dockerfile", "dockerfile" },
      ruby = { "rb", "rake", "gemspec" },
      javascript = { "js", "jsx", "mjs" },
      typescript = { "ts", "tsx" },
      rust = { "rs", "rust" },
      nix = { "nix" },
    }

    for filetype, extensions in pairs(filetypes) do
      for _, ext in ipairs(extensions) do
        vim.filetype.add({ extension = { [ext] = filetype } })
      end
    end

    -- Folding configuration is handled in `config/folding.lua` (LSP-based by default)

    -- Performance optimization
    vim.opt.maxmempattern = 10000 -- Increase max memory for pattern matching
    vim.opt.regexpengine = 1 -- Use new regexp engine
  end,
}
