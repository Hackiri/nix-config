return {
  "nvim-treesitter/nvim-treesitter",
  version = false, -- track main branch; queries/parsers evolve together
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" }, -- Load on buffer read/new
  priority = 1000, -- Give it high priority to load early
  dependencies = {
    { "nvim-treesitter/nvim-treesitter-textobjects", version = false },
    { "nvim-treesitter/nvim-treesitter-context", version = false },
    { "windwp/nvim-ts-autotag", version = "*" },
    { "JoosepAlviste/nvim-ts-context-commentstring", version = "*" },
    { "RRethy/nvim-treesitter-endwise", version = "*" }, -- Auto-add end in Ruby, Lua, etc.
    { "RRethy/nvim-treesitter-textsubjects", version = false }, -- Text objects for text
  },
  -- Define filetype associations as early as possible so detection works for any file open method
  init = function()
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
  end,
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

    -- Configure the core nvim-treesitter plugin (install dir/runtimepath management)
    -- Neovim 0.11 switched to vim.treesitter for highlighting; nvim-treesitter now
    -- focuses on parser management and utilities. No per-module setup here.
    require("nvim-treesitter").setup({})

    -- Ensure parsers for our language list are installed (non-blocking)
    vim.schedule(function()
      local ok, installer = pcall(require, "nvim-treesitter.install")
      if ok then
        pcall(installer.install, ensure_installed, { summary = false })
      end
    end)

    -- Configure textobjects via its own plugin API (new style)
    require("nvim-treesitter-textobjects").setup({
      select = {
        lookahead = true,
        selection_modes = {},
        include_surrounding_whitespace = false,
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
          -- Comment text objects (use capital C to avoid clash with class)
          ["aC"] = "@comment.outer",
          ["iC"] = "@comment.inner",
        },
      },
      move = {
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
      swap = {
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
    })

    -- Configure textsubjects via its own API
    require("nvim-treesitter-textsubjects").configure({
      prev_selection = ",",
      keymaps = {
        ["."] = "textsubjects-smart",
        [";"] = "textsubjects-container-outer",
        ["i;"] = "textsubjects-container-inner",
      },
    })

    -- Keymaps for textobjects (select)
    local map = vim.keymap.set
    for _, mode in ipairs({ "x", "o" }) do
      map(mode, "aa", function()
        require("nvim-treesitter-textobjects.select").select_textobject("@parameter.outer", "textobjects")
      end, { desc = "TS: parameter.outer" })
      map(mode, "ia", function()
        require("nvim-treesitter-textobjects.select").select_textobject("@parameter.inner", "textobjects")
      end, { desc = "TS: parameter.inner" })
      map(mode, "af", function()
        require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
      end, { desc = "TS: function.outer" })
      map(mode, "if", function()
        require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
      end, { desc = "TS: function.inner" })
      map(mode, "ac", function()
        require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
      end, { desc = "TS: class.outer" })
      map(mode, "ic", function()
        require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
      end, { desc = "TS: class.inner" })
      map(mode, "ai", function()
        require("nvim-treesitter-textobjects.select").select_textobject("@conditional.outer", "textobjects")
      end, { desc = "TS: conditional.outer" })
      map(mode, "ii", function()
        require("nvim-treesitter-textobjects.select").select_textobject("@conditional.inner", "textobjects")
      end, { desc = "TS: conditional.inner" })
      map(mode, "al", function()
        require("nvim-treesitter-textobjects.select").select_textobject("@loop.outer", "textobjects")
      end, { desc = "TS: loop.outer" })
      map(mode, "il", function()
        require("nvim-treesitter-textobjects.select").select_textobject("@loop.inner", "textobjects")
      end, { desc = "TS: loop.inner" })
      map(mode, "ab", function()
        require("nvim-treesitter-textobjects.select").select_textobject("@block.outer", "textobjects")
      end, { desc = "TS: block.outer" })
      map(mode, "ib", function()
        require("nvim-treesitter-textobjects.select").select_textobject("@block.inner", "textobjects")
      end, { desc = "TS: block.inner" })
      map(mode, "a/", function()
        require("nvim-treesitter-textobjects.select").select_textobject("@call.outer", "textobjects")
      end, { desc = "TS: call.outer" })
      map(mode, "i/", function()
        require("nvim-treesitter-textobjects.select").select_textobject("@call.inner", "textobjects")
      end, { desc = "TS: call.inner" })
      map(mode, "aC", function()
        require("nvim-treesitter-textobjects.select").select_textobject("@comment.outer", "textobjects")
      end, { desc = "TS: comment.outer" })
      map(mode, "iC", function()
        require("nvim-treesitter-textobjects.select").select_textobject("@comment.inner", "textobjects")
      end, { desc = "TS: comment.inner" })
    end

    -- Keymaps for textobjects (move)
    map({ "n", "x", "o" }, "]m", function()
      require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
    end, { desc = "TS: next function start" })
    map({ "n", "x", "o" }, "]]", function()
      require("nvim-treesitter-textobjects.move").goto_next_start("@class.outer", "textobjects")
    end, { desc = "TS: next class start" })
    map({ "n", "x", "o" }, "]i", function()
      require("nvim-treesitter-textobjects.move").goto_next_start("@conditional.outer", "textobjects")
    end, { desc = "TS: next conditional start" })
    map({ "n", "x", "o" }, "]l", function()
      require("nvim-treesitter-textobjects.move").goto_next_start("@loop.outer", "textobjects")
    end, { desc = "TS: next loop start" })
    map({ "n", "x", "o" }, "]s", function()
      require("nvim-treesitter-textobjects.move").goto_next_start("@statement.outer", "textobjects")
    end, { desc = "TS: next statement start" })
    map({ "n", "x", "o" }, "]z", function()
      require("nvim-treesitter-textobjects.move").goto_next_start("@fold", "folds")
    end, { desc = "TS: next fold" })

    map({ "n", "x", "o" }, "]M", function()
      require("nvim-treesitter-textobjects.move").goto_next_end("@function.outer", "textobjects")
    end, { desc = "TS: next function end" })
    map({ "n", "x", "o" }, "][", function()
      require("nvim-treesitter-textobjects.move").goto_next_end("@class.outer", "textobjects")
    end, { desc = "TS: next class end" })

    map({ "n", "x", "o" }, "[m", function()
      require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
    end, { desc = "TS: prev function start" })
    map({ "n", "x", "o" }, "[[", function()
      require("nvim-treesitter-textobjects.move").goto_previous_start("@class.outer", "textobjects")
    end, { desc = "TS: prev class start" })
    map({ "n", "x", "o" }, "[i", function()
      require("nvim-treesitter-textobjects.move").goto_previous_start("@conditional.outer", "textobjects")
    end, { desc = "TS: prev conditional start" })
    map({ "n", "x", "o" }, "[l", function()
      require("nvim-treesitter-textobjects.move").goto_previous_start("@loop.outer", "textobjects")
    end, { desc = "TS: prev loop start" })
    map({ "n", "x", "o" }, "[s", function()
      require("nvim-treesitter-textobjects.move").goto_previous_start("@statement.outer", "textobjects")
    end, { desc = "TS: prev statement start" })
    map({ "n", "x", "o" }, "[z", function()
      require("nvim-treesitter-textobjects.move").goto_previous_start("@fold", "folds")
    end, { desc = "TS: prev fold" })

    map({ "n", "x", "o" }, "[M", function()
      require("nvim-treesitter-textobjects.move").goto_previous_end("@function.outer", "textobjects")
    end, { desc = "TS: prev function end" })
    map({ "n", "x", "o" }, "[]", function()
      require("nvim-treesitter-textobjects.move").goto_previous_end("@class.outer", "textobjects")
    end, { desc = "TS: prev class end" })

    -- Keymaps for textobjects (swap)
    map("n", "<leader>a", function()
      require("nvim-treesitter-textobjects.swap").swap_next("@parameter.inner", "textobjects")
    end, { desc = "TS: swap next param" })
    map("n", "<leader>A", function()
      require("nvim-treesitter-textobjects.swap").swap_previous("@parameter.inner", "textobjects")
    end, { desc = "TS: swap prev param" })

    -- Configure autotag explicitly with supported filetypes
    require("nvim-ts-autotag").setup({
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
    })

    -- Folding configuration is handled in `config/folding.lua` (LSP-based by default)

    -- Performance optimization
    vim.opt.maxmempattern = 10000 -- Increase max memory for pattern matching
    vim.opt.regexpengine = 1 -- Use new regexp engine
  end,
}
