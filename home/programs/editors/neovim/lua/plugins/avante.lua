-- avante.nvim: Cursor-like AI sidebar for NeoVim
-- LazyVim extra handles base config; this file adds custom overrides
-- https://github.com/yetone/avante.nvim
return {
  "yetone/avante.nvim",
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
