return {
  "stevearc/oil.nvim",
  -- enabled = false,
  keys = {
    { "-", "<CMD>Oil<CR>", desc = "Open parent directory" },
    {
      "<leader>-",
      function()
        require("oil").toggle_float()
      end,
      desc = "Open Oil in float",
    },
  },
  cmd = "Oil", -- Load when Oil command is called
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("oil").setup({
      default_file_explorer = true, -- start up nvim with oil instead of netrw
      columns = {},
      keymaps = {
        ["<C-h>"] = false,
        ["<C-c>"] = false, -- prevent from closing Oil as <C-c> is esc key
        ["<M-h>"] = "actions.select_split",
        ["q"] = "actions.close",
      },
      delete_to_trash = true,
      view_options = {
        show_hidden = true,
      },
      skip_confirm_for_simple_edits = true,
    })

    -- Keymaps are now defined in the keys spec above for lazy loading

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "oil", -- Adjust if Oil uses a specific file type identifier
      callback = function()
        vim.opt_local.cursorline = true
      end,
    })
  end,
}
