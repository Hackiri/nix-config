-- Fuzzy Finder (files, lsp, etc)
return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    { "nvim-lua/plenary.nvim", version = "*" },
    { "nvim-telescope/telescope-ui-select.nvim", version = "*" },
    { "nvim-tree/nvim-web-devicons", version = "*" },
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local builtin = require("telescope.builtin")

    telescope.setup({
      defaults = {
        scroll_strategy = "limit", -- Prevent cycling through results
        file_ignore_patterns = {
          "node_modules",
          ".git/",
          "target/",
          "dist/",
          "build/",
          "%.lock",
        },
        mappings = {
          i = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-n>"] = actions.cycle_history_next,
            ["<C-p>"] = actions.cycle_history_prev,
            ["<C-c>"] = actions.close,
            ["<C-u>"] = false,
            ["<C-d>"] = false,
            ["<esc>"] = actions.close,
            -- Preview scrolling
            ["J"] = actions.preview_scrolling_down,
            ["K"] = actions.preview_scrolling_up,
            ["H"] = false,
            ["L"] = false,
            -- Add new mappings for quick actions
            ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
            ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            ["<C-l>"] = actions.complete_tag,
            ["<C-/>"] = actions.which_key,
          },
          n = {
            ["d"] = actions.delete_buffer,
            ["<esc>"] = actions.close,
            -- Preview scrolling
            ["J"] = actions.preview_scrolling_down,
            ["K"] = actions.preview_scrolling_up,
            ["H"] = false,
            ["L"] = false,
            -- Add normal mode mappings
            ["q"] = actions.send_to_qflist + actions.open_qflist,
            ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
          },
        },
        sorting_strategy = "ascending",
        layout_config = {
          horizontal = {
            prompt_position = "top",
            preview_width = 0.6,
            width = { padding = 5 },
          },
          vertical = {
            mirror = false,
          },
          width = 0.87,
          height = 0.80,
          preview_cutoff = 120,
        },
        path_display = {
          "truncate",
          "filename_first",
        },
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--trim", -- Remove indentation
          "--hidden", -- Search hidden files
        },
      },
      extensions = {
        ["ui-select"] = {
          require("telescope.themes").get_dropdown({
            initial_mode = "normal",
            sorting_strategy = "ascending",
            layout_strategy = "center",
            layout_config = {
              width = function(_, max_columns, _)
                return math.min(max_columns - 20, 120)
              end,
              height = function(_, _, max_lines)
                return math.min(max_lines - 10, 20)
              end,
            },
            border = true,
            borderchars = {
              prompt = { "─", "│", " ", "│", "╭", "╮", "│", "│" },
              results = { "─", "│", "─", "│", "├", "┤", "╯", "╰" },
              preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
            },
          }),
        },
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
      },
      pickers = {
        find_files = {
          theme = "dropdown",
          previewer = false,
          hidden = true,
          find_command = { "rg", "--files", "--sortr=modified", "--hidden", "--glob", "!.git" },
        },
        buffers = {
          theme = "dropdown",
          previewer = false,
          sort_lastused = true,
          sort_mru = true,
          show_all_buffers = true,
          ignore_current_buffer = true,
          mappings = {
            i = {
              ["<C-d>"] = actions.delete_buffer,
            },
            n = {
              ["d"] = actions.delete_buffer,
            },
          },
        },
        live_grep = {
          additional_args = function()
            return { "--hidden" }
          end,
        },
      },
    })

    -- Load extensions
    -- Safely load extensions with error handling
    local function safe_load_extension(name)
      local ok, err = pcall(telescope.load_extension, name)
      if not ok then
        vim.notify("Could not load telescope extension '" .. name .. "': " .. err, vim.log.levels.WARN)
      end
    end

    safe_load_extension("fzf")
    safe_load_extension("ui-select")

    -- Keymaps
    local map = function(key, fn, desc)
      vim.keymap.set("n", key, fn, { desc = desc })
    end

    -- Files
    map("<leader>ff", builtin.find_files, "Find Files")
    map("<leader>fg", builtin.live_grep, "Find Text")
    map("<leader>fw", builtin.grep_string, "Find Word Under Cursor")
    map("<leader>fh", builtin.help_tags, "Find Help")
    map("<leader>fo", builtin.oldfiles, "Find Recent Files")
    map("<leader>fb", builtin.buffers, "Find Buffers")

    -- Git
    map("<leader>fgf", builtin.git_files, "Find Git Files")
    map("<leader>fgc", builtin.git_commits, "Find Git Commits")
    map("<leader>fgb", builtin.git_branches, "Find Git Branches")
    map("<leader>fgs", builtin.git_status, "Find Git Status")

    -- LSP
    map("<leader>fr", builtin.lsp_references, "Find References")
    map("<leader>fd", builtin.lsp_definitions, "Find Definitions")
    map("<leader>fi", builtin.lsp_implementations, "Find Implementations")
    map("<leader>ft", builtin.lsp_type_definitions, "Find Type Definitions")
    map("<leader>fs", builtin.lsp_document_symbols, "Find Document Symbols")
    map("<leader>fws", builtin.lsp_workspace_symbols, "Find Workspace Symbols")
    map("<leader>fwd", builtin.diagnostics, "Find Workspace Diagnostics")

    -- Search
    map("<leader>f/", builtin.current_buffer_fuzzy_find, "Find in Current Buffer")
    map("<leader>f?", builtin.search_history, "Find Search History")
    map("<leader>f:", builtin.command_history, "Find Command History")

    -- Misc
    map("<leader>fk", builtin.keymaps, "Find Keymaps")
    map("<leader>fm", builtin.marks, "Find Marks")
    map("<leader>fj", builtin.jumplist, "Find Jump List")
  end,
}
