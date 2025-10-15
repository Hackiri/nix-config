-- Adds git related signs to the gutter, as well as utilities for managing changes
return {
  "lewis6991/gitsigns.nvim",
  version = "*",
  event = { "BufReadPre", "BufNewFile" }, -- Load when reading files
  opts = {
    -- See `:help gitsigns.txt`
    signs = {
      add = { text = "+" },
      change = { text = "~" },
      delete = { text = "_" },
      topdelete = { text = "‾" },
      changedelete = { text = "~" },
    },
    signs_staged = {
      add = { text = "+" },
      change = { text = "~" },
      delete = { text = "_" },
      topdelete = { text = "‾" },
      changedelete = { text = "~" },
    },
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns

      local function map(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
      end

      -- Navigation
      map("n", "]h", function()
        if vim.wo.diff then
          return "]h"
        end
        vim.schedule(function()
          gs.next_hunk()
        end)
        return "<Ignore>"
      end, { expr = true, desc = "Next Hunk" })

      map("n", "[h", function()
        if vim.wo.diff then
          return "[h"
        end
        vim.schedule(function()
          gs.prev_hunk()
        end)
        return "<Ignore>"
      end, { expr = true, desc = "Prev Hunk" })

      -- Git Hunk Actions (<leader>gh prefix)
      map("n", "<leader>ghs", gs.stage_hunk, { desc = "Stage Hunk" })
      map("n", "<leader>ghr", gs.reset_hunk, { desc = "Reset Hunk" })
      map("v", "<leader>ghs", function()
        gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, { desc = "Stage Hunk" })
      map("v", "<leader>ghr", function()
        gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, { desc = "Reset Hunk" })
      map("n", "<leader>ghS", gs.stage_buffer, { desc = "Stage Buffer" })
      map("n", "<leader>ghu", gs.undo_stage_hunk, { desc = "Undo Stage Hunk" })
      map("n", "<leader>ghR", gs.reset_buffer, { desc = "Reset Buffer" })
      map("n", "<leader>ghp", gs.preview_hunk, { desc = "Preview Hunk" })
      map("n", "<leader>ghb", function()
        gs.blame_line({ full = true })
      end, { desc = "Blame Line" })
      map("n", "<leader>ghd", gs.diffthis, { desc = "Diff This" })
      map("n", "<leader>ghD", function()
        gs.diffthis("~")
      end, { desc = "Diff This ~" })

      -- Additional git operations
      map("n", "<leader>gb", gs.toggle_current_line_blame, { desc = "Toggle git blame" })
      map("n", "<leader>gd", gs.diffthis, { desc = "Git diff" })
      map("n", "<leader>gp", gs.preview_hunk, { desc = "Preview git hunk" })
    end,
  },
}
