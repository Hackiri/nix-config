-- fzf-lua: Fast and customizable fuzzy finder
-- LazyVim 14.x+ default picker (replaces telescope.nvim)
-- Docs: https://github.com/ibhagwan/fzf-lua

return {
  "ibhagwan/fzf-lua",
  -- Use latest version for Neovim 0.11.3 treesitter compatibility
  version = false,
  cmd = "FzfLua",
  keys = {
    -- Files
    { "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find Files" },
    { "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Find Text (Live Grep)" },
    { "<leader>fw", "<cmd>FzfLua grep_cword<cr>", desc = "Find Word Under Cursor" },
    { "<leader>fh", "<cmd>FzfLua help_tags<cr>", desc = "Find Help" },
    { "<leader>fo", "<cmd>FzfLua oldfiles<cr>", desc = "Find Recent Files" },
    { "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Find Buffers" },

    -- Git
    { "<leader>fgf", "<cmd>FzfLua git_files<cr>", desc = "Find Git Files" },
    { "<leader>fgc", "<cmd>FzfLua git_commits<cr>", desc = "Find Git Commits" },
    { "<leader>fgb", "<cmd>FzfLua git_branches<cr>", desc = "Find Git Branches" },
    { "<leader>fgs", "<cmd>FzfLua git_status<cr>", desc = "Find Git Status" },

    -- LSP
    { "<leader>fr", "<cmd>FzfLua lsp_references<cr>", desc = "Find References" },
    { "<leader>fd", "<cmd>FzfLua lsp_definitions<cr>", desc = "Find Definitions" },
    { "<leader>fi", "<cmd>FzfLua lsp_implementations<cr>", desc = "Find Implementations" },
    { "<leader>ft", "<cmd>FzfLua lsp_typedefs<cr>", desc = "Find Type Definitions" },
    { "<leader>fs", "<cmd>FzfLua lsp_document_symbols<cr>", desc = "Find Document Symbols" },
    { "<leader>fws", "<cmd>FzfLua lsp_workspace_symbols<cr>", desc = "Find Workspace Symbols" },
    { "<leader>fwd", "<cmd>FzfLua diagnostics_workspace<cr>", desc = "Find Workspace Diagnostics" },

    -- Search
    { "<leader>f/", "<cmd>FzfLua blines<cr>", desc = "Find in Current Buffer" },
    { "<leader>f?", "<cmd>FzfLua search_history<cr>", desc = "Find Search History" },
    { "<leader>f:", "<cmd>FzfLua command_history<cr>", desc = "Find Command History" },

    -- Misc
    { "<leader>fk", "<cmd>FzfLua keymaps<cr>", desc = "Find Keymaps" },
    { "<leader>fm", "<cmd>FzfLua marks<cr>", desc = "Find Marks" },
    { "<leader>fj", "<cmd>FzfLua jumps<cr>", desc = "Find Jump List" },
  },
  opts = function()
    local actions = require("fzf-lua.actions")

    return {
      -- Global configuration
      "default-title", -- Use default title style

      winopts = {
        height = 0.80,
        width = 0.87,
        row = 0.5,
        col = 0.5,
        border = "rounded",
        preview = {
          layout = "horizontal",
          horizontal = "right:60%",
          scrollbar = "border",
          delay = 50,
        },
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
          ["ctrl-q"] = "select-all+accept",
          ["ctrl-u"] = "unix-line-discard",
          ["ctrl-a"] = "beginning-of-line",
          ["ctrl-e"] = "end-of-line",
          ["alt-a"] = "toggle-all",
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
        cmd = "rg --files --sortr=modified --hidden --glob '!.git'",
        git_icons = true,
        file_icons = true,
        color_icons = true,
        find_opts = [[-type f -not -path '*/\.git/*' -printf '%P\n']],
        rg_opts = "--color=never --files --hidden --follow -g '!.git'",
        fd_opts = "--color=never --type f --hidden --follow --exclude .git",
      },

      -- Grep configuration
      grep = {
        prompt = "Grep❯ ",
        input_prompt = "Grep For❯ ",
        cmd = "rg --column --line-number --no-heading --color=always --smart-case --max-columns=4096 --hidden",
        git_icons = true,
        file_icons = true,
        color_icons = true,
        rg_opts = "--hidden --column --line-number --no-heading --color=always --smart-case -g '!.git'",
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
    }
  end,
  config = function(_, opts)
    require("fzf-lua").setup(opts)

    -- Register fzf-lua as the default UI select
    require("fzf-lua").register_ui_select()
  end,
}
