return {
  "nvim-neo-tree/neo-tree.nvim",
  cmd = "Neotree", -- Load only when :Neotree command is used
  branch = "v3.x",
  dependencies = {
    { "nvim-lua/plenary.nvim", version = "*" },
    { "nvim-tree/nvim-web-devicons", version = "*" },
    { "MunifTanjim/nui.nvim", version = "*" },
    {
      "s1n7ax/nvim-window-picker",
      version = "2.*",
      config = function()
        require("window-picker").setup({
          filter_rules = {
            include_current_win = false,
            autoselect_one = true,
            bo = {
              filetype = { "neo-tree", "neo-tree-popup", "notify" },
              buftype = { "terminal", "quickfix" },
            },
          },
        })
      end,
    },
  },
  keys = {
    {
      "<leader>e",
      function()
        require("neo-tree.command").execute({ action = "focus", position = "left" })
      end,
      desc = "Explorer (focus)",
    },
    {
      "<leader>ef",
      "<cmd>Neotree reveal<cr>",
      desc = "Explorer (find current file)",
    },
    {
      "<leader>et",
      "<cmd>Neotree toggle<cr>",
      desc = "Explorer (toggle)",
    },
    {
      "<leader>eg",
      "<cmd>Neotree float git_status<cr>",
      desc = "Explorer (git status)",
    },
    {
      "<leader>eb",
      "<cmd>Neotree buffers<cr>",
      desc = "Explorer (buffers)",
    },
  },
  config = function()
    vim.fn.sign_define("DiagnosticSignError", { text = " ", texthl = "DiagnosticSignError" })
    vim.fn.sign_define("DiagnosticSignWarn", { text = " ", texthl = "DiagnosticSignWarn" })
    vim.fn.sign_define("DiagnosticSignInfo", { text = " ", texthl = "DiagnosticSignInfo" })
    vim.fn.sign_define("DiagnosticSignHint", { text = "󰌵", texthl = "DiagnosticSignHint" })

    local neotree = require("neo-tree")

    local function reveal_in_neotree()
      local path = vim.fn.expand("%:p")
      if path == "" then
        return
      end

      local state = require("neo-tree.sources.manager").get_state("filesystem")
      if state.window.is_visible then
        require("neo-tree.command").execute({
          action = "show",
          source = "filesystem",
          reveal_file = path,
          reveal_force_cwd = true,
        })
      else
        require("neo-tree.command").execute({
          action = "show",
          source = "filesystem",
          toggle = false,
          reveal_file = path,
          reveal_force_cwd = true,
          position = "left",
        })
      end
    end

    -- Monkey patch the toggle_node function to handle nil tree cases
    local commands = require("neo-tree.sources.common.commands")
    local original_toggle_node = commands.toggle_node
    commands.toggle_node = function(state)
      if not state or not state.tree then
        return
      end
      return original_toggle_node(state)
    end

    neotree.setup({
      close_if_last_window = false,
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = true,
      open_files_do_not_replace_types = { "terminal", "trouble", "qf" },
      sort_case_insensitive = false,
      use_default_mappings = false,
      retain_hidden_root_indent = true,
      log_level = "info", -- Valid options: "trace", "debug", "info", "warn", "error", "fatal"
      source_selector = {
        winbar = false,
        statusline = false,
        sources = {
          { source = "filesystem" },
          { source = "buffers" },
          { source = "git_status" },
        },
      },
      event_handlers = {
        {
          event = "neo_tree_popup_input_ready",
          ---@param args { bufnr: integer, winid: integer }
          handler = function(args)
            vim.cmd("stopinsert")
            vim.keymap.set("i", "<esc>", vim.cmd.stopinsert, { noremap = true, buffer = args.bufnr })
          end,
        },
        {
          event = "neo_tree_window_after_open",
          handler = function(args)
            if args.position == "left" or args.position == "right" then
              vim.cmd("wincmd =")
            end
          end,
        },
        {
          event = "neo_tree_window_after_close",
          handler = function(args)
            if args.position == "left" or args.position == "right" then
              vim.cmd("wincmd =")
            end
          end,
        },
        {
          event = "file_opened",
          handler = function()
            -- Auto close neo-tree after opening a file
            require("neo-tree.command").execute({ action = "close" })
          end,
        },
        {
          event = "before_render",
          handler = function(state)
            -- Ensure window is valid before rendering
            if state.window and state.window.winnr and not vim.api.nvim_win_is_valid(state.window.winnr) then
              state.window.winnr = nil
            end
          end,
        },
      },
      window = {
        position = "left",
        width = 40,
        mapping_options = {
          noremap = true,
          nowait = true,
        },
        mappings = {
          ["<space>"] = {
            "toggle_node",
            nowait = false,
          },
          ["<2-LeftMouse>"] = "open",
          ["<cr>"] = "open",
          ["<esc>"] = "cancel",
          ["P"] = {
            "toggle_preview",
            config = { use_float = true },
          },
          ["l"] = "open",
          ["S"] = "open_split",
          ["s"] = "open_vsplit",
          ["t"] = "open_tabnew",
          ["w"] = "open_with_window_picker",
          ["C"] = "close_node",
          ["z"] = "close_all_nodes",
          ["a"] = {
            "add",
            config = { show_path = "none" },
          },
          ["A"] = "add_directory",
          ["d"] = "delete",
          ["r"] = "rename",
          ["y"] = "copy_to_clipboard",
          ["x"] = "cut_to_clipboard",
          ["p"] = "paste_from_clipboard",
          ["c"] = "copy",
          ["m"] = "move",
          ["q"] = "close_window",
          ["R"] = "refresh",
          ["?"] = "show_help",
          ["<"] = "prev_source",
          [">"] = "next_source",
        },
      },
      default_component_configs = {
        container = {
          enable_character_fade = true,
        },
        indent = {
          indent_size = 2,
          padding = 1,
          with_markers = true,
          indent_marker = "│",
          last_indent_marker = "└",
          highlight = "NeoTreeIndentMarker",
          with_expanders = nil,
          expander_collapsed = "",
          expander_expanded = "",
          expander_highlight = "NeoTreeExpander",
        },
        icon = {
          folder_closed = "",
          folder_open = "",
          folder_empty = "󰜌",
          default = "*",
          highlight = "NeoTreeFileIcon",
        },
        modified = {
          symbol = "[+]",
          highlight = "NeoTreeModified",
        },
        name = {
          trailing_slash = false,
          use_git_status_colors = true,
          highlight = "NeoTreeFileName",
        },
        git_status = {
          symbols = {
            added = "",
            modified = "",
            deleted = "✖",
            renamed = "󰁕",
            untracked = "",
            ignored = "",
            unstaged = "󰄱",
            staged = "",
            conflict = "",
          },
        },
      },
      filesystem = {
        filtered_items = {
          visible = false,
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_hidden = false,
          hide_by_name = {
            ".DS_Store",
            "thumbs.db",
          },
          never_show = {},
        },
        follow_current_file = {
          enabled = false,
        },
        group_empty_dirs = false,
        hijack_netrw_behavior = "open_current",
        use_libuv_file_watcher = true,
        window = {
          mappings = {
            ["<bs>"] = "navigate_up",
            ["."] = "set_root",
            ["H"] = "toggle_hidden",
            ["/"] = "fuzzy_finder",
            ["D"] = "fuzzy_finder_directory",
            ["f"] = "filter_on_submit",
            ["<c-x>"] = "clear_filter",
            ["[g"] = "prev_git_modified",
            ["]g"] = "next_git_modified",
          },
        },
        commands = {
          rename = function(state)
            local node = state.tree:get_node()
            if not node then
              return
            end

            local path = node:get_id()
            local old_name = vim.fn.fnamemodify(path, ":t")

            vim.ui.input({
              prompt = "Rename " .. old_name .. " to: ",
              default = old_name,
              completion = "file",
            }, function(new_name)
              if not new_name or new_name == "" or new_name == old_name then
                return
              end

              local new_path = vim.fn.fnamemodify(path, ":h") .. "/" .. new_name

              -- Ensure parent directory exists
              local parent_path = vim.fn.fnamemodify(new_path, ":h")
              if vim.fn.isdirectory(parent_path) == 0 then
                vim.fn.mkdir(parent_path, "p")
              end

              -- Perform the rename
              local success = vim.uv.fs_rename(path, new_path)
              if success then
                vim.schedule(function()
                  require("neo-tree.sources.manager").refresh(state.name)
                  vim.api.nvim_echo({ { string.format("Renamed %s to %s", old_name, new_name), "Normal" } }, false, {})
                end)
              else
                vim.schedule(function()
                  vim.api.nvim_echo(
                    { { string.format("Failed to rename %s to %s", old_name, new_name), "ErrorMsg" } },
                    false,
                    {}
                  )
                end)
              end
            end)
          end,

          delete = function(state)
            local node = state.tree:get_node()
            if not node then
              return
            end

            local path = node:get_id()
            local name = vim.fn.fnamemodify(path, ":t")

            vim.ui.select({ "Yes", "No" }, {
              prompt = string.format("Delete %s?", name),
            }, function(choice)
              if choice ~= "Yes" then
                return
              end

              local success
              if vim.fn.executable("trash") == 1 then
                success = os.execute("trash " .. vim.fn.shellescape(path)) == 0
              else
                success = vim.fn.delete(path, "rf") == 0
              end

              vim.schedule(function()
                if success then
                  require("neo-tree.sources.manager").refresh(state.name)
                  vim.api.nvim_echo({ { string.format("Deleted %s", name), "Normal" } }, false, {})
                else
                  vim.api.nvim_echo({ { string.format("Failed to delete %s", name), "ErrorMsg" } }, false, {})
                end
              end)
            end)
          end,

          delete_visual = function(state, selected_nodes)
            if not selected_nodes or #selected_nodes == 0 then
              return
            end

            local paths = {}
            for _, node in ipairs(selected_nodes) do
              table.insert(paths, node:get_id())
            end

            vim.ui.select({ "Yes", "No" }, {
              prompt = string.format("Delete %d items?", #paths),
            }, function(choice)
              if choice ~= "Yes" then
                return
              end

              local success = true
              for _, path in ipairs(paths) do
                local current_success
                if vim.fn.executable("trash") == 1 then
                  current_success = os.execute("trash " .. vim.fn.shellescape(path)) == 0
                else
                  current_success = vim.fn.delete(path, "rf") == 0
                end
                success = success and current_success
              end

              vim.schedule(function()
                if success then
                  require("neo-tree.sources.manager").refresh(state.name)
                  vim.api.nvim_echo({ { string.format("Deleted %d items", #paths), "Normal" } }, false, {})
                else
                  vim.api.nvim_echo({ { string.format("Failed to delete some items"), "ErrorMsg" } }, false, {})
                end
              end)
            end)
          end,
        },
      },
      buffers = {
        follow_current_file = {
          enabled = true,
          leave_dirs_open = false,
        },
        group_empty_dirs = true,
        show_unloaded = true,
      },
    })

    vim.keymap.set("n", "<leader>e", function()
      require("neo-tree.command").execute({
        action = "show",
        source = "filesystem",
        toggle = true,
        position = "left",
      })
    end, { noremap = true, silent = true, desc = "Toggle Neo-tree" })

    vim.keymap.set("n", "\\", function()
      local reveal_file = vim.fn.expand("%:p")
      if reveal_file == "" then
        reveal_file = nil
      end

      require("neo-tree.command").execute({
        action = "show",
        source = "filesystem",
        toggle = true,
        reveal_file = reveal_file,
      })
    end, { noremap = true, silent = true, desc = "Toggle Neo-tree with current file" })
  end,
}
