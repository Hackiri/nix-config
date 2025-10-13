-- Git blame and browse integration
return {
  "dinhhuy258/git.nvim",
  event = "BufReadPre",
  version = "*",
  opts = {
    keymaps = {
      -- Open blame window
      blame = "<Leader>gb",
      -- Open file/folder in git repository
      browse = "<Leader>go",
    },
  },
}
