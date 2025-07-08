return {
  -- add nightfox
  {
    "EdenEast/nightfox.nvim",
    lazy = false,
    -- Default options
    config = function()
      require("nightfox").setup({
        options = {
          styles = {
            comments = "italic",
            keywords = "bold",
            types = "italic,bold",
          },
          transparent = true,
          terminal_colors = true,
        },
        palettes = {
          -- Custom nightfox with black background
          nightfox = {
            bg1 = "#000000", -- Black background
            bg0 = "#1d1d2b", -- Alt backgrounds (floats, statusline, ...)
            bg3 = "#121820", -- 55% darkened from stock
            sel0 = "#131b24", -- 55% darkened from stock
          },
        },
        specs = {
          all = {
            inactive = "bg0", -- Default value for other styles
          },
          nightfox = {
            inactive = "#090909", -- Slightly lighter then black background
          },
        },
        groups = {
          all = {
            NormalNC = { fg = "fg1", bg = "inactive" }, -- Non-current windows
          },
        },
      })
    end,
  },
}
