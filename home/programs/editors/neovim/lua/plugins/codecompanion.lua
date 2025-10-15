-- CodeCompanion: AI coding assistant for Neovim
-- https://github.com/olimorris/codecompanion.nvim
return {
  "olimorris/codecompanion.nvim",
  event = "VeryLazy", -- Load after UI is rendered to improve startup time
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    -- Extensions
    "ravitemer/mcphub.nvim", -- MCP (Model Context Protocol) integration
    "MeanderingProgrammer/render-markdown.nvim", -- Markdown rendering in chat
    {
      "HakonHarnes/img-clip.nvim", -- Image clipboard support
      event = "VeryLazy",
      opts = {
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
        },
      },
    },
  },
  config = function()
    require("codecompanion").setup({
      -- Adapter configuration (customize based on your AI provider)
      adapters = {
        anthropic = function()
          return require("codecompanion.adapters").extend("anthropic", {
            env = {
              api_key = "ANTHROPIC_API_KEY",
            },
            schema = {
              model = {
                default = "claude-sonnet-4-20250514",
              },
            },
          })
        end,
        openai = function()
          return require("codecompanion.adapters").extend("openai", {
            env = {
              api_key = "OPENAI_API_KEY",
            },
          })
        end,
      },

      -- Display settings
      display = {
        action_palette = {
          width = 95,
          height = 10,
        },
        chat = {
          window = {
            layout = "vertical", -- vertical | horizontal | float | buffer
            border = "rounded",
            height = 0.8,
            width = 0.45,
            relative = "editor",
          },
          -- Show the model in the chat header
          show_settings = true,
          show_token_count = true,
        },
        diff = {
          enabled = true,
          provider = "mini_diff", -- default | mini_diff
        },
      },

      -- Inline code assistance
      inline = {
        adapter = "anthropic",
      },

      -- Chat settings
      chat = {
        adapter = "anthropic",
      },

      -- Prompt library
      prompt_library = {
        ["Custom Prompt"] = {
          strategy = "chat",
          description = "Custom prompt template",
          prompts = {
            {
              role = "system",
              content = "You are a helpful coding assistant.",
            },
          },
        },
      },

      -- Strategies
      strategies = {
        chat = {
          adapter = "anthropic",
          roles = {
            llm = "CodeCompanion",
            user = "Me",
          },
          variables = {
            ["buffer"] = {
              callback = "strategies.chat.variables.buffer",
              description = "Share the current buffer with the LLM",
            },
            ["viewport"] = {
              callback = "strategies.chat.variables.viewport",
              description = "Share the current viewport with the LLM",
            },
          },
          slash_commands = {
            ["buffer"] = {
              callback = "strategies.chat.slash_commands.buffer",
              description = "Insert open buffers",
              opts = {
                contains_code = true,
                provider = "fzf_lua",
              },
            },
            ["file"] = {
              callback = "strategies.chat.slash_commands.file",
              description = "Insert a file",
              opts = {
                contains_code = true,
                max_lines = 1000,
                provider = "fzf_lua",
              },
            },
            ["symbols"] = {
              callback = "strategies.chat.slash_commands.symbols",
              description = "Insert symbols from a selected file",
              opts = {
                contains_code = true,
                provider = "fzf_lua",
              },
            },
          },
        },
        inline = {
          adapter = "anthropic",
        },
        agent = {
          adapter = "anthropic",
        },
      },

      -- Logging
      opts = {
        log_level = "ERROR", -- TRACE | DEBUG | ERROR | INFO
      },

      -- Keybindings within CodeCompanion buffers
      keymaps = {
        ["<C-s>"] = "keymaps.save",
        ["<C-c>"] = "keymaps.close",
        ["q"] = "keymaps.cancel_request",
      },
    })

    -- Global keymaps for CodeCompanion
    vim.keymap.set("n", "<leader>cc", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Toggle CodeCompanion Chat" })
    vim.keymap.set("v", "<leader>cc", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Toggle CodeCompanion Chat" })
    vim.keymap.set("n", "<leader>ca", "<cmd>CodeCompanionActions<cr>", { desc = "CodeCompanion Actions" })
    vim.keymap.set("v", "<leader>ca", "<cmd>CodeCompanionActions<cr>", { desc = "CodeCompanion Actions" })
    vim.keymap.set("n", "<leader>ci", "<cmd>CodeCompanion<cr>", { desc = "CodeCompanion Inline" })
    vim.keymap.set("v", "<leader>ci", "<cmd>CodeCompanion<cr>", { desc = "CodeCompanion Inline" })
    vim.keymap.set("n", "<leader>cq", "<cmd>CodeCompanionChat Add<cr>", { desc = "Add to CodeCompanion Chat" })

    -- Advanced keymaps
    vim.keymap.set("n", "<leader>cp", "<cmd>CodeCompanionChat<cr>", { desc = "Prompt CodeCompanion" })
    vim.keymap.set("n", "<leader>cm", function()
      local input = vim.fn.input("Quick Chat: ")
      if input ~= "" then
        require("codecompanion").prompt(input)
      end
    end, { desc = "Quick CodeCompanion Message" })

    -- Inline assistant keymaps
    vim.keymap.set({ "n", "v" }, "<leader>ce", function()
      require("codecompanion").inline()
    end, { desc = "Inline Code Edit" })

    vim.keymap.set({ "n", "v" }, "<leader>cx", function()
      require("codecompanion").inline({
        prompt = "Explain this code",
      })
    end, { desc = "Explain Code" })

    vim.keymap.set({ "n", "v" }, "<leader>cf", function()
      require("codecompanion").inline({
        prompt = "Fix this code",
      })
    end, { desc = "Fix Code" })

    vim.keymap.set({ "n", "v" }, "<leader>ct", function()
      require("codecompanion").inline({
        prompt = "Write tests for this code",
      })
    end, { desc = "Generate Tests" })

    vim.keymap.set({ "n", "v" }, "<leader>cd", function()
      require("codecompanion").inline({
        prompt = "Add documentation for this code",
      })
    end, { desc = "Add Documentation" })

    vim.keymap.set({ "n", "v" }, "<leader>cr", function()
      require("codecompanion").inline({
        prompt = "Refactor this code",
      })
    end, { desc = "Refactor Code" })
  end,
}
