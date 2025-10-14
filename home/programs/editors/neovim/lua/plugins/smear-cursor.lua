return {
  "sphamba/smear-cursor.nvim",
  enabled = vim.g.neovim_mode ~= "skitty", -- Disable plugin for skitty mode
  cond = vim.g.neovide == nil,
  opts = {
    stiffness = 0.8, -- 0.6      [0, 1]
    trailing_stiffness = 0.4, -- 0.4      [0, 1]
    stiffness_insert_mode = 0.6, -- 0.4      [0, 1]
    trailing_stiffness_insert_mode = 0.6, -- 0.4      [0, 1]
    distance_stop_animating = 0.5, -- 0.1      > 0
  },
  config = function(_, opts)
    require("smear_cursor").setup(opts)

    -- Disable smear cursor for TSX/JSX files to prevent lag
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "tsx", "jsx", "typescriptreact", "javascriptreact" },
      callback = function()
        require("smear_cursor").enabled = false
      end,
    })

    -- Re-enable for other filetypes
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "*",
      callback = function()
        local ft = vim.bo.filetype
        if ft ~= "tsx" and ft ~= "jsx" and ft ~= "typescriptreact" and ft ~= "javascriptreact" then
          require("smear_cursor").enabled = true
        end
      end,
    })
  end,
}
