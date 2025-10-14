return {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "nvim-lua/lsp-status.nvim", -- For LSP status
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
    }

    -- Cache system for improved performance
    local cache = {
      branch = "",
      branch_color = nil,
      file_permissions = { perms = "", color = colors.green },
    }

    -- Set up autocmds for cache updates
    vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained" }, {
      callback = function()
        -- Update git branch
        local branch = vim.fn.system("git rev-parse --abbrev-ref HEAD 2>/dev/null"):gsub("\n", "")
        cache.branch = (branch ~= "") and branch or ""
        cache.branch_color = (cache.branch == "live") and { fg = colors.red1, gui = "bold" } or nil
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

    -- LSP status function
    local function get_lsp_status()
      local clients = vim.lsp.get_clients()
      if #clients == 0 then
        return icons.disconnected .. " No LSP"
      end
      local buf_clients = vim.lsp.get_clients({ bufnr = 0 })
      if #buf_clients == 0 then
        return icons.disconnected .. " No LSP"
      end
      local buf_client_names = {}
      for _, client in pairs(buf_clients) do
        table.insert(buf_client_names, client.name)
      end
      return icons.lsp_client .. " " .. table.concat(buf_client_names, ", ")
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

    -- Setup
    require("lualine").setup({
      options = {
        icons_enabled = true,
        theme = "catppuccin-mocha", -- Changed to use specific catppuccin flavor
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
          {
            get_lsp_status,
            color = { fg = colors.blue, gui = "bold" },
            cond = hide_in_width,
          },
        },
        lualine_x = {
          -- Lazy status
          {
            lazy_status.updates,
            cond = lazy_status.has_updates,
            color = { fg = colors.orange },
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
          location,
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
  end,
}
