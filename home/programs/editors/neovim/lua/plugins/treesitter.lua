-- nvim-treesitter configuration for MAIN branch
-- This is the new, minimal API that requires manual highlighting setup

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main", -- Modern rewrite with minimal API
  build = ":TSUpdate", -- Official recommendation from main branch README
  lazy = false, -- Load immediately
  
  dependencies = {
    -- NOTE: These plugins are DISABLED for main branch - they cause loading errors
    -- The main branch has breaking changes and these plugins are not yet compatible
    -- { "nvim-treesitter/nvim-treesitter-textobjects" }, -- DISABLED: causes module loading loop
    { "nvim-treesitter/nvim-treesitter-context", version = "*" }, -- Show context at top
    { "windwp/nvim-ts-autotag", version = "*" },
    { "JoosepAlviste/nvim-ts-context-commentstring", version = "*" },
    -- { "RRethy/nvim-treesitter-endwise", version = "*" }, -- DISABLED: not compatible with main
    -- { "RRethy/nvim-treesitter-textsubjects", version = false }, -- DISABLED: not compatible with main
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

          -- Check if parser exists before trying to start treesitter
          local lang = vim.treesitter.language.get_lang(ft) or ft
          local parser_path = vim.fn.stdpath("data") .. "/site/parser/" .. lang .. ".so"
          if vim.fn.filereadable(parser_path) == 0 then
            -- Parser not installed, skip silently
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
          if not vim.api.nvim_buf_is_valid(buf) or vim.treesitter.highlighter.active[buf] then
            return
          end

          -- Check if parser exists before trying to start treesitter
          local ft = vim.bo[buf].filetype
          local lang = vim.treesitter.language.get_lang(ft) or ft
          local parser_path = vim.fn.stdpath("data") .. "/site/parser/" .. lang .. ".so"
          if vim.fn.filereadable(parser_path) == 0 then
            -- Parser not installed, skip silently
            return
          end

          pcall(vim.treesitter.start, buf)
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
    
    -- ========================================================================
    -- NATIVE NEOVIM TREESITTER INSPECTION (replaces deprecated playground)
    -- ========================================================================
    -- Neovim 0.10+ has built-in treesitter inspection commands
    
    -- Keybinding: <leader>ti to inspect highlight groups under cursor
    vim.keymap.set("n", "<leader>ti", "<cmd>Inspect<cr>", {
      desc = "Inspect highlight groups under cursor",
      silent = true,
    })
    
    -- Keybinding: <leader>tt to show parsed syntax tree (TSPlayground replacement)
    vim.keymap.set("n", "<leader>tt", "<cmd>InspectTree<cr>", {
      desc = "Show parsed syntax tree (Treesitter Playground)",
      silent = true,
    })
    
    -- Keybinding: <leader>tq to open Live Query Editor (Neovim 0.10+)
    vim.keymap.set("n", "<leader>tq", "<cmd>EditQuery<cr>", {
      desc = "Open Live Query Editor",
      silent = true,
    })
    
    -- User command aliases for discoverability
    vim.api.nvim_create_user_command("TSPlayground", "InspectTree", {
      desc = "Show parsed syntax tree (alias for :InspectTree)",
    })
    
    vim.api.nvim_create_user_command("TSInspect", "Inspect", {
      desc = "Inspect highlight groups under cursor (alias for :Inspect)",
    })
    
    -- Main branch only handles parser installation
    -- No module configuration (highlight, indent, etc.)
    
    -- Only install essential parsers immediately (non-blocking)
    local essential_languages = {
      "c", "lua", "vim", "vimdoc", "query", -- Core Neovim
      "markdown", "markdown_inline", -- Documentation
      "regex", "bash", "html", "latex", "yaml", -- User-requested parsers
    }
    
    -- Full list of languages to install on-demand
    local all_languages = {
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

    -- Check which parsers are missing and install them SYNCHRONOUSLY
    -- This prevents "substitute" errors on startup
    local parser_dir = vim.fn.stdpath("data") .. "/site/parser"
    local missing_parsers = {}

    for _, lang in ipairs(essential_languages) do
      local parser_path = parser_dir .. "/" .. lang .. ".so"
      if vim.fn.filereadable(parser_path) == 0 then
        table.insert(missing_parsers, lang)
      end
    end

    -- Only install if there are missing parsers
    if #missing_parsers > 0 then
      vim.notify(
        string.format("Installing %d missing parser(s): %s", #missing_parsers, table.concat(missing_parsers, ", ")),
        vim.log.levels.INFO
      )
      -- Install synchronously to prevent query errors on startup
      pcall(ts.install, missing_parsers)
    end
    
    -- Command to install essential parsers manually
    vim.api.nvim_create_user_command("TSInstallEssential", function()
      vim.notify("Installing essential parsers...", vim.log.levels.INFO)
      ts.install(essential_languages)
    end, {
      desc = "Install essential treesitter parsers",
    })
    
    -- Create user command to install all parsers manually
    vim.api.nvim_create_user_command("TSInstallAll", function()
      vim.notify("Installing all treesitter parsers...", vim.log.levels.INFO)
      ts.install(all_languages)
    end, {
      desc = "Install all treesitter parsers",
    })
    
    -- Auto-install parser when opening a file (on-demand)
    -- DISABLED: Can cause hangs, use :TSInstall <lang> manually instead
    -- vim.api.nvim_create_autocmd("FileType", {
    --   group = vim.api.nvim_create_augroup("TreesitterAutoInstall", { clear = true }),
    --   callback = function(args)
    --     local ft = vim.bo[args.buf].filetype
    --     if ft == "" then
    --       return
    --     end
    --     
    --     -- Get the language for this filetype
    --     local lang = vim.treesitter.language.get_lang(ft) or ft
    --     
    --     -- Check if parser exists
    --     local parser_path = vim.fn.stdpath("data") .. "/site/parser/" .. lang .. ".so"
    --     local has_parser = vim.fn.filereadable(parser_path) == 1
    --     
    --     -- Install if missing
    --     if not has_parser then
    --       vim.schedule(function()
    --         vim.notify("Installing " .. lang .. " parser...", vim.log.levels.INFO)
    --         pcall(ts.install, { lang })
    --       end)
    --     end
    --   end,
    --   desc = "Auto-install treesitter parser on demand",
    -- })
    
    -- Instead, create a command to install parser for current filetype
    vim.api.nvim_create_user_command("TSInstallCurrent", function()
      local ft = vim.bo.filetype
      if ft == "" then
        vim.notify("No filetype detected", vim.log.levels.WARN)
        return
      end
      
      local lang = vim.treesitter.language.get_lang(ft) or ft
      vim.notify("Installing " .. lang .. " parser...", vim.log.levels.INFO)
      ts.install({ lang })
    end, {
      desc = "Install treesitter parser for current filetype",
    })
    
    -- ========================================================================
    -- NOTE: Autocmds moved to init() function for earlier registration
    -- ========================================================================
    -- This ensures they work when opening files from explorers (mini-files, snacks, etc.)
    
    -- ========================================================================
    -- TEXTOBJECTS (DISABLED for main branch)
    -- ========================================================================
    -- NOTE: nvim-treesitter-textobjects is NOT compatible with main branch yet
    -- It causes a module loading loop error. Re-enable when officially supported.
    --
    -- For now, use Neovim's built-in text objects or consider switching to
    -- the stable/master branch if you need textobjects functionality.
    --
    -- Alternative: Use plugins like:
    -- - mini.ai (https://github.com/echasnovski/mini.ai)
    -- - various-textobjs (https://github.com/chrisgrieser/nvim-various-textobjs)
    
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
    -- TEXTSUBJECTS (DISABLED for main branch)
    -- ========================================================================
    -- NOTE: nvim-treesitter-textsubjects is NOT compatible with main branch
    -- Consider using mini.ai or nvim-various-textobjs as alternatives

    -- ========================================================================
    -- ENDWISE (DISABLED for main branch)
    -- ========================================================================
    -- NOTE: nvim-treesitter-endwise is NOT compatible with main branch
    -- Consider using nvim-autopairs or similar plugins as alternatives
    
    -- Performance optimization
    vim.opt.maxmempattern = 10000
    vim.opt.regexpengine = 1
  end,
}