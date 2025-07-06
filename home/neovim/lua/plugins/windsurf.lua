return {
  {
    "Exafunction/windsurf.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "saghen/blink.cmp",
    },
    event = "BufEnter",
    config = function()
      -- Register blink.cmp
      local ok, blink = pcall(require, "blink.cmp")
      if ok then
        blink.setup({
          sources = {
            {
              name = "nvim_lsp",
              priority = 100,
              group_index = 1,
            },
            {
              name = "buffer",
              priority = 30,
              group_index = 2,
            },
            {
              name = "path",
              priority = 40,
              group_index = 2,
            },
          },
        })
      end

      -- Add commands
      -- Avante commands will be provided by the avante.nvim plugin
    end,
  },
}
