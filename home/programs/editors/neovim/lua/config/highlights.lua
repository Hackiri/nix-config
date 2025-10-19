-- Set up highlights for completion menu
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    -- Get terminal background color
    -- -- Get terminal background color
    -- local active_theme = vim.g.colors_name
    -- if active_theme == "tokyonight" then -- change to your preferred theme(s)
    --   -- local bg = "#1a1b26" -- Tokyo Night terminal background
    --   -- local border_color = "#292e42" -- Subtle border color
    --   -- ... your highlight overrides here ...
    --   -- vim.api.nvim_set_hl(0, "Normal", { bg = bg })
    --   -- (repeat for other highlight groups)
    -- end
    -- Get background color from the active colorscheme
    local normal_hl = vim.api.nvim_get_hl(0, { name = "Normal" })
    local bg = normal_hl.bg and string.format("#%06x", normal_hl.bg) or "#1a1b26"

    local border_hl = vim.api.nvim_get_hl(0, { name = "FloatBorder" })
    local border_color = border_hl.fg and string.format("#%06x", border_hl.fg) or "#292e42"

    -- General UI background
    vim.api.nvim_set_hl(0, "Normal", { bg = bg })
    vim.api.nvim_set_hl(0, "NormalNC", { bg = bg }) -- Non-current windows
    vim.api.nvim_set_hl(0, "SignColumn", { bg = bg })
    vim.api.nvim_set_hl(0, "MsgArea", { bg = bg })
    vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = bg })

    -- Command line and input UI
    vim.api.nvim_set_hl(0, "MsgArea", { bg = bg })
    vim.api.nvim_set_hl(0, "MsgSeparator", { bg = bg })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = bg })
    vim.api.nvim_set_hl(0, "FloatBorder", { fg = border_color, bg = bg })

    -- Command line completion
    vim.api.nvim_set_hl(0, "Pmenu", { bg = bg })
    vim.api.nvim_set_hl(0, "PmenuBorder", { fg = border_color, bg = bg })
    vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#363b54", blend = 20 })
    vim.api.nvim_set_hl(0, "PmenuSbar", { bg = "#363b54", blend = 20 })
    vim.api.nvim_set_hl(0, "PmenuThumb", { bg = border_color })
    vim.api.nvim_set_hl(0, "WildMenu", { bg = bg })

    -- Search and incremental search
    vim.api.nvim_set_hl(0, "Search", { bg = "#1a1b26", fg = "#7aa2f7", bold = true })
    vim.api.nvim_set_hl(0, "IncSearch", { bg = "#1a1b26", fg = "#7aa2f7", bold = true })
    vim.api.nvim_set_hl(0, "CurSearch", { bg = "#1a1b26", fg = "#7aa2f7", bold = true })

    -- Popup menu and documentation
    vim.api.nvim_set_hl(0, "PopupNormal", { bg = bg })
    vim.api.nvim_set_hl(0, "PopupBorder", { fg = border_color, bg = bg })
    vim.api.nvim_set_hl(0, "FloatShadow", { bg = bg })
    vim.api.nvim_set_hl(0, "FloatShadowThrough", { bg = bg })

    -- CMP specific with matching borders
    vim.api.nvim_set_hl(0, "CmpItemAbbr", { fg = "#787c99", bg = bg })
    vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { fg = "#7aa2f7", bg = bg, bold = true })
    vim.api.nvim_set_hl(0, "CmpItemAbbrMatchFuzzy", { fg = "#7aa2f7", bg = bg, bold = true })
    vim.api.nvim_set_hl(0, "CmpItemMenu", { fg = "#565f89", bg = bg, italic = true })
    vim.api.nvim_set_hl(0, "CmpBorder", { fg = border_color, bg = bg })

    -- Ghost text highlight
    vim.api.nvim_set_hl(0, "CmpGhostText", { fg = "#565f89", italic = true })

    -- Kind highlights
    vim.api.nvim_set_hl(0, "CmpItemKindFunction", { fg = "#c678dd", bg = bg })
    vim.api.nvim_set_hl(0, "CmpItemKindMethod", { fg = "#c678dd", bg = bg })
    vim.api.nvim_set_hl(0, "CmpItemKindVariable", { fg = "#e06c75", bg = bg })
    vim.api.nvim_set_hl(0, "CmpItemKindKeyword", { fg = "#56b6c2", bg = bg })

    -- Telescope with subtle borders
    vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = border_color, bg = bg })
    vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = border_color, bg = bg })
    vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { fg = border_color, bg = bg })
    vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { fg = border_color, bg = bg })

    local telescope_groups = {
      "TelescopeNormal",
      "TelescopePrompt",
      "TelescopeResults",
      "TelescopePreview",
      "TelescopePromptNormal",
      "TelescopePromptPrefix",
      "TelescopeSelection",
    }
    for _, group in ipairs(telescope_groups) do
      vim.api.nvim_set_hl(0, group, { bg = bg })
    end

    -- Mini.files with subtle borders
    vim.api.nvim_set_hl(0, "MiniFilesBorder", { fg = border_color, bg = bg })
    vim.api.nvim_set_hl(0, "MiniFilesNormal", { bg = bg })
    vim.api.nvim_set_hl(0, "MiniFilesTitle", { fg = "#787c99", bg = bg })

    -- Status line and winbar
    vim.api.nvim_set_hl(0, "StatusLine", { bg = bg })
    vim.api.nvim_set_hl(0, "StatusLineNC", { bg = bg })
    vim.api.nvim_set_hl(0, "WinBar", { bg = bg })
    vim.api.nvim_set_hl(0, "WinBarNC", { bg = bg })

    -- Buffer line with terminal background
    vim.api.nvim_set_hl(0, "BufferLineBackground", { bg = bg })
    vim.api.nvim_set_hl(0, "BufferLineBufferVisible", { bg = bg })
    vim.api.nvim_set_hl(0, "BufferLineBufferSelected", { bg = bg, bold = true })

    -- LSP Floating windows
    vim.api.nvim_set_hl(0, "LspInfoBorder", { fg = border_color, bg = bg })
    vim.api.nvim_set_hl(0, "DiagnosticFloatingError", { bg = bg })
    vim.api.nvim_set_hl(0, "DiagnosticFloatingWarn", { bg = bg })
    vim.api.nvim_set_hl(0, "DiagnosticFloatingInfo", { bg = bg })
    vim.api.nvim_set_hl(0, "DiagnosticFloatingHint", { bg = bg })

    -- Noice command line popup
    vim.api.nvim_set_hl(0, "NoiceCmdline", { bg = bg })
    vim.api.nvim_set_hl(0, "NoiceCmdlinePopup", { bg = bg })
    vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder", { fg = border_color, bg = bg })
    vim.api.nvim_set_hl(0, "NoiceCmdlinePopupTitle", { fg = "#787c99", bg = bg })
    vim.api.nvim_set_hl(0, "NoiceConfirm", { bg = bg })
    vim.api.nvim_set_hl(0, "NoiceConfirmBorder", { fg = border_color, bg = bg })
  end,
})

-- Configure border characters for floating windows
local border = {
  { "┌", "FloatBorder" },
  { "─", "FloatBorder" },
  { "┐", "FloatBorder" },
  { "│", "FloatBorder" },
  { "┘", "FloatBorder" },
  { "─", "FloatBorder" },
  { "└", "FloatBorder" },
  { "│", "FloatBorder" },
}

-- Set default border for LSP floating windows (Neovim 0.11+)
local _ofp = vim.lsp.util.open_floating_preview
vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or border
  return _ofp(contents, syntax, opts, ...)
end

-- Set border for diagnostic floating windows
vim.diagnostic.config({
  float = {
    border = border,
    style = "minimal",
  },
})

-- Configure command line options
vim.opt.cmdheight = 0 -- Hide command line when not in use
vim.opt.pumblend = 0 -- No transparency for popup menu
vim.opt.winblend = 0 -- No transparency for floating windows

-- Apply highlights immediately
vim.cmd("doautocmd ColorScheme")

-- Disable transparency
vim.g.transparent_enabled = false
