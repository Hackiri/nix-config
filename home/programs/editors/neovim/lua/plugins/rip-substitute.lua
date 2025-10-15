-- Rip-substitute - Modern search and replace with live preview
-- Enhanced search/replace from v12 config
return {
  "chrisgrieser/nvim-rip-substitute",
  keys = {
    {
      "<leader>rs",
      function()
        require("rip-substitute").sub()
      end,
      mode = { "n", "x" },
      desc = "Search: Replace (rip-substitute)",
    },
  },
  opts = {
    popupWin = {
      hideSearchReplaceLabels = true, -- Cleaner UI
      hideKeymapHints = true, -- Cleaner UI
    },
    keymaps = {
      insertModeConfirm = "<CR>", -- Confirm with Enter in insert mode
    },
    editingBehavior = {
      autoCaptureGroups = true, -- Automatically capture regex groups
    },
    debug = false,
  },
}
