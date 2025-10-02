return {
  "lukas-reineke/headlines.nvim",
  enabled = false, -- Disabled to avoid conflict with render-markdown.nvim
  dependencies = "nvim-treesitter/nvim-treesitter",
  -- Only load for specific filetypes (excludes markdown to avoid conflict with render-markdown.nvim)
  ft = { "norg", "rmd", "org" },
  config = function()
    require("headlines").setup({
      norg = {
        headline_highlights = {
          "Headline1",
          "Headline2",
          "Headline3",
          "Headline4",
          "Headline5",
          "Headline6",
        },
        codeblock_highlight = "CodeBlock",
        dash_highlight = "Dash",
        dash_string = "─",
        quote_highlight = "Quote",
        quote_string = "┃",
        bullets = {
          "•",
          "◦",
          "○",
        },
      },
      org = {
        headline_highlights = {
          "Headline1",
          "Headline2",
          "Headline3",
          "Headline4",
          "Headline5",
          "Headline6",
        },
        codeblock_highlight = "CodeBlock",
        dash_highlight = "Dash",
        dash_string = "─",
        quote_highlight = "Quote",
        quote_string = "┃",
      },
      rmd = {
        headline_highlights = {
          "Headline1",
          "Headline2",
          "Headline3",
          "Headline4",
          "Headline5",
          "Headline6",
        },
        codeblock_highlight = "CodeBlock",
        dash_highlight = "Dash",
        dash_string = "─",
        quote_highlight = "Quote",
        quote_string = "┃",
        bullets = {
          "•",
          "◦",
          "○",
        },
      },
    })
  end,
}
