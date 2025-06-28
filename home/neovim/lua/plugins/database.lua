return {
  --use nvim in browser
  { "kristijanhusak/vim-dadbod-ui" },
  { "kristijanhusak/vim-dadbod-completion" },
  -- Database
  {
    "tpope/vim-dadbod",
    -- lazy = true,
    dependencies = {
      "kristijanhusak/vim-dadbod-ui",
      "kristijanhusak/vim-dadbod-completion",
    },
    -- event = 'VeryLazy',
    config = function()
      vim.g.db_ui_execute_on_save = 0 --do not execute on save
      vim.g.db_ui_win_position = "left"
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_icons = {
        expanded = {
          db = "▼",
          buffers = "▼",
          saved_queries = "▼",
          schemas = "▼",
          schema = "▼",
          tables = "▼",
          table = "▼",
        },
        collapsed = {
          db = "▶",
          buffers = "▶",
          saved_queries = "▶",
          schemas = "▶",
          schema = "▶",
          tables = "▶",
          table = "▶",
        },
        saved_query = "*",
        new_query = "+",
        tables = "~",
        buffers = "»",
        add_connection = "[+]",
        connection_ok = "✓",
        connection_error = "✕",
      }
      -- Add keybindings for database operations under <leader>q prefix
      vim.keymap.set("n", "<leader>qt", "<cmd>DBUIToggle<CR>", { desc = "Toggle DB UI" })
      vim.keymap.set("n", "<leader>qf", "<cmd>DBUIFindBuffer<CR>", { desc = "Find DB Buffer" })
      vim.keymap.set("n", "<leader>qr", "<cmd>DBUIRenameBuffer<CR>", { desc = "Rename DB Buffer" })
      vim.keymap.set("n", "<leader>ql", "<cmd>DBUILastQueryInfo<CR>", { desc = "Last Query Info" })
      -- Add execution keybindings in SQL files
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "mysql", "plsql" },
        callback = function()
          vim.keymap.set("n", "<leader>qe", "<cmd>DBUIExecuteQuery<CR>", { buffer = true, desc = "Execute Query" })
          vim.keymap.set(
            "v",
            "<leader>qe",
            "<cmd>'<,'>DBUIExecuteQuery<CR>",
            { buffer = true, desc = "Execute Selected Query" }
          )
        end,
      })
    end,
  },
}

-- {'add_connection': '[+]', 'expanded': {'schemas': '▾', 'saved_queries': '▾', 'db': '▾', 'schema': '▾', 'table': '▾', 'buffers': '▾', 'tables': '▾'}, 'connection_ok': '✓', 'connection_error': '✕', 'tables': '~', '
-- collapsed': {'schemas': '▸', 'saved_queries': '▸', 'db': '▸', 'schema': '▸', 'table': '▸', 'buffers': '▸', 'tables': '▸'}, 'saved_query': '*', 'buffers': '»', 'new_query': '+'}
