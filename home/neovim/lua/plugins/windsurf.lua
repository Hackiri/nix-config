return {
  {
    "Exafunction/windsurf.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "saghen/blink.cmp",
      "hrsh7th/nvim-cmp",
      "Exafunction/codeium.nvim",
    },
    event = "BufEnter",
    config = function()
      -- Define the language server path
      local cache_path = vim.fn.stdpath("cache")
      local ls_path = cache_path .. "/codeium/bin/language_server_macos_x64"

      -- Ensure directory exists
      local ls_dir = vim.fn.fnamemodify(ls_path, ":h")
      if vim.fn.isdirectory(ls_dir) == 0 then
        vim.fn.mkdir(ls_dir, "p")
      end

      -- Setup Codeium with error handling - only for completion
      local codeium_ok, codeium = pcall(require, "codeium")
      if codeium_ok then
        pcall(function()
          codeium.setup({
            enable_cmp_source = true, -- Enable as completion source
            enable_chat = false, -- Disable chat (using Avante for that)
            tools = { -- Disable tools (using Avante for that)
              enable = false,
            },
          })
        end)
      else
        vim.notify("Codeium plugin not found", vim.log.levels.WARN)
      end
      -- Register blink.cmp
      local ok, blink = pcall(require, "blink.cmp")
      if ok then
        blink.setup({
          sources = {
            {
              name = "codeium",
              priority = 50,
              group_index = 1,
            },
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
    end,
  },
}
