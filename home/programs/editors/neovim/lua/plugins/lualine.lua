return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy", -- Load after initial UI is rendered
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "folke/trouble.nvim", -- For symbol statusline integration
  },
  config = function()
    local lualine = require("lualine")
    local lazy_status = require("lazy.status") -- to configure lazy pending updates count

    -- Utility function for string truncation
    local function trunc(trunc_width, trunc_len, hide_width, no_ellipsis)
      return function(str)
        local win_width = vim.fn.winwidth(0)
        if hide_width and win_width < hide_width then
          return ""
        elseif trunc_width and trunc_len and win_width < trunc_width and #str > trunc_len then
          return str:sub(1, trunc_len) .. (no_ellipsis and "" or "...")
        end
        return str
      end
    end

    -- Color palette
    local colors = {
      -- Base colors
      blue = "#61afef",
      green = "#98c379",
      purple = "#c678dd",
      cyan = "#56b6c2",
      red1 = "#e06c75",
      red2 = "#be5046",
      yellow = "#e5c07b",
      orange = "#d19a66",

      -- Monochrome
      fg = "#abb2bf",
      bg = "#282c34",
      gray1 = "#828997",
      gray2 = "#2c323c",
      gray3 = "#3e4452",

      -- Git colors
      git_add = "#98c379",
      git_change = "#61afef",
      git_delete = "#e06c75",

      -- Diagnostic colors
      error = "#e06c75",
      warn = "#e5c07b",
      info = "#61afef",
      hint = "#56b6c2",
    }

    -- Icons
    local icons = {
      -- Mode
      normal = "",
      insert = "",
      visual = "",
      replace = "󰛔",
      command = "",
      terminal = "",

      -- Git
      git_branch = "",
      git_added = "",
      git_modified = "",
      git_removed = "",

      -- Diagnostics
      diagnostic_error = "",
      diagnostic_warn = "",
      diagnostic_info = "",
      diagnostic_hint = "",
      diagnostic_ok = "",

      -- Folding
      fold_lsp = "󱧊",
      fold_treesitter = "",
      fold_indent = "",
      fold_none = "󰝾",

      -- LSP
      lsp_client = "",
      lsp_progress = "",
      lsp_progress_done = "",

      -- File
      file_permissions = "",

      -- Package
      package_pending = "",
      package_installed = "",
      package_uninstalled = "",

      -- Term
      term = "",

      -- Misc
      line_number = " 󰏽",
      connected = "󰌘",
      disconnected = "󰌙",
      progress = "󰔟",
      lock = "",
      dots = "󰇘",
      recording = "󰑋",
      copilot = "",
    }

    -- Cache system for improved performance
    local cache = {
      branch = "",
      branch_color = nil,
      file_permissions = { perms = "", color = colors.green },
      lsp_clients = {},
    }

    -- Set up autocmds for cache updates
    vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained" }, {
      callback = function()
        -- Update git branch
        local branch = vim.fn.system("git rev-parse --abbrev-ref HEAD 2>/dev/null"):gsub("\n", "")
        cache.branch = (branch ~= "") and branch or ""
        cache.branch_color = (cache.branch == "live" or cache.branch == "main" or cache.branch == "master")
            and { fg = colors.red1, gui = "bold" }
          or nil
      end,
    })

    vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
      callback = function()
        if vim.bo.filetype ~= "sh" then
          cache.file_permissions = { perms = "", color = colors.gray1 }
          return
        end
        local file_path = vim.fn.expand("%:p")
        local permissions = file_path and vim.fn.getfperm(file_path) or "No File"
        local owner_permissions = permissions:sub(1, 3)
        cache.file_permissions = {
          perms = permissions,
          color = (owner_permissions == "rwx") and colors.green or colors.gray1,
        }
      end,
    })

    -- Update LSP clients cache
    vim.api.nvim_create_autocmd({ "LspAttach", "LspDetach", "BufEnter" }, {
      callback = function()
        local buf_clients = vim.lsp.get_clients({ bufnr = 0 })
        cache.lsp_clients = buf_clients
      end,
    })

    -- Utility functions
    local function hide_in_width()
      return vim.fn.winwidth(0) > 100
    end

    local function hide_in_small_window()
      return vim.fn.winwidth(0) > 70
    end

    local function get_venv_name()
      local venv = os.getenv("VIRTUAL_ENV")
      if not venv then
        return ""
      end
      local name = venv:match("([^/]+)$")
      return name or ""
    end

    local function should_show_permissions()
      return vim.bo.filetype == "sh" and vim.fn.expand("%:p") ~= ""
    end

    local function should_show_spell_status()
      return vim.wo.spell
    end

    local function get_spell_status()
      local lang_map = { en = "English", es = "Spanish" }
      return "Spell: " .. (lang_map[vim.bo.spelllang] or vim.bo.spelllang)
    end

    -- Macro recording indicator
    local function show_macro_recording()
      local recording_register = vim.fn.reg_recording()
      if recording_register == "" then
        return ""
      else
        return icons.recording .. "  " .. recording_register
      end
    end

    -- Word count for text files
    local function get_word_count()
      local ft = vim.bo.filetype
      if ft == "markdown" or ft == "md" or ft == "txt" or ft == "text" then
        local wc = vim.fn.wordcount()
        if wc.visual_words then
          return wc.visual_words == 1 and "1 word" or wc.visual_words .. " words"
        else
          return wc.words .. " words"
        end
      end
      return ""
    end

    local function should_show_word_count()
      local ft = vim.bo.filetype
      return ft == "markdown" or ft == "md" or ft == "txt" or ft == "text"
    end

    -- Visual scroll position with icons
    local function get_scroll_position()
      local progress_icons = {
        "󰋙",
        "󰫃",
        "󰫄",
        "󰫅",
        "󰫆",
        "󰫇",
        "󰫈",
      }
      local current = vim.api.nvim_win_get_cursor(0)[1]
      local lines = vim.api.nvim_buf_line_count(0)
      local i = math.floor((current - 1) / lines * #progress_icons) + 1
      return progress_icons[i] or progress_icons[1]
    end

    local function get_file_permissions()
      if vim.bo.filetype ~= "sh" then
        return "", colors.gray1
      end
      local file_path = vim.fn.expand("%:p")
      local permissions = file_path and vim.fn.getfperm(file_path) or "No File"
      local owner_permissions = permissions:sub(1, 3)
      return permissions, (owner_permissions == "rwx") and colors.green or colors.gray1
    end

    local function create_separator(condition)
      return {
        cond = condition,
        function()
          return " "
        end,
        color = { fg = colors.gray3, bg = colors.bg },
        separator = { left = "", right = "" },
        padding = 0,
      }
    end

    -- NEW: LSP Clients component with count and color
    local function get_lsp_clients()
      local buf_clients = vim.lsp.get_clients({ bufnr = 0 })
      if #buf_clients == 0 then
        return ""
      end

      local client_names = {}
      for _, client in ipairs(buf_clients) do
        table.insert(client_names, client.name)
      end

      -- Show count and first client name
      if #client_names == 1 then
        return icons.lsp_client .. " " .. client_names[1]
      else
        return icons.lsp_client .. " " .. client_names[1] .. " (+" .. (#client_names - 1) .. ")"
      end
    end

    local function has_lsp_clients()
      return #vim.lsp.get_clients({ bufnr = 0 }) > 0
    end

    -- NEW: Copilot status (if using copilot)
    local function get_copilot_status()
      local copilot_ok, copilot_status = pcall(function()
        return require("copilot.api").status.data.status
      end)

      if not copilot_ok then
        return ""
      end

      if copilot_status == "Normal" then
        return icons.copilot
      elseif copilot_status == "InProgress" then
        return icons.copilot .. " …"
      else
        return ""
      end
    end

    local function has_copilot()
      local ok = pcall(require, "copilot")
      return ok
    end

    -- NEW: Improved DAP status
    local function get_dap_status()
      local dap_ok, dap = pcall(require, "dap")
      if not dap_ok then
        return ""
      end

      local session = dap.session()
      if session then
        return " DEBUGGING"
      end
      return ""
    end

    local function has_dap_session()
      local dap_ok, dap = pcall(require, "dap")
      if not dap_ok then
        return false
      end
      return dap.session() ~= nil
    end

    -- Component configurations
    local mode = {
      "mode",
      fmt = function(str)
        local mode_icons = {
          NORMAL = icons.normal,
          INSERT = icons.insert,
          VISUAL = icons.visual,
          ["V-LINE"] = icons.visual,
          ["V-BLOCK"] = icons.visual,
          REPLACE = icons.replace,
          COMMAND = icons.command,
          TERMINAL = icons.terminal,
        }
        return " " .. (mode_icons[str] or "") .. " " .. str
      end,
    }

    local filename = {
      "filename",
      file_status = true,
      path = 1,
      shorting_target = 40,
      symbols = {
        modified = "[+]",
        readonly = "",
        unnamed = "[No Name]",
        newfile = "[New]",
      },
    }

    local diagnostics = {
      "diagnostics",
      sources = { "nvim_diagnostic" },
      sections = { "error", "warn", "info", "hint" },
      symbols = {
        error = icons.diagnostic_error .. " ",
        warn = icons.diagnostic_warn .. " ",
        info = icons.diagnostic_info .. " ",
        hint = icons.diagnostic_hint .. " ",
      },
      colored = true,
      update_in_insert = false,
      always_visible = false,
      diagnostics_color = {
        error = { fg = colors.error },
        warn = { fg = colors.warn },
        info = { fg = colors.info },
        hint = { fg = colors.hint },
      },
    }

    local diff = {
      "diff",
      colored = true,
      symbols = {
        added = icons.git_added .. " ",
        modified = icons.git_modified .. " ",
        removed = icons.git_removed .. " ",
      },
      diff_color = {
        added = { fg = colors.git_add },
        modified = { fg = colors.git_change },
        removed = { fg = colors.git_delete },
      },
      cond = hide_in_width,
    }

    local branch = {
      "branch",
      icons_enabled = true,
      icon = icons.git_branch,
      colored = true,
      color = function()
        return cache.branch_color
      end,
      fmt = trunc(120, 20), -- Truncate branch name in small windows
    }

    local location = {
      "location",
      padding = 0,
      fmt = function()
        return icons.line_number .. " %l:%c "
      end,
    }

    local progress = {
      "progress",
      fmt = function(str)
        return icons.progress .. " " .. str
      end,
    }

    local fold_method = {
      function()
        local ok, folding = pcall(require, "config.folding")
        if not ok or type(folding) ~= "table" then
          return ""
        end
        ---@type string
        local method = folding.get_fold_method()
        local method_icons = {
          lsp = icons.fold_lsp,
          treesitter = icons.fold_treesitter,
          indent = icons.fold_indent,
          none = icons.fold_none,
        }
        return method_icons[method] .. " " .. method:upper()
      end,
      cond = hide_in_small_window,
      color = { fg = colors.purple },
    }

    -- Trouble symbols statusline integration
    local trouble_symbols = {
      get = function()
        return ""
      end,
      has = function()
        return false
      end,
    }

    -- Initialize Trouble symbols statusline if available
    local ok, trouble = pcall(require, "trouble")
    if ok then
      trouble_symbols = trouble.statusline({
        mode = "lsp_document_symbols",
        groups = {},
        title = false,
        filter = { range = true },
        format = "{kind_icon}{symbol.name:Normal}",
        hl_group = "lualine_c_normal",
      })
    end

    -- Setup
    require("lualine").setup({
      options = {
        icons_enabled = true,
        theme = "auto", -- Auto-detect from colorscheme
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = {
          statusline = { "dashboard", "alpha", "starter" },
          winbar = {
            "help",
            "startify",
            "dashboard",
            "packer",
            "neogitstatus",
            "NvimTree",
            "Trouble",
            "alpha",
            "lir",
            "Outline",
            "spectre_panel",
            "toggleterm",
            "qf",
          },
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = true,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        },
      },
      sections = {
        lualine_a = { mode },
        lualine_b = {
          branch,
          {
            get_venv_name,
            color = { fg = colors.cyan, gui = "bold" },
            cond = function()
              return get_venv_name() ~= ""
            end,
          },
          diff,
        },
        lualine_c = {
          filename,
          diagnostics,
          -- Trouble: Current symbol (function, class, etc.)
          {
            trouble_symbols.get,
            cond = trouble_symbols.has,
            color = { fg = colors.cyan, gui = "italic" },
          },
          -- NEW: LSP clients with count
          {
            get_lsp_clients,
            color = { fg = colors.blue, gui = "bold" },
            cond = has_lsp_clients,
          },
          -- Word count for text files
          {
            get_word_count,
            color = { fg = colors.gray1, bg = colors.gray2, gui = "bold" },
            separator = { left = "", right = "" },
            padding = 1,
            cond = should_show_word_count,
          },
          -- Macro recording indicator
          {
            show_macro_recording,
            color = { fg = "#ffffff", bg = colors.red1, gui = "bold" },
            separator = { left = "", right = "" },
            padding = 1,
          },
          -- NEW: DAP debugging status
          {
            get_dap_status,
            color = { fg = "#ffffff", bg = colors.orange, gui = "bold" },
            separator = { left = "", right = "" },
            padding = 1,
            cond = has_dap_session,
          },
          -- Search count
          { "searchcount", cond = hide_in_small_window },
          -- Selection count
          { "selectioncount", cond = hide_in_small_window },
        },
        lualine_x = {
          -- NEW: Copilot status
          {
            get_copilot_status,
            cond = has_copilot,
            color = { fg = colors.green, gui = "bold" },
          },
          -- Lazy status with icon
          {
            function()
              return icons.package_pending .. " " .. lazy_status.updates()
            end,
            cond = lazy_status.has_updates,
            color = { fg = colors.orange, gui = "bold" },
          },
          -- Spell status with separators
          create_separator(should_show_spell_status),
          {
            get_spell_status,
            cond = should_show_spell_status,
            color = function()
              return { fg = colors.purple, bg = colors.bg, gui = "bold" }
            end,
            separator = { left = "", right = "" },
            padding = 1,
          },
          -- Permissions with separators
          create_separator(should_show_permissions),
          {
            get_file_permissions,
            cond = should_show_permissions,
            color = function()
              local _, color = get_file_permissions()
              return { fg = color, bg = colors.bg, gui = "bold" }
            end,
            separator = { left = "", right = "" },
            padding = 1,
          },
          fold_method,
          "encoding",
          {
            "fileformat",
            symbols = {
              unix = "LF",
              dos = "CRLF",
              mac = "CR",
            },
          },
          "filetype",
        },
        lualine_y = {
          {
            "location",
            padding = 0,
            fmt = function()
              return icons.line_number .. " %l:%c " .. get_scroll_position()
            end,
          },
          progress,
        },
        lualine_z = {},
      },
      -- inactive sections
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = {
        "neo-tree",
        "lazy",
        "trouble",
        "quickfix",
        "toggleterm",
        "nvim-dap-ui",
      },
    })

    -- Auto-refresh lualine when macro recording starts/stops
    vim.api.nvim_create_autocmd("RecordingEnter", {
      callback = function()
        lualine.refresh()
      end,
    })

    vim.api.nvim_create_autocmd("RecordingLeave", {
      callback = function()
        -- Wait 50ms for vim.fn.reg_recording() to clear before refreshing
        local timer = vim.loop.new_timer()
        timer:start(
          50,
          0,
          vim.schedule_wrap(function()
            lualine.refresh()
          end)
        )
      end,
    })
  end,
}
