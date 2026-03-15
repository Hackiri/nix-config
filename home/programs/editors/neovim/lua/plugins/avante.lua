-- avante.nvim: Cursor-like AI sidebar for NeoVim
-- LazyVim extra handles base config; this file adds custom overrides
-- https://github.com/yetone/avante.nvim

-- Disable Avante when Copilot is not authenticated (no auth token files)
local function copilot_setup()
  local dir = vim.fn.expand("~/.config/github-copilot")
  return vim.fn.filereadable(dir .. "/hosts.json") == 1 or vim.fn.filereadable(dir .. "/apps.json") == 1
end

return {
  "yetone/avante.nvim",
  enabled = copilot_setup(),
  opts = {
    -- Use Copilot as provider (leverages existing subscription, no extra API key)
    provider = "copilot",
    -- Provider-specific config (new format per migration guide)
    providers = {
      copilot = {
        model = "claude-sonnet-4",
      },
    },
  },
}
