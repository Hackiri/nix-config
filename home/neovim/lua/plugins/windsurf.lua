-- ~/.config/nvim/lua/plugins/windsurf.lua
return {
  "Hackiri/windsurf.vim",
  branch = "windsurf-nvim-features", -- Use our enhanced branch
  config = function()
    require("codeium").setup({
      -- Basic windsurf.nvim configuration
      enable_cmp_source = true,
      virtual_text = {
        enabled = true,
        manual = false,
      },
      
      -- Advanced features we added
      web_search = {
        provider = "tavily", -- or "google", "kagi", etc.
        -- Set API keys in environment variables
      },
      
      rag_service = {
        enabled = false, -- Enable if you want RAG features
        host_mount = os.getenv("HOME"),
        runner = "docker",
      },
      
      tools = {
        enabled = true,
        disabled_tools = {}, -- Disable specific tools if needed
      },
    })
  end,
  dependencies = {
    "nvim-lua/plenary.nvim", -- Required for HTTP requests
  },
}
