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
    -- Copy filepath operations
    {
      "<leader>ya",
      function()
        require("genghis").copyFilepathWithTilde()
      end,
      desc = "Yank: Absolute path (with ~)",
    },
    {
      "<leader>yr",
      function()
        require("genghis").copyRelativePath()
      end,
      desc = "Yank: Relative path",
    },
    {
      "<leader>yn",
      function()
        require("genghis").copyFilename()
      end,
      desc = "Yank: Filename",
    },
    {
      "<leader>yp",
      function()
        require("genghis").copyDirectoryPath()
      end,
      desc = "Yank: Directory path",
    },

    -- File navigation (navigate between files in same directory)
    {
      "<M-CR>",
      function()
        require("genghis").navigateToFileInFolder("next")
      end,
      desc = "File: Next file in folder",
    },
    {
      "<S-M-CR>",
      function()
        require("genghis").navigateToFileInFolder("prev")
      end,
      desc = "File: Previous file in folder",
    },

    -- File operations
    {
      "<leader>fr",
      function()
        require("genghis").renameFile()
      end,
      desc = "File: Rename",
    },
    {
      "<leader>fn",
      function()
        require("genghis").createNewFile()
      end,
      desc = "File: New file",
    },
    {
      "<leader>fw",
      function()
        require("genghis").duplicateFile()
      end,
      desc = "File: Duplicate",
    },
    {
      "<leader>fm",
      function()
        require("genghis").moveToFolderInCwd()
      end,
      desc = "File: Move to folder",
    },
    {
      "<leader>fd",
      function()
        require("genghis").trashFile()
      end,
      desc = "File: Delete (trash)",
    },
    {
      "<leader>fx",
      function()
        require("genghis").chmodx()
      end,
      desc = "File: chmod +x",
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
      "<leader>fF",
      function()
        require("genghis").showInSystemExplorer()
      end,
      desc = "File: Reveal in system explorer",
    },
  },
}
