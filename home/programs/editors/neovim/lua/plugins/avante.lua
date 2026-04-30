-- avante.nvim: Cursor-like AI sidebar for NeoVim
-- LazyVim extra handles base config; this file adds custom overrides
-- https://github.com/yetone/avante.nvim

-- Disable Avante when Copilot is not authenticated (no auth token files)
local function copilot_setup()
  local config_home = vim.env.XDG_CONFIG_HOME
  if not config_home or config_home == "" then
    config_home = vim.fn.expand("~/.config")
  end

  local dir = config_home .. "/github-copilot"
  return vim.fn.filereadable(dir .. "/hosts.json") == 1 or vim.fn.filereadable(dir .. "/apps.json") == 1
end

return {
  "yetone/avante.nvim",
  enabled = copilot_setup(),
  dependencies = {
    "zbirenbaum/copilot.lua",
  },
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
  config = function(_, opts)
    require("lazy").load({ plugins = { "copilot.lua" } })
    require("avante").setup(opts)
  end,
}
