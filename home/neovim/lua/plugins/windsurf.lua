return {
  {
    "Exafunction/windsurf.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "saghen/blink.cmp",
    },
    event = "BufEnter",
    config = function()
      -- Define the language server path
      local cache_path = vim.fn.stdpath("cache")
      local ls_path = cache_path .. "/codeium/bin/1.20.9/language_server_macos_x64"

      -- Ensure directory exists
      local ls_dir = vim.fn.fnamemodify(ls_path, ":h")
      if vim.fn.isdirectory(ls_dir) == 0 then
        vim.fn.mkdir(ls_dir, "p")
      end

      require("codeium").setup({
        enable_cmp_source = false,
        enable_chat = true,
        language_server = {
          binary_path = ls_path,
          download_timeout = 300,
          start_timeout = 300,
        },
        tools = {
          language_server = ls_path,
        },
      })

      -- Ensure the binary is executable after download
      vim.defer_fn(function()
        if vim.fn.filereadable(ls_path) == 1 then
          vim.fn.system({ "chmod", "+x", ls_path })
        end
      end, 2000)

      -- Register codeium with blink.cmp
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

      -- Add commands
      vim.api.nvim_create_user_command("CodeiumReload", function()
        require("codeium").reload()
      end, {})

      vim.api.nvim_create_user_command("CodeiumToggle", function()
        vim.g.codeium_enabled = not vim.g.codeium_enabled
        print("Codeium " .. (vim.g.codeium_enabled and "enabled" or "disabled"))
      end, {})
    end,
  },
}
