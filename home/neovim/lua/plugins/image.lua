return {
  "3rd/image.nvim",
  event = "VeryLazy",
  opts = {
    integrations = {
      markdown = {
        enabled = true,
        clear_in_insert_mode = false,
        download_remote_images = true,
        only_render_image_at_cursor = false,
        filetypes = { "markdown", "vimwiki" }, -- Supported file types
      },
      neorg = {
        enabled = true,
        clear_in_insert_mode = false,
        download_remote_images = true,
        only_render_image_at_cursor = false,
        filetypes = { "norg" },
      },
    },
    max_width = nil,
    max_height = nil,
    max_width_window_percentage = nil,
    max_height_window_percentage = nil,
    window_overlap_clear_enabled = false, -- toggles images when windows are overlapped
    window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
    editor_only_render_when_focused = false, -- auto show/hide images when the editor gains/looses focus
    tmux_show_only_in_active_window = false, -- auto show/hide images in tmux window
    hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp" }, -- Patterns of files to hijack
  },
  config = function()
    -- Add keybindings for image operations under <leader>i prefix
    vim.keymap.set("n", "<leader>it", "<cmd>ImageToggle<cr>", { desc = "Toggle Image" })
    vim.keymap.set("n", "<leader>iT", "<cmd>ImageToggleAll<cr>", { desc = "Toggle All Images" })
    vim.keymap.set("n", "<leader>ir", "<cmd>ImageReload<cr>", { desc = "Reload Image" })
    vim.keymap.set("n", "<leader>iR", "<cmd>ImageReloadAll<cr>", { desc = "Reload All Images" })
    vim.keymap.set("n", "<leader>is", "<cmd>ImageSave<cr>", { desc = "Save Image" })
  end,
}
