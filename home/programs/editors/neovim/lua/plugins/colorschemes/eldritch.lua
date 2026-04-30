-- https://github.com/eldritch-theme/eldritch.nvim
--

local palette = require("config.colors")

return {
  "eldritch-theme/eldritch.nvim",
  lazy = false,
  priority = 1000, -- Make sure it loads before other plugins
  name = "eldritch",
  opts = {
    transparent = false,
    styles = {
      -- Style to be applied to different syntax groups
      -- Value is any valid attr-list value for `:help nvim_set_hl`
      comments = { italic = true },
      keywords = { italic = true },
      functions = {},
      variables = {},
      -- Background styles. Can be "dark", "transparent" or "normal"
      sidebars = "dark",
      floats = "dark",
    },
    on_colors = function(colors)
      local color_definitions = {
        bg = palette.color10,
        fg = palette.color14,
        comment = palette.color09,
        selection = palette.color16,
        visual = palette.color16,
        bg_visual = palette.color16,

        red = palette.color11,
        orange = palette.color08,
        yellow = palette.color12,
        green = palette.color02,
        purple = palette.color04,
        cyan = palette.color03,
        pink = palette.color01,

        bright_red = palette.color11,
        bright_green = palette.color02,
        bright_yellow = palette.color12,
        bright_blue = palette.color04,
        bright_magenta = palette.color01,
        bright_cyan = palette.color03,
        bright_white = palette.color14,

        white = palette.color14,
        black = palette.color10,
        menu = palette.color10,
        bg_dark = palette.color17,
        bg_highlight = palette.color17,
        terminal_black = palette.color13,
        fg_dark = palette.color09,
        fg_gutter = palette.color13,
        fg_gutter_light = palette.color09,
        dark3 = palette.color13,
        dark5 = palette.color13,
        dark_cyan = palette.color03,
        dark_yellow = palette.color08,
        dark_green = palette.color02,
        magenta = palette.color01,
        magenta2 = palette.color01,
        magenta3 = palette.color21,

        git = {
          change = palette.color03,
          add = palette.color02,
          delete = palette.color11,
        },
        gitSigns = {
          change = palette.color03,
          add = palette.color02,
          delete = palette.color11,
        },
      }

      for key, value in pairs(color_definitions) do
        colors[key] = value
      end
    end,

    on_highlights = function(highlights, colors)
      local highlight_definitions = {
        DiffAdd = { bg = colors.green, fg = colors.black },
        DiffChange = { bg = colors.cyan, fg = colors.black },
        DiffDelete = { bg = colors.red, fg = colors.black },
        FzfLuaResultsDiffDelete = { bg = colors.red, fg = colors.black },

        CursorLine = { bg = colors.terminal_black },
        ColorColumn = { bg = colors.terminal_black },
        Cursor = { bg = palette.color24 },
        lCursor = { bg = palette.color24 },
        CursorIM = { bg = palette.color24 },
        Visual = { bg = colors.bg_visual, fg = colors.black },

        ["@markup.strong"] = { fg = palette.color24, bold = true },
        ["@markup.raw.markdown_inline"] = { fg = colors.green },
        Folded = { bg = "NONE" },
        RenderMarkdownCode = { bg = palette.color07 },
        RenderMarkdownQuote = { fg = colors.yellow },

        SpellBad = { sp = colors.red, undercurl = true, bold = true, italic = true },
        SpellCap = { sp = colors.yellow, undercurl = true, bold = true, italic = true },
        SpellLocal = { sp = colors.yellow, undercurl = true, bold = true, italic = true },
        SpellRare = { sp = colors.purple, undercurl = true, bold = true, italic = true },

        MiniDiffSignAdd = { fg = colors.green, bold = true },
        MiniDiffSignChange = { fg = colors.cyan, bold = true },

        DiagnosticError = { fg = colors.red },
        DiagnosticWarn = { fg = colors.yellow },
        DiagnosticInfo = { fg = colors.cyan },
        DiagnosticHint = { fg = colors.green },
        DiagnosticOk = { fg = colors.green },

        PreProc = { fg = palette.color06 },
        ["@operator"] = { fg = colors.green },

        KubectlHeader = { fg = colors.purple },
        KubectlWarning = { fg = colors.yellow },
        KubectlError = { fg = colors.red },
        KubectlInfo = { fg = colors.cyan },
        KubectlDebug = { fg = colors.purple },
        KubectlSuccess = { fg = colors.green },
        KubectlPending = { fg = colors.yellow },
        KubectlDeprecated = { fg = colors.comment },
        KubectlExperimental = { fg = colors.pink },
        KubectlNote = { fg = colors.cyan },
        KubectlGray = { fg = colors.fg_gutter_light },

        FzfLuaFzfPrompt = { fg = colors.purple, bg = colors.bg },
        FzfLuaCursorLine = { fg = colors.green, bg = colors.terminal_black },
        FzfLuaTitle = { fg = colors.cyan, bg = colors.bg },
        FzfLuaSearch = { fg = colors.fg, bg = colors.bg },
        FzfLuaBorder = { fg = colors.green, bg = colors.bg },
        FzfLuaNormal = { fg = colors.fg, bg = colors.bg },
        FzfLuaMultiSelection = { fg = colors.green, bg = colors.bg },
        FzfLuaSelection = { fg = colors.fg, bg = colors.terminal_black },
      }

      for group, props in pairs(highlight_definitions) do
        highlights[group] = props
      end
    end,
  },
}
