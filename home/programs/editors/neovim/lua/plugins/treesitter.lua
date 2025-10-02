-- nvim-treesitter configuration for MAIN branch
-- This is the new, minimal API that requires manual highlighting setup

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main", -- Modern rewrite with minimal API
  build = ":TSUpdate", -- Official recommendation from main branch README
  lazy = false, -- Load immediately
  
  dependencies = {
    -- NOTE: These plugins may need updates for main branch compatibility
    { "nvim-treesitter/nvim-treesitter-textobjects" }, -- Let it use default branch
    { "nvim-treesitter/nvim-treesitter-context", version = "*" }, -- Show context at top
    { "windwp/nvim-ts-autotag", version = "*" },
    { "JoosepAlviste/nvim-ts-context-commentstring", version = "*" },
    { "RRethy/nvim-treesitter-endwise", version = "*" }, -- Auto-add end in Ruby, Lua, etc.
    { "RRethy/nvim-treesitter-textsubjects", version = false }, -- Smart text selection
  },
  
  init = function(plugin)
    -- Add to runtimepath EARLY so treesitter is available
    require("lazy.core.loader").add_to_rtp(plugin)
    
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
    
    -- ========================================================================
    -- SETUP AUTOCMDS EARLY (in init, not config)
    -- ========================================================================
    -- This ensures autocmds are registered BEFORE files are opened from explorers
    
    local highlight_filetypes = {
      "lua", "python", "javascript", "typescript", "tsx", "jsx",
      "rust", "go", "java", "c", "cpp", "ruby", "php",
      "html", "css", "scss", "json", "yaml", "toml",
      "bash", "fish", "markdown", "vim", "nix", "terraform",
      "dockerfile", "sql", "graphql", "vue", "svelte",
    }
    
    local indent_filetypes = {
      "lua", "javascript", "typescript", "tsx", "jsx",
      "rust", "go", "java", "c", "cpp", "ruby", "php",
      "html", "css", "json", "vim", "nix",
    }
    
    local fold_filetypes = {
      "lua", "python", "javascript", "typescript", "tsx", "jsx",
      "rust", "go", "java", "c", "cpp", "ruby",
    }
    
    -- Highlighting autocmd - using multiple events for maximum coverage
    -- This catches files opened from CLI, explorers, and buffer switches
    local highlight_ft_set = {}
    for _, ft in ipairs(highlight_filetypes) do
      highlight_ft_set[ft] = true
    end
    
    -- Primary autocmd: BufReadPost + BufWinEnter for explorer support
    vim.api.nvim_create_autocmd({ "BufReadPost", "BufWinEnter" }, {
      group = vim.api.nvim_create_augroup("TreesitterHighlight", { clear = true }),
      callback = function(args)
        -- Defer to ensure treesitter is fully loaded
        vim.schedule(function()
          local buf = args.buf
          if not vim.api.nvim_buf_is_valid(buf) then
            return
          end
          
          -- Check if already active
          if vim.treesitter.highlighter.active[buf] then
            return
          end
          
          -- Disable for very large files (performance optimization)
          local filename = vim.api.nvim_buf_get_name(buf)
          if filename ~= "" then
            local max_filesize = 500 * 1024 -- 500 KB
            local ok, stats = pcall(vim.uv.fs_stat, filename)
            if ok and stats and stats.size > max_filesize then
              return -- Skip treesitter for large files
            end
          end
          
          -- Force filetype detection if not set (critical for explorer support)
          local ft = vim.bo[buf].filetype
          if ft == "" then
            if filename ~= "" then
              -- Force filetype detection
              vim.api.nvim_buf_call(buf, function()
                vim.cmd("filetype detect")
              end)
              
              -- Re-check filetype after detection
              vim.schedule(function()
                ft = vim.bo[buf].filetype
                if ft ~= "" and highlight_ft_set[ft] and not vim.treesitter.highlighter.active[buf] then
                  pcall(vim.treesitter.start, buf)
                end
              end)
              return
            end
            return
          end
          
          -- Check if filetype is in our list
          if not highlight_ft_set[ft] then
            return
          end
          
          -- Start treesitter
          pcall(vim.treesitter.start, buf)
        end)
      end,
      desc = "Enable treesitter highlighting (explorer support)",
    })
    
    -- Secondary: FileType event for immediate response
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("TreesitterHighlightFT", { clear = true }),
      pattern = highlight_filetypes,
      callback = function(args)
        vim.schedule(function()
          local buf = args.buf
          if vim.api.nvim_buf_is_valid(buf) and not vim.treesitter.highlighter.active[buf] then
            pcall(vim.treesitter.start, buf)
          end
        end)
      end,
      desc = "Enable treesitter highlighting on FileType",
    })
    
    -- Indentation autocmd
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("TreesitterIndent", { clear = true }),
      pattern = indent_filetypes,
      callback = function()
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
      desc = "Enable treesitter indentation (experimental)",
    })
    
    -- Folding autocmd
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("TreesitterFold", { clear = true }),
      pattern = fold_filetypes,
      callback = function()
        vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.wo.foldmethod = "expr"
        vim.wo.foldenable = false
      end,
      desc = "Enable treesitter folding",
    })
  end,
  
  config = function()
    -- ========================================================================
    -- MANUAL TREESITTER LOADER
    -- ========================================================================
    -- Create user command and keybinding for manual loading
    
    -- User command: :TSStart
    vim.api.nvim_create_user_command("TSStart", function()
      local buf = vim.api.nvim_get_current_buf()
      local ft = vim.bo[buf].filetype
      
      if ft == "" then
        vim.notify("No filetype detected. Set filetype first with :set filetype=<lang>", vim.log.levels.WARN)
        return
      end
      
      -- Check if already active
      if vim.treesitter.highlighter.active[buf] then
        vim.notify("Treesitter already active for " .. ft, vim.log.levels.INFO)
        return
      end
      
      -- Try to start treesitter
      local ok, err = pcall(vim.treesitter.start, buf)
      if ok then
        vim.notify("✓ Treesitter started for " .. ft, vim.log.levels.INFO)
      else
        vim.notify("✗ Failed to start treesitter: " .. tostring(err), vim.log.levels.ERROR)
        -- Suggest installing parser
        vim.notify("Try: :TSInstall " .. ft, vim.log.levels.INFO)
      end
    end, {
      desc = "Manually start treesitter highlighting for current buffer",
    })
    
    -- User command: :TSRestart (stop + start)
    vim.api.nvim_create_user_command("TSRestart", function()
      local buf = vim.api.nvim_get_current_buf()
      local ft = vim.bo[buf].filetype
      
      -- Stop if active
      if vim.treesitter.highlighter.active[buf] then
        pcall(vim.treesitter.stop, buf)
      end
      
      -- Wait a tick then restart
      vim.schedule(function()
        local ok = pcall(vim.treesitter.start, buf)
        if ok then
          vim.notify("✓ Treesitter restarted for " .. ft, vim.log.levels.INFO)
        else
          vim.notify("✗ Failed to restart treesitter", vim.log.levels.ERROR)
        end
      end)
    end, {
      desc = "Restart treesitter highlighting for current buffer",
    })
    
    -- User command: :TSStatus
    vim.api.nvim_create_user_command("TSStatus", function()
      local buf = vim.api.nvim_get_current_buf()
      local ft = vim.bo[buf].filetype
      local active = vim.treesitter.highlighter.active[buf] ~= nil
      
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
      print("Treesitter Status")
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
      print("Buffer: " .. buf)
      print("Filetype: " .. (ft ~= "" and ft or "NONE"))
      print("Active: " .. (active and "✓ YES" or "✗ NO"))
      
      if ft ~= "" then
        local lang = vim.treesitter.language.get_lang(ft) or ft
        print("Language: " .. lang)
        
        -- Check if parser exists
        local parser_path = vim.fn.stdpath("data") .. "/site/parser/" .. lang .. ".so"
        local has_parser = vim.fn.filereadable(parser_path) == 1
        print("Parser: " .. (has_parser and "✓ Installed" or "✗ Not installed"))
        
        if not has_parser then
          print("\nInstall with: :TSInstall " .. lang)
        end
      end
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    end, {
      desc = "Show treesitter status for current buffer",
    })
    
    -- Keybinding: <leader>ts to manually start treesitter
    vim.keymap.set("n", "<leader>ts", "<cmd>TSStart<cr>", {
      desc = "Start Treesitter highlighting",
      silent = true,
    })
    
    -- Keybinding: <leader>tr to restart treesitter
    vim.keymap.set("n", "<leader>tr", "<cmd>TSRestart<cr>", {
      desc = "Restart Treesitter highlighting",
      silent = true,
    })
    
    -- Main branch only handles parser installation
    -- No module configuration (highlight, indent, etc.)
    
    local languages = {
      -- Core languages
      "c", "lua", "vim", "vimdoc", "query",
      -- Web Development
      "html", "css", "scss", "javascript", "typescript", "tsx", "jsx",
      "vue", "svelte", "graphql", "json", "jsonc", "xml",
      -- Backend
      "python", "java", "go", "rust", "ruby", "php", "cpp", "c_sharp",
      "kotlin", "scala",
      -- System and DevOps
      "bash", "fish", "dockerfile", "terraform", "hcl", "make", "cmake",
      "perl", "toml", "awk",
      -- Data and Config
      "yaml", "ini", "sql", "proto",
      -- Documentation
      "markdown", "markdown_inline", "rst", "latex", "bibtex", "typst",
      -- Version Control
      "git_config", "gitattributes", "gitcommit", "gitignore", "diff",
      -- Scripting
      "regex", "jq", "nix", "groovy",
    }
    
    -- Main branch setup - only configures install directory
    local ok, ts = pcall(require, "nvim-treesitter")
    if not ok then
      vim.notify("nvim-treesitter not available", vim.log.levels.ERROR)
      return
    end
    
    -- Setup install directory
    ts.setup({
      install_dir = vim.fn.stdpath("data") .. "/site",
    })
    
    -- Install parsers using the official API
    -- This is async and returns a promise, but we don't need to wait
    vim.schedule(function()
      pcall(ts.install, languages)
    end)
    
    -- ========================================================================
    -- NOTE: Autocmds moved to init() function for earlier registration
    -- ========================================================================
    -- This ensures they work when opening files from explorers (mini-files, snacks, etc.)
    
    -- ========================================================================
    -- TEXTOBJECTS (If plugin supports main branch)
    -- ========================================================================
    -- NOTE: nvim-treesitter-textobjects may not fully support main branch yet
    -- This is a best-effort configuration
    
    local textobjects_ok, textobjects = pcall(require, "nvim-treesitter-textobjects")
    if textobjects_ok and textobjects.setup then
      textobjects.setup({
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
            -- Comment text objects (capital C to avoid clash with class)
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
          },
          goto_next_end = {
            ["]M"] = "@function.outer",
            ["]["] = "@class.outer",
          },
          goto_previous_start = {
            ["[m"] = "@function.outer",
            ["[["] = "@class.outer",
            ["[i"] = "@conditional.outer",
            ["[l"] = "@loop.outer",
          },
          goto_previous_end = {
            ["[M"] = "@function.outer",
            ["[]"] = "@class.outer",
          },
        },
        swap = {
          -- Changed from <leader>a to <leader>sa to avoid conflict with Avante AI prefix
          swap_next = {
            ["<leader>sa"] = "@parameter.inner",
          },
          swap_previous = {
            ["<leader>sA"] = "@parameter.inner",
          },
        },
      })
    end
    
    -- ========================================================================
    -- AUTOTAG
    -- ========================================================================
    require("nvim-ts-autotag").setup({
      filetypes = {
        "html", "javascript", "typescript", "javascriptreact", "typescriptreact",
        "svelte", "vue", "tsx", "jsx", "xml", "php", "markdown",
        "astro", "glimmer", "handlebars", "hbs", "rescript",
      },
    })
    
    -- ========================================================================
    -- CONTEXT COMMENTSTRING
    -- ========================================================================
    vim.g.skip_ts_context_commentstring_module = true
    require("ts_context_commentstring").setup({})
    
    -- ========================================================================
    -- TREESITTER CONTEXT (sticky context at top)
    -- ========================================================================
    local context_ok, context = pcall(require, "treesitter-context")
    if context_ok then
      context.setup({
        enable = true,
        max_lines = 3, -- How many lines to show
        min_window_height = 20, -- Minimum editor window height
        line_numbers = true,
        multiline_threshold = 1,
        trim_scope = 'outer',
        mode = 'cursor', -- 'cursor' or 'topline'
      })
      
      -- Keybinding to jump to context
      vim.keymap.set("n", "[c", function()
        context.go_to_context()
      end, { desc = "Jump to context", silent = true })
    end
    
    -- ========================================================================
    -- TEXTSUBJECTS (smart text selection)
    -- ========================================================================
    local textsubjects_ok, textsubjects = pcall(require, "nvim-treesitter-textsubjects")
    if textsubjects_ok then
      textsubjects.configure({
        prev_selection = ",",
        keymaps = {
          ["."] = "textsubjects-smart", -- Smart selection
          [";"] = "textsubjects-container-outer", -- Container selection
          ["i;"] = { "textsubjects-container-inner", desc = "Select inside containers" },
        },
      })
    end
    
    -- ========================================================================
    -- ENDWISE (auto-add end statements)
    -- ========================================================================
    local endwise_ok, endwise = pcall(require, "nvim-treesitter-endwise")
    if endwise_ok then
      -- Endwise is configured automatically via treesitter if available
      -- No explicit setup needed for main branch
    end
    
    -- Performance optimization
    vim.opt.maxmempattern = 10000
    vim.opt.regexpengine = 1
  end,
}
