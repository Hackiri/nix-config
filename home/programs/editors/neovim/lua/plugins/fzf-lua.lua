-- fzf-lua: Fast and customizable fuzzy finder
-- LazyVim 14.x+ default picker (uses fzf-lua)
-- Docs: https://github.com/ibhagwan/fzf-lua
--
-- Key advantages of fzf-lua (from https://git.ramboe.io/YouTube/ciao-telescope-i-dont-need-you-anymore):
--   1. Exact string matching support (--exact flag)
--   2. Multi-stage filtering workflow via quickfix
--   3. Better composability with native Vim workflows
--   4. More transparent configuration
--
-- Multi-stage filtering workflow:
--   1. <leader>fg - Start live_grep search
--   2. Type your search pattern
--   3. <ctrl-q> - Send all results to quickfix list
--   4. <ctrl-g> or <leader>fq - Open quickfix in fzf to filter further
--   5. Repeat step 4 to progressively narrow down results
--
-- Exact matching:
--   - <leader>fF - Find files with exact match (no fuzzy)
--   - <leader>fG - Live grep with exact match
--   - Or add '--exact' flag inline: search for 'pattern --exact'

return {
  "ibhagwan/fzf-lua",
  -- Use latest version for Neovim 0.11.3 treesitter compatibility
  version = false,
  cmd = "FzfLua",
  dependencies = {
    -- fzf-lua extensions
    {
      "phanen/fzf-lua-extra",
      dependencies = {
        "nvim-mini/mini.visits", -- Required for visits picker
      },
    },
    {
      "drop-stones/fzf-lua-grep-context",
      dependencies = { "MunifTanjim/nui.nvim" },
      config = function()
        -- Define reusable grep contexts
        local contexts = {
          default = {
            title = "Default",
            entries = {
              -- Language-specific contexts
              lua = { label = "Lua Files", filetype = "lua", globs = { "*.lua" } },
              nix = { label = "Nix Files", extension = "nix", globs = { "*.nix" } },
              typescript = {
                label = "TypeScript/React",
                filetype = "typescriptreact",
                globs = { "*.ts", "*.tsx", "*.js", "*.jsx" },
              },
              python = { label = "Python Files", filetype = "python", globs = { "*.py" } },
              go = { label = "Go Files", filetype = "go", globs = { "*.go" } },
              rust = { label = "Rust Files", filetype = "rust", globs = { "*.rs" } },
              markdown = { label = "Markdown Files", filetype = "markdown", globs = { "*.md" } },
              config = {
                label = "Config Files",
                extension = "json",
                globs = { "*.json", "*.yaml", "*.yml", "*.toml", "*.conf" },
              },
              -- Exclude contexts
              no_tests = { label = "Exclude Tests", globs = { "!**/*test*" } },
              no_node_modules = { label = "Exclude node_modules", globs = { "!**/node_modules/**" } },
              no_build = {
                label = "Exclude Build/Dist",
                globs = { "!{**/dist/**,**/build/**,**/target/**,result}" },
              },
            },
          },
        }

        require("fzf-lua-grep-context").setup({
          contexts = contexts,
          picker = {
            default_group = "default",
          },
        })
      end,
    },
  },
  keys = {
    -- Files
    { "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find Files" },
    { "<leader>fF", "<cmd>FzfLua files fzf_opts={['--exact']=''}<cr>", desc = "Find Files (Exact Match)" },
    { "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Find Text (Live Grep)" },
    { "<leader>fG", "<cmd>FzfLua live_grep fzf_opts={['--exact']=''}<cr>", desc = "Find Text (Exact Match)" },
    { "<leader>fw", "<cmd>FzfLua grep_cword<cr>", desc = "Find Word Under Cursor" },
    { "<leader>fv", "<cmd>FzfLua grep_visual<cr>", mode = "v", desc = "Find Visual Selection" },
    { "<leader>fh", "<cmd>FzfLua help_tags<cr>", desc = "Find Help" },
    { "<leader>fo", "<cmd>FzfLua oldfiles<cr>", desc = "Find Recent Files" },
    { "<leader>fr", "<cmd>FzfLua resume<cr>", desc = "Resume Last Search" },
    { "<leader>fp", "<cmd>FzfLua builtin<cr>", desc = "FzfLua Pickers (Builtin)" },

    -- Git
    { "<leader>fgf", "<cmd>FzfLua git_files<cr>", desc = "Find Git Files" },
    { "<leader>fgc", "<cmd>FzfLua git_commits<cr>", desc = "Find Git Commits" },
    { "<leader>fgB", "<cmd>FzfLua git_bcommits<cr>", desc = "Find Git Buffer Commits" },
    { "<leader>fgb", "<cmd>FzfLua git_branches<cr>", desc = "Find Git Branches" },
    { "<leader>fgs", "<cmd>FzfLua git_status<cr>", desc = "Find Git Status" },

    -- LSP
    { "<leader>fR", "<cmd>FzfLua lsp_references<cr>", desc = "Find References" },
    { "<leader>fd", "<cmd>FzfLua lsp_definitions<cr>", desc = "Find Definitions" },
    { "<leader>fi", "<cmd>FzfLua lsp_implementations<cr>", desc = "Find Implementations" },
    { "<leader>ft", "<cmd>FzfLua lsp_typedefs<cr>", desc = "Find Type Definitions" },
    { "<leader>fs", "<cmd>FzfLua lsp_document_symbols<cr>", desc = "Find Document Symbols" },
    { "<leader>fws", "<cmd>FzfLua lsp_workspace_symbols<cr>", desc = "Find Workspace Symbols" },
    { "<leader>fwd", "<cmd>FzfLua diagnostics_workspace<cr>", desc = "Find Workspace Diagnostics" },
    {
      "<leader>fca",
      function()
        require("fzf-lua").lsp_code_actions({
          winopts = {
            relative = "cursor",
            row = 1.01,
            col = 0,
            height = 0.2,
            width = 0.4,
          },
        })
      end,
      desc = "Code Actions (Near Cursor)",
    },

    -- Search
    { "<leader>f/", "<cmd>FzfLua blines<cr>", desc = "Find in Current Buffer" },
    { "<leader>f?", "<cmd>FzfLua search_history<cr>", desc = "Find Search History" },
    { "<leader>f:", "<cmd>FzfLua command_history<cr>", desc = "Find Command History" },

    -- Misc
    { "<leader>fk", "<cmd>FzfLua keymaps<cr>", desc = "Find Keymaps" },
    { "<leader>fm", "<cmd>FzfLua marks<cr>", desc = "Find Marks" },
    { "<leader>fj", "<cmd>FzfLua jumps<cr>", desc = "Find Jump List" },
    { "<leader>fy", "<cmd>FzfLua registers<cr>", desc = "Find Registers" },
    { "<leader>fz", "<cmd>FzfLua spell_suggest<cr>", desc = "Spelling Suggestions" },
    { "<leader>fc", "<cmd>FzfLua commands<cr>", desc = "Find Commands" },
    { "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Find Buffers" },

    -- Quickfix (for multi-stage filtering workflow)
    { "<leader>fq", "<cmd>FzfLua quickfix<cr>", desc = "Find in Quickfix" },
    { "<C-g>", "<cmd>FzfLua quickfix<cr>", desc = "Filter Quickfix with fzf" },

    -- fzf-lua-extra keymaps
    {
      "<leader>fV",
      function()
        require("fzf-lua-extra").visits()
      end,
      desc = "Find Visits (Frequent Files)",
    },
    {
      "<leader>fL",
      function()
        require("fzf-lua-extra").lazy()
      end,
      desc = "Find Lazy Plugins",
    },
    {
      "<leader>fgh",
      function()
        require("fzf-lua-extra").hunks()
      end,
      desc = "Find Git Hunks",
    },
    {
      "<leader>fgl",
      function()
        require("fzf-lua-extra").git_log()
      end,
      desc = "Find Git Log (Enhanced)",
    },
    {
      "<leader>fP",
      function()
        require("fzf-lua-extra").ps()
      end,
      desc = "Find Processes",
    },

    -- fzf-lua-grep-context keymaps
    {
      "<leader>fgx",
      function()
        require("fzf-lua-grep-context").picker()
      end,
      desc = "Select Grep Contexts",
    },
  },
  opts = function()
    local actions = require("fzf-lua.actions")
    local path = require("fzf-lua.path")

    -- Custom action: Copy file path with line:col to clipboard
    local function copy_file_path(selected, opts)
      local file_and_path = path.entry_to_file(selected[1], opts).stripped
      vim.fn.setreg("+", file_and_path) -- System clipboard
      vim.fn.setreg("0", file_and_path) -- Yank register
      vim.notify("Copied: " .. file_and_path, vim.log.levels.INFO)
    end

    return {
      -- Global configuration
      "default-title", -- Use default title style
      fzf_opts = { ["--wrap"] = true }, -- Wrap long lines in fzf

      winopts = {
        height = 0.80,
        width = 0.87,
        row = 0.5,
        col = 0.5,
        preview = {
          layout = "horizontal",
          horizontal = "right:60%",
          delay = 50,
          wrap = "wrap", -- Wrap long lines in preview
        },
      },

      -- Default settings
      defaults = {
        formatter = "path.filename_first", -- Show filename before path for easier scanning
      },

      -- Previewers configuration - fix for Neovim 0.11.3 treesitter compatibility
      previewers = {
        builtin = {
          -- Disable treesitter highlighting in previewer to avoid API compatibility issues
          treesitter = { enable = false },
          -- Use syntax highlighting instead
          syntax = true,
          syntax_limit_b = 1024 * 100, -- 100KB limit
        },
      },

      -- Keybindings
      keymap = {
        builtin = {
          ["<C-/>"] = "toggle-help",
          ["<C-d>"] = "preview-page-down",
          ["<C-u>"] = "preview-page-up",
        },
        fzf = {
          ["ctrl-q"] = "select-all+accept", -- Send all to quickfix
          ["ctrl-u"] = "unix-line-discard",
          ["ctrl-a"] = "beginning-of-line",
          ["ctrl-e"] = "end-of-line",
          ["alt-a"] = "toggle-all",
          -- Multi-stage filtering workflow (from article):
          -- 1. Use live_grep to find results
          -- 2. Press ctrl-q to send to quickfix
          -- 3. Use :FzfLua quickfix to filter further
        },
      },

      -- Actions
      actions = {
        files = {
          ["default"] = actions.file_edit_or_qf,
          ["ctrl-x"] = actions.file_split,
          ["ctrl-v"] = actions.file_vsplit,
          ["ctrl-t"] = actions.file_tabedit,
          ["ctrl-q"] = actions.file_sel_to_qf,
          ["alt-q"] = actions.file_sel_to_ll,
          ["ctrl-y"] = { fn = copy_file_path, exec_silent = true }, -- Copy file:line:col to clipboard
        },
        buffers = {
          ["default"] = actions.buf_edit,
          ["ctrl-x"] = actions.buf_split,
          ["ctrl-v"] = actions.buf_vsplit,
          ["ctrl-t"] = actions.buf_tabedit,
          ["ctrl-d"] = { fn = actions.buf_del, reload = true },
        },
      },

      -- File picker configuration
      files = {
        prompt = "Files❯ ",
        -- Use rg for faster file finding with sort by modified time
        cmd = "rg --files --sortr=modified --hidden --glob '!.git'",
        git_icons = true,
        file_icons = true,
        color_icons = true,
      },

      -- Grep configuration
      grep = {
        prompt = "Grep❯ ",
        input_prompt = "Grep For❯ ",
        -- Add --hidden and --max-columns to defaults
        cmd = "rg --column --line-number --no-heading --color=always --smart-case --max-columns=4096 --hidden",
        git_icons = true,
        file_icons = true,
        color_icons = true,
        rg_glob = false, -- fzf-lua-grep-context handles glob parsing and injection
        fn_transform_cmd = function(query, cmd, _)
          vim.opt.rtp:append(vim.env.FZF_LUA_GREP_CONTEXT)
          return require("fzf-lua-grep-context.transform").rg(query, cmd)
        end,
        actions = {
          ["ctrl-t"] = function()
            require("fzf-lua-grep-context").picker()
          end,
        },
      },

      -- LSP configuration
      lsp = {
        prompt_postfix = "❯ ",
        cwd_only = false,
        async_or_timeout = 5000,
        file_icons = true,
        git_icons = false,
        lsp_icons = true,
        ui_select = true,
        symbol_style = 1, -- 1: icon+text, 2: icon only, 3: text only
        symbol_icons = {
          File = "󰈙",
          Module = "",
          Namespace = "󰌗",
          Package = "",
          Class = "󰌗",
          Method = "󰆧",
          Property = "",
          Field = "",
          Constructor = "",
          Enum = "󰕘",
          Interface = "󰕘",
          Function = "󰊕",
          Variable = "󰆧",
          Constant = "󰏿",
          String = "󰀬",
          Number = "󰎠",
          Boolean = "◩",
          Array = "󰅪",
          Object = "󰅩",
          Key = "󰌋",
          Null = "󰟢",
          EnumMember = "",
          Struct = "󰌗",
          Event = "",
          Operator = "󰆕",
          TypeParameter = "󰊄",
        },
      },

      -- Git configuration
      git = {
        files = {
          cmd = "git ls-files --exclude-standard",
          prompt = "GitFiles❯ ",
        },
        status = {
          prompt = "GitStatus❯ ",
          cmd = "git -c color.status=false status --short --untracked-files=all",
          previewer = "git_diff",
          file_icons = true,
          git_icons = true,
          color_icons = true,
        },
        commits = {
          prompt = "Commits❯ ",
          cmd = "git log --color --pretty=format:'%C(yellow)%h%Creset %Cgreen(%><(12)%cr%><|(12))%Creset %s %C(blue)<%an>%Creset'",
          preview = "git show --color {1}",
          actions = {
            ["default"] = actions.git_checkout,
          },
        },
        bcommits = {
          prompt = "BCommits❯ ",
          cmd = "git log --color --pretty=format:'%C(yellow)%h%Creset %Cgreen(%><(12)%cr%><|(12))%Creset %s %C(blue)<%an>%Creset' <file>",
          preview = "git show --color {1} -- <file>",
        },
        branches = {
          prompt = "Branches❯ ",
          cmd = "git branch --all --color",
          preview = "git log --graph --pretty=oneline --abbrev-commit --color {1}",
          actions = {
            ["default"] = actions.git_switch,
          },
        },
      },

      -- Old files configuration
      oldfiles = {
        prompt = "History❯ ",
        cwd_only = false,
        include_current_session = true,
      },

      -- Buffer configuration
      buffers = {
        prompt = "Buffers❯ ",
        file_icons = true,
        color_icons = true,
        sort_lastused = true,
        actions = {
          ["ctrl-d"] = { fn = actions.buf_del, reload = true },
        },
      },

      -- Help tags configuration
      helptags = {
        prompt = "Help❯ ",
      },

      -- Keymaps configuration
      keymaps = {
        prompt = "Keymaps❯ ",
      },

      -- Command history
      command_history = {
        prompt = "Command History❯ ",
      },

      -- Search history
      search_history = {
        prompt = "Search History❯ ",
      },

      -- Marks
      marks = {
        prompt = "Marks❯ ",
      },

      -- Jumps
      jumps = {
        prompt = "Jumps❯ ",
      },

      -- Quickfix configuration
      -- Article workflow: live_grep -> ctrl-q (send to qf) -> ctrl-g (filter qf with fzf)
      quickfix = {
        prompt = "Quickfix❯ ",
        file_icons = true,
        git_icons = true,
        color_icons = true,
      },

      -- Location list configuration
      loclist = {
        prompt = "Location List❯ ",
        file_icons = true,
        git_icons = true,
        color_icons = true,
      },
    }
  end,
  config = function(_, opts)
    require("fzf-lua").setup(opts)

    -- Register fzf-lua as the default UI select
    require("fzf-lua").register_ui_select()

    -- Grep contexts are injected through grep.fn_transform_cmd above.
  end,
}
