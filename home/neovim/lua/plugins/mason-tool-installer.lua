-- Mason tool installer configuration
return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  dependencies = {
    "williamboman/mason.nvim",
  },
  cmd = { "MasonToolsInstall", "MasonToolsUpdate" },
  opts = {
    -- Automatically install / update on startup
    auto_update = true,
    -- Run installations in parallel
    run_on_start = true,
    -- Start a log of the installation
    start_delay = 3000, -- 3 second delay
    -- Set a custom log level
    log_level = vim.log.levels.INFO,
    -- Default tools to install
    -- Note: Most tools are now specified in the lsp.lua file
    -- Only include tools NOT managed by Nix
    ensure_installed = {
      -- Formatters
      "stylua", -- Lua formatter
      "prettier", -- JavaScript/TypeScript/CSS/HTML/JSON/YAML formatter
      -- Don't include nixpkgs-fmt as it's managed by Nix

      -- Linters
      "luacheck", -- Lua linter
      -- Don't include shellcheck as it's likely managed by Nix

      -- Command line tools
      "ripgrep", -- Fast search tool (needed for dictionary completion)
    },
  },
  -- Keymaps
  keys = {
    { "<leader>cmt", "<cmd>MasonToolsInstall<cr>", desc = "Mason Tools Install" },
    { "<leader>cmu", "<cmd>MasonToolsUpdate<cr>", desc = "Mason Tools Update" },
  },
}
