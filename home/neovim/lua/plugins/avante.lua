-- Avante.nvim configuration
return {
  "yetone/avante.nvim",
  build = function()
    -- conditionally use the correct build system for the current OS
    if vim.fn.has("win32") == 1 then
      return "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
    else
      return "make"
    end
  end,
  event = "VeryLazy",
  version = false, -- Never set this value to "*"! Never!
  ---@module 'avante'
  ---@type avante.Config
  opts = {
    -- add any opts here
    -- for example
    provider = "claude",
    -- provider = 'openai',
    providers = {
      claude = {
        -- openai = {
        endpoint = "https://api.anthropic.com",
        model = "claude-sonnet-4-20250514",
        api_key_name = "ANTHROPIC_API_KEY", -- Use environment variable instead of hardcoded key
        -- model = 'o3-mini',
        -- api_key_name = 'OPENAI_API_KEY',
        timeout = 30000, -- Timeout in milliseconds
        extra_request_body = {
          temperature = 0.75,
          max_tokens = 20480,
        },
      },
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below dependencies are optional,
    "echasnovski/mini.pick", -- for file_selector provider mini.pick
    "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
    "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
    "ibhagwan/fzf-lua", -- for file_selector provider fzf
    "stevearc/dressing.nvim", -- for input provider dressing
    "folke/snacks.nvim", -- for input provider snacks
    "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
    "zbirenbaum/copilot.lua", -- for providers='copilot'
    {
      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
  config = function()
    -- Use pcall to safely require mcphub
    local mcphub_ok, mcphub_module = pcall(require, "mcphub")

    require("avante").setup({
      -- system_prompt as function ensures LLM always has latest MCP server state
      -- This is evaluated for every message, even in existing chats
      system_prompt = function()
        if mcphub_ok then
          local hub = mcphub_module.get_hub_instance()
          return hub and hub:get_active_servers_prompt() or ""
        end
        return ""
      end,
      -- Using function prevents requiring mcphub before it's loaded
      custom_tools = function()
        if mcphub_ok then
          return {
            require("mcphub.extensions.avante").mcp_tool(),
          }
        end
        return {}
      end,
      -- Ensure Avante doesn't interfere with Codeium completion
      completion = {
        auto_trigger = false, -- Don't auto-trigger Avante completion
      },
    })
  end,
}
