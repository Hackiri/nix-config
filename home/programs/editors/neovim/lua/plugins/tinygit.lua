-- Tinygit - Streamlined git operations with smart defaults
-- Enhanced git workflow plugin from v12 config
return {
  "chrisgrieser/nvim-tinygit",
  event = "VeryLazy",
  dependencies = {
    "stevearc/dressing.nvim", -- Optional: improves input UI
  },
  keys = {
    -- Core git operations
    {
      "<leader>gc",
      function()
        require("tinygit").smartCommit({ pushIfClean = false })
      end,
      desc = "Git: Smart commit",
    },
    {
      "<leader>gC",
      function()
        require("tinygit").smartCommit({ pushIfClean = true })
      end,
      desc = "Git: Smart commit & push",
    },
    {
      "<leader>gp",
      function()
        require("tinygit").push({ pullBefore = true })
      end,
      desc = "Git: Pull & push",
    },
    {
      "<leader>gP",
      function()
        require("tinygit").push({ createGitHubPr = true })
      end,
      desc = "Git: Push & create PR",
    },

    -- Advanced commit operations
    {
      "<leader>gf",
      function()
        require("tinygit").fixupCommit({ autoRebase = true })
      end,
      desc = "Git: Fixup commit & rebase",
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

    -- File history
    {
      "<leader>gh",
      function()
        require("tinygit").fileHistory()
      end,
      mode = { "n", "x" },
      desc = "Git: File history",
    },

    -- GitHub URLs
    {
      "<leader>gu",
      function()
        require("tinygit").githubUrl("file")
      end,
      mode = { "n", "x" },
      desc = "Git: GitHub URL (file)",
    },
    {
      "<leader>gU",
      function()
        require("tinygit").githubUrl("repo")
      end,
      desc = "Git: GitHub URL (repo)",
    },
    {
      "<leader>gb",
      function()
        require("tinygit").githubUrl("blame")
      end,
      mode = { "n", "x" },
      desc = "Git: GitHub blame URL",
    },

    -- Stash operations
    {
      "<leader>gt",
      function()
        require("tinygit").stashPush()
      end,
      desc = "Git: Stash push",
    },
    {
      "<leader>gT",
      function()
        require("tinygit").stashPop()
      end,
      desc = "Git: Stash pop",
    },

    -- Undo operations
    {
      "<leader>gu",
      function()
        require("tinygit").undoLastCommitOrAmend()
      end,
      desc = "Git: Undo last commit/amend",
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
