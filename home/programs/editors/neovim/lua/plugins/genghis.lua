-- Genghis - Convenience file operations
-- File manipulation and navigation plugin from v12 config
return {
  "chrisgrieser/nvim-genghis",
  dependencies = {
    "stevearc/dressing.nvim", -- Optional: improves input UI
  },
  opts = {
    navigation = {
      onlySameExtAsCurrentFile = true, -- Navigate only between files with same extension
    },
  },
  keys = {
    -- Copy filepath operations (remapped to uppercase Y to avoid yazi/clipboard conflicts)
    {
      "<leader>Ya",
      function()
        require("genghis").copyFilepathWithTilde()
      end,
      desc = "Genghis: Yank absolute path (~)",
    },
    {
      "<leader>Yr",
      function()
        require("genghis").copyRelativePath()
      end,
      desc = "Genghis: Yank relative path",
    },
    {
      "<leader>Yn",
      function()
        require("genghis").copyFilename()
      end,
      desc = "Genghis: Yank filename",
    },
    {
      "<leader>Yp",
      function()
        require("genghis").copyDirectoryPath()
      end,
      desc = "Genghis: Yank directory path",
    },

    -- File navigation (navigate between files in same directory)
    {
      "<M-CR>",
      function()
        require("genghis").navigateToFileInFolder("next")
      end,
      desc = "Genghis: Next file in folder",
    },
    {
      "<S-M-CR>",
      function()
        require("genghis").navigateToFileInFolder("prev")
      end,
      desc = "Genghis: Previous file in folder",
    },

    -- File operations (remapped to uppercase F to avoid FZF conflicts)
    {
      "<leader>FR",
      function()
        require("genghis").renameFile()
      end,
      desc = "Genghis: Rename file",
    },
    {
      "<leader>FN",
      function()
        require("genghis").createNewFile()
      end,
      desc = "Genghis: New file",
    },
    {
      "<leader>FW",
      function()
        require("genghis").duplicateFile()
      end,
      desc = "Genghis: Duplicate file",
    },
    {
      "<leader>FM",
      function()
        require("genghis").moveToFolderInCwd()
      end,
      desc = "Genghis: Move to folder",
    },
    {
      "<leader>FD",
      function()
        require("genghis").trashFile()
      end,
      desc = "Genghis: Delete file (trash)",
    },
    {
      "<leader>FX",
      function()
        require("genghis").chmodx()
      end,
      desc = "Genghis: chmod +x",
    },

    -- Move selection to new file
    {
      "<leader>rx",
      function()
        require("genghis").moveSelectionToNewFile()
      end,
      mode = "x",
      desc = "Refactor: Move selection to new file",
    },

    -- System file explorer (macOS/Linux)
    {
      "<leader>Fe",
      function()
        require("genghis").showInSystemExplorer()
      end,
      desc = "File: Reveal in system explorer",
    },
  },
}
