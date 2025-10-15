-- Neovim Lua colors configuration
-- Pure Lua implementation - no external shell script needed

local M = {}

-- Define your color palette directly in Lua
M.colors = {
  -- Lighter markdown headings (4 colors to the right)
  color18 = "#2d244b", -- Markdown heading 1 - color04
  color19 = "#10492d", -- Markdown heading 2 - color02
  color20 = "#013e4a", -- Markdown heading 3 - color03
  color21 = "#4b314c", -- Markdown heading 4 - color01
  color22 = "#1e2b00", -- Markdown heading 5 - color05
  color23 = "#2d1c08", -- Markdown heading 6 - color08
  color26 = "#0D1116", -- Markdown heading foreground (usually color10)

  -- Primary colors
  color04 = "#987afb",
  color02 = "#37f499",
  color03 = "#04d1f9",
  color01 = "#fca6ff",
  color05 = "#9ad900",
  color08 = "#e58f2a",
  color06 = "#05ff23",

  -- Background and UI colors
  color10 = "#0D1116", -- Terminal and neovim background
  color17 = "#141b22", -- Lualine across, 1 color to the right of background
  color07 = "#141b22", -- Markdown codeblock, 2 to the right of background
  color25 = "#232e3b", -- Background of inactive tmux pane, 3 to the right
  color13 = "#232e3b", -- Line across cursor, 5 to the right of background
  color15 = "#013e4a", -- Tmux inactive windows, 7 colors to the right

  -- Text and UI elements
  color09 = "#b7bfce", -- Comments
  color11 = "#f16c75", -- Underline spellbad
  color12 = "#f1fc79", -- Underline spellcap
  color14 = "#ffffff", -- Cursor and tmux windows text
}

-- Apply colors to Neovim highlight groups
function M.setup()
  if _G.vim then
    for name, hex in pairs(M.colors) do
      vim.api.nvim_set_hl(0, name, { fg = hex })
    end
  end
end

-- Auto-setup when module is loaded
M.setup()

-- Return the colors table for external usage (like wezterm)
return M.colors
