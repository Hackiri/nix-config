return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown" }, -- Only load for markdown files
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  init = function()
    -- Define colors to match Tokyo Night theme
    local colors = {
      color18 = "#363b54", -- Base background
      color19 = "#515c7e", -- Selection color
      color20 = "#3d59a1", -- Search match color
      color21 = "#7aa2f7", -- Blue
      color22 = "#7dcfff", -- Cyan
      color23 = "#bb9af7", -- Magenta
      color10 = "#acb0d0", -- Bright white for better contrast
    }

    -- Define color variables
    local color1_bg = colors["color18"]
    local color2_bg = colors["color19"]
    local color3_bg = colors["color20"]
    local color4_bg = colors["color21"]
    local color5_bg = colors["color22"]
    local color6_bg = colors["color23"]
    local color_fg = colors["color10"]

    -- Use unique highlight groups for render-markdown
    vim.cmd(string.format([[highlight RenderMD1Bg guifg=%s guibg=%s]], color_fg, color1_bg))
    vim.cmd(string.format([[highlight RenderMD2Bg guifg=%s guibg=%s]], color_fg, color2_bg))
    vim.cmd(string.format([[highlight RenderMD3Bg guifg=%s guibg=%s]], color_fg, color3_bg))
    vim.cmd(string.format([[highlight RenderMD4Bg guifg=%s guibg=%s]], color_fg, color4_bg))
    vim.cmd(string.format([[highlight RenderMD5Bg guifg=%s guibg=%s]], color_fg, color5_bg))
    vim.cmd(string.format([[highlight RenderMD6Bg guifg=%s guibg=%s]], color_fg, color6_bg))

    vim.cmd(string.format([[highlight RenderMD1Fg cterm=bold gui=bold guifg=%s]], color1_bg))
    vim.cmd(string.format([[highlight RenderMD2Fg cterm=bold gui=bold guifg=%s]], color2_bg))
    vim.cmd(string.format([[highlight RenderMD3Fg cterm=bold gui=bold guifg=%s]], color3_bg))
    vim.cmd(string.format([[highlight RenderMD4Fg cterm=bold gui=bold guifg=%s]], color4_bg))
    vim.cmd(string.format([[highlight RenderMD5Fg cterm=bold gui=bold guifg=%s]], color5_bg))
    vim.cmd(string.format([[highlight RenderMD6Fg cterm=bold gui=bold guifg=%s]], color6_bg))
  end,
  config = function()
    -- Add keybindings for markdown rendering under <leader>r prefix
    vim.keymap.set("n", "<leader>rt", "<cmd>RenderToggle<CR>", { desc = "Toggle Markdown Rendering" })
    vim.keymap.set("n", "<leader>rr", "<cmd>RenderRefresh<CR>", { desc = "Refresh Markdown Rendering" })
    vim.keymap.set("n", "<leader>rc", "<cmd>RenderClose<CR>", { desc = "Close Markdown Rendering" })

    -- Add checkbox operations
    vim.keymap.set("n", "<leader>rx", function()
      local line = vim.fn.getline(".")
      if line:match("%[%s%]") then
        vim.cmd("s/\\[\\s\\]/[x]/e")
      elseif line:match("%[x%]") then
        vim.cmd("s/\\[x\\]/[ ]/e")
      end
      vim.cmd("nohl")
    end, { desc = "Toggle Checkbox" })
  end,
  opts = {
    bullet = {
      enabled = true,
    },
    checkbox = {
      enabled = true,
      position = "inline",
      unchecked = {
        icon = "   󰄱 ",
        highlight = "RenderMarkdownUnchecked",
        scope_highlight = nil,
      },
      checked = {
        icon = "   󰱒 ",
        highlight = "RenderMarkdownChecked",
        scope_highlight = nil,
      },
    },
    heading = {
      sign = false,
      icons = { "󰎤 ", "󰎧 ", "󰎪 ", "󰎭 ", "󰎱 ", "󰎳 " },
      backgrounds = {
        "RenderMD1Bg",
        "RenderMD2Bg",
        "RenderMD3Bg",
        "RenderMD4Bg",
        "RenderMD5Bg",
        "RenderMD6Bg",
      },
      foregrounds = {
        "RenderMD1Fg",
        "RenderMD2Fg",
        "RenderMD3Fg",
        "RenderMD4Fg",
        "RenderMD5Fg",
        "RenderMD6Fg",
      },
    },
    latex = {
      enabled = true,
    },
  },
}
