-- Tinygit - Streamlined git operations with smart defaults
-- Enhanced git workflow plugin from v12 config
return {
  "chrisgrieser/nvim-tinygit",
  event = "VeryLazy",
  dependencies = {
    "stevearc/dressing.nvim", -- Optional: improves input UI
  },
  keys = {
    -- Core git operations (remapped to avoid conflicts)
    {
      "<leader>gcs",
      function()
        require("tinygit").smartCommit({ pushIfClean = false })
      end,
      desc = "Tinygit: Smart commit",
    },
    {
      "<leader>gcp",
      function()
        require("tinygit").smartCommit({ pushIfClean = true })
      end,
      desc = "Tinygit: Smart commit & push",
    },
    {
      "<leader>gpl",
      function()
        require("tinygit").push({ pullBefore = true })
      end,
      desc = "Tinygit: Pull & push",
    },
    {
      "<leader>gpr",
      function()
        require("tinygit").push({ createGitHubPr = true })
      end,
      desc = "Tinygit: Push & create PR",
    },

    -- Advanced commit operations
    {
      "<leader>gfx",
      function()
        require("tinygit").fixupCommit({ autoRebase = true })
      end,
      desc = "Tinygit: Fixup commit & rebase",
    },
    {
      "<leader>gm",
      function()
        require("tinygit").amendNoEdit({ forcePushIfDiverged = true })
      end,
      desc = "Git: Amend & force push",
    },
    {
      "<leader>gM",
      function()
        require("tinygit").amendOnlyMsg({ forcePushIfDiverged = true })
      end,
      desc = "Git: Amend message & force push",
    },

    -- GitHub integration
    {
      "<leader>gi",
      function()
        require("tinygit").issuesAndPrs({ state = "open" })
      end,
      desc = "Git: Open issues",
    },
    {
      "<leader>gI",
      function()
        require("tinygit").issuesAndPrs({ state = "closed" })
      end,
      desc = "Git: Closed issues",
    },
    {
      "gi",
      function()
        require("tinygit").openIssueUnderCursor()
      end,
      desc = "Git: Open issue under cursor",
    },

    -- File history (remapped to avoid conflict with gitsigns hunks)
    {
      "<leader>gH",
      function()
        require("tinygit").fileHistory()
      end,
      mode = { "n", "x" },
      desc = "Tinygit: File history",
    },

    -- GitHub URLs (remapped to avoid conflicts)
    {
      "<leader>gurl",
      function()
        require("tinygit").githubUrl("file")
      end,
      mode = { "n", "x" },
      desc = "Tinygit: GitHub URL (file)",
    },
    {
      "<leader>gurL",
      function()
        require("tinygit").githubUrl("repo")
      end,
      desc = "Tinygit: GitHub URL (repo)",
    },
    {
      "<leader>gbl",
      function()
        require("tinygit").githubUrl("blame")
      end,
      mode = { "n", "x" },
      desc = "Tinygit: GitHub blame URL",
    },

    -- Stash operations
    {
      "<leader>gst",
      function()
        require("tinygit").stashPush()
      end,
      desc = "Tinygit: Stash push",
    },
    {
      "<leader>gsT",
      function()
        require("tinygit").stashPop()
      end,
      desc = "Tinygit: Stash pop",
    },

    -- Undo operations (fixed duplicate mapping)
    {
      "<leader>guz",
      function()
        require("tinygit").undoLastCommitOrAmend()
      end,
      desc = "Tinygit: Undo last commit/amend",
    },
  },
  opts = {
    stage = {
      moveToNextHunkOnStagingToggle = true,
    },
    commit = {
      keepAbortedMsgSecs = 60 * 10, -- 10 minutes
      spellcheck = true,
      subject = {
        autoFormat = function(subject)
          -- Remove trailing dot (commitlint rule)
          subject = subject:gsub("%.$", "")

          -- Sentence case after commit type
          subject = subject
            :gsub("^(%w+: )(.)", function(c1, c2)
              return c1 .. c2:lower()
            end) -- no scope
            :gsub("^(%w+%b(): )(.)", function(c1, c2)
              return c1 .. c2:lower()
            end) -- with scope
          return subject
        end,
        enforceType = true, -- Enforce conventional commit types
      },
    },
    push = {
      openReferencedIssues = true, -- Open issues mentioned in commit after push
    },
    history = {
      autoUnshallowIfNeeded = true,
      diffPopup = { width = 0.9, height = 0.9 },
    },
    statusline = {
      blame = {
        hideAuthorNames = {}, -- Add your name here to hide from blame
        ignoreAuthors = { "🤖 automated", "dependabot" },
        maxMsgLen = 72,
      },
    },
  },
}
