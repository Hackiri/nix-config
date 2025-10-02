-- Get colors from the colors module
local colors = require("config.colors")
local icons = LazyVim.config.icons

return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  version = "*",
  dependencies = {
    { "nvim-tree/nvim-web-devicons", version = "*" },
    { "nvim-lua/lsp-status.nvim", version = "*" },
  },
  opts = function()
    local icons = {
      diagnostics = {
        Error = " ",
        Warn = " ",
        Hint = " ",
        Info = " ",
      },
      git = {
        added = " ",
        modified = " ",
        removed = " ",
      },
      kinds = {
        Array = " ",
        Boolean = " ",
        Class = " ",
        Constructor = " ",
        Enum = " ",
        EnumMember = " ",
        Event = " ",
        Field = " ",
        File = " ",
        Folder = " ",
        Function = " ",
        Interface = " ",
        Key = " ",
        Keyword = " ",
        Method = " ",
        Module = " ",
        Namespace = " ",
        Null = " ",
        Number = " ",
        Object = " ",
        Operator = " ",
        Package = " ",
        Property = " ",
        Reference = " ",
        Snippet = " ",
        String = " ",
        Struct = " ",
        Text = " ",
        TypeParameter = " ",
        Unit = " ",
        Value = " ",
        Variable = " ",
      },
    }

    local function fg(name)
      return function()
        local hl = vim.api.nvim_get_hl_by_name(name, true)
        return hl and hl.foreground and { fg = string.format("#%06x", hl.foreground) }
      end
    end

    -- Cache system for better performance
    local cache = {
      branch = "",
      branch_color = nil,
      commit_hash = "",
      file_permissions = { perms = "", color = nil },
    }

    -- Helper function to get color with proper naming convention
    local function getColor(name)
      -- Convert color03 format to color3 format if needed
      if type(name) == "string" and name:match("^color0%d$") then
        name = "color" .. tonumber(name:sub(-1))
      end
      return colors[name] or colors.foreground
    end

    -- Set up autocmds for cache updates
    vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained" }, {
      callback = function()
        -- Update git branch
        cache.branch = vim.fn.system("git rev-parse --abbrev-ref HEAD 2>/dev/null"):gsub("\n", "")
        if cache.branch == "" or cache.branch:match("fatal") then
          cache.branch = ""
          cache.branch_color = nil
        else
          cache.branch_color = (cache.branch == "live") and { fg = getColor("color11"), gui = "bold" } or nil
        end

        -- Update commit hash only for dotfiles-latest repo
        local git_dir = vim.fn.system("git rev-parse --git-dir 2>/dev/null"):gsub("\n", "")
        if git_dir ~= "" and not git_dir:match("fatal") then
          local repo_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "")
          if repo_root:match("dotfiles%-latest$") or repo_root:match("nix%-darwin%-config$") then
            cache.commit_hash = vim.fn.system("git rev-parse --short=7 HEAD 2>/dev/null"):gsub("\n", "")
          else
            cache.commit_hash = ""
          end
        else
          cache.commit_hash = ""
        end
      end,
    })

    vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
      callback = function()
        if vim.bo.filetype ~= "sh" then
          cache.file_permissions = { perms = "", color = nil }
          return
        end
        local file_path = vim.fn.expand("%:p")
        local permissions = file_path and vim.fn.getfperm(file_path) or "No File"
        local owner_permissions = permissions:sub(1, 3)
        cache.file_permissions = {
          perms = permissions,
          color = (owner_permissions == "rwx") and getColor("color2") or getColor("color3"),
        }
      end,
    })

    -- Custom component for virtual env
    local function venv()
      local venv_name = os.getenv("VIRTUAL_ENV")
      if venv_name then
        return "󰌠 " .. vim.fn.fnamemodify(venv_name, ":t")
      end
      return ""
    end

    -- Enhanced file permissions component with caching
    local function file_permissions()
      local file = vim.fn.expand("%:p")
      if file == "" or vim.bo.filetype ~= "sh" then
        return ""
      end

      return " " .. cache.file_permissions.perms
    end

    -- Custom component for spell status
    local function spell_status()
      if not vim.wo.spell then
        return ""
      end

      local lang_map = {
        en = "EN",
        es = "ES",
      }

      return "󰓆 " .. (lang_map[vim.bo.spelllang] or vim.bo.spelllang)
    end

    -- Custom component for fold method
    local function fold_method()
      local foldmethod = vim.wo.foldmethod
      if foldmethod == "manual" then
        return ""
      end
      return "󰡀 " .. foldmethod
    end

    -- Enhanced git branch component with caching and commit hash
    local function git_branch()
      if cache.branch == "" then
        return ""
      end

      return cache.branch .. (cache.commit_hash ~= "" and " " .. cache.commit_hash or "")
    end

    -- Create a separator function for consistent styling
    local function create_separator(condition)
      return {
        function()
          return ""
        end,
        color = { fg = getColor("color14") },
        separator = { left = "", right = "" },
        padding = 0,
        cond = condition,
      }
    end

    return {
      options = {
        theme = "auto",
        globalstatus = true,
        disabled_filetypes = { statusline = { "dashboard", "alpha" } },
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {
          {
            git_branch,
            color = function()
              return cache.branch_color
            end,
            separator = { right = "" },
            padding = 1,
          },
        },
        lualine_c = {
          {
            "diagnostics",
            symbols = {
              error = icons.diagnostics.Error,
              warn = icons.diagnostics.Warn,
              info = icons.diagnostics.Info,
              hint = icons.diagnostics.Hint,
            },
          },
          {
            "filetype",
            icon_only = true,
            separator = "",
            padding = { left = 1, right = 0 },
          },
          {
            "filename",
            path = 1,
            symbols = {
              modified = "  ",
              readonly = "",
              unnamed = "",
            },
          },
          -- Language/Parser indicator
          {
            function()
              local buf = vim.api.nvim_get_current_buf()
              local ft = vim.bo[buf].filetype
              if ft == "" then
                return ""
              end
              
              -- Check if treesitter is active for this buffer
              local ts_active = vim.treesitter.highlighter.active[buf] ~= nil
              if ts_active then
                -- Get the language from treesitter
                local lang = vim.treesitter.language.get_lang(ft) or ft
                return " " .. lang
              end
              
              return ""
            end,
            color = { fg = "#7aa2f7", gui = "bold" }, -- Blue color for language
            cond = function()
              return vim.bo.filetype ~= ""
            end,
          },
          { file_permissions },
          {
            function()
              return require("nvim-navic").get_location()
            end,
            cond = function()
              return package.loaded["nvim-navic"] and require("nvim-navic").is_available()
            end,
          },
        },
        lualine_x = {
          { spell_status },
          { fold_method },
          { venv },
          {
            function()
              return require("noice").api.status.command.get()
            end,
            cond = function()
              return package.loaded["noice"] and require("noice").api.status.command.has()
            end,
            color = fg("Statement"),
          },
          {
            function()
              return require("noice").api.status.mode.get()
            end,
            cond = function()
              return package.loaded["noice"] and require("noice").api.status.mode.has()
            end,
            color = fg("Constant"),
          },
          {
            require("lazy.status").updates,
            cond = require("lazy.status").has_updates,
            color = fg("Special"),
          },
          {
            "diff",
            symbols = {
              added = icons.git.added,
              modified = icons.git.modified,
              removed = icons.git.removed,
            },
          },
        },
        lualine_y = {
          { "progress", separator = " ", padding = { left = 1, right = 0 } },
          { "location", padding = { left = 0, right = 1 } },
        },
        lualine_z = {
          function()
            return " " .. os.date("%R")
          end,
        },
      },
      extensions = { "lazy", "fzf" }, -- Removed neo-tree to maintain branch visibility in neo-tree
    }
  end,
}
