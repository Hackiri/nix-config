local trigger_text = ";"

return {
  "saghen/blink.cmp",
  enabled = true,
  event = { "InsertEnter", "CmdlineEnter" }, -- Load only when entering insert or command mode
  version = "1.*",
  dependencies = {
    "moyiz/blink-emoji.nvim",
    "Kaiser-Yang/blink-cmp-dictionary",
    "olimorris/codecompanion.nvim", -- CodeCompanion AI suggestions
    {
      "saghen/blink.compat",
      version = "2.*", -- Use v2.* for blink.cmp v1.*
      lazy = true,
      opts = {},
    },
  },
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = function(_, opts)
    -- Merge custom sources with the existing ones from lazyvim
    opts.sources = vim.tbl_deep_extend("force", opts.sources or {}, {
      default = { "lsp", "path", "snippets", "buffer", "dadbod", "emoji", "dictionary", "codeium", "codecompanion" },
      providers = {
        lsp = {
          name = "lsp",
          enabled = true,
          module = "blink.cmp.sources.lsp",
          kind = "LSP",
          -- When linking markdown notes, I would get snippets and text in the
          -- suggestions, I want those to show only if there are no LSP
          -- suggestions
          -- Disabling fallbacks as my snippets wouldn't show up
          -- Enabled fallbacks as this seems to be working now
          fallbacks = { "snippets", "buffer" },
          score_offset = 90, -- the higher the number, the higher the priority
        },
        path = {
          name = "Path",
          module = "blink.cmp.sources.path",
          score_offset = 25,
          -- When typing a path, I would get snippets and text in the
          -- suggestions, I want those to show only if there are no path
          -- suggestions
          fallbacks = { "snippets", "buffer" },
          opts = {
            trailing_slash = false,
            label_trailing_slash = true,
            get_cwd = function(context)
              return vim.fn.expand(("#%d:p:h"):format(context.bufnr))
            end,
            show_hidden_files_by_default = true,
          },
        },
        buffer = {
          name = "Buffer",
          enabled = true,
          max_items = 3,
          module = "blink.cmp.sources.buffer",
          min_keyword_length = 4,
          score_offset = 15, -- the higher the number, the higher the priority
        },
        snippets = {
          name = "snippets",
          enabled = true,
          max_items = 8,
          min_keyword_length = 2,
          module = "blink.cmp.sources.snippets",
          score_offset = 85, -- the higher the number, the higher the priority
          -- Only show snippets if I type the trigger_text characters, so
          -- to expand the "bash" snippet, if the trigger_text is ";" I have to
          -- type ";bash"
          should_show_items = function()
            local col = vim.api.nvim_win_get_cursor(0)[2]
            local before_cursor = vim.api.nvim_get_current_line():sub(1, col)
            -- NOTE: remember that `trigger_text` is modified at the top of the file
            return before_cursor:match(trigger_text .. "%w*$") ~= nil
          end,
          -- After accepting the completion, delete the trigger_text characters
          -- from the final inserted text
          -- Modified transform_items function based on suggestion by `synic` so
          -- that the luasnip source is not reloaded after each transformation
          -- https://github.com/linkarzu/dotfiles-latest/discussions/7#discussion-7849902
          transform_items = function(_, items)
            local line = vim.api.nvim_get_current_line()
            local col = vim.api.nvim_win_get_cursor(0)[2]
            local before_cursor = line:sub(1, col)
            local start_pos, end_pos = before_cursor:find(trigger_text .. "[^" .. trigger_text .. "]*$")
            if start_pos then
              for _, item in ipairs(items) do
                if not item.trigger_text_modified then
                  ---@diagnostic disable-next-line: inject-field
                  item.trigger_text_modified = true
                  item.textEdit = {
                    newText = item.insertText or item.label,
                    range = {
                      start = { line = vim.fn.line(".") - 1, character = start_pos - 1 },
                      ["end"] = { line = vim.fn.line(".") - 1, character = end_pos },
                    },
                  }
                end
              end
            end
            return items
          end,
        },
        -- Example on how to configure dadbod found in the main repo
        -- https://github.com/kristijanhusak/vim-dadbod-completion
        dadbod = {
          name = "Dadbod",
          module = "vim_dadbod_completion.blink",
          score_offset = 85, -- the higher the number, the higher the priority
        },
        -- https://github.com/moyiz/blink-emoji.nvim
        emoji = {
          module = "blink-emoji",
          name = "Emoji",
          score_offset = 15, -- the higher the number, the higher the priority
          opts = { insert = true }, -- Insert emoji (default) or complete its name
        },
        -- Dictionary completion using ripgrep - official approach
        -- https://github.com/Kaiser-Yang/blink-cmp-dictionary
        dictionary = {
          module = "blink-cmp-dictionary",
          name = "Dict",
          score_offset = 20, -- the higher the number, the higher the priority
          enabled = true,
          max_items = 8,
          min_keyword_length = 3,
          opts = {
            -- Use Neovim's config directory for portable paths
            -- These files are symlinked via xdg.configFile in default.nix
            dictionary_files = vim.fn.stdpath("config") .. "/spell/en.utf-8.add",
            dictionary_directories = { vim.fn.stdpath("config") .. "/dictionaries" },

            -- Use ripgrep for searching words - will be found in PATH
            get_command = function()
              -- First check if rg is in PATH, then fall back to system path
              if vim.fn.executable("rg") == 1 then
                return "rg"
              else
                return "/run/current-system/sw/bin/rg"
              end
            end,

            get_command_args = function(prefix)
              -- Use the dictionary file in Neovim's config directory
              local dict_path = vim.fn.stdpath("config") .. "/dictionaries/words.txt"

              return {
                "--color=never",
                "--no-line-number",
                "--no-messages",
                "--no-filename",
                "--ignore-case",
                "--max-count=100",
                "--",
                "^" .. prefix, -- Match words starting with prefix
                dict_path,
              }
            end,

            -- Handle capitalization properly
            capitalize_first = function(context, match)
              local prefix = context.line:sub(1, context.cursor[2]):match("([%w_]*)$") or ""
              return string.match(prefix, "^%u") ~= nil and match.label:match("^%l*$") ~= nil
            end,

            documentation = {
              enable = true, -- enable documentation to show the definition of the word
              get_command = {
                -- For the word definitions feature
                -- make sure "wn" is available in your system
                -- brew install wordnet
                "wn",
                "${word}", -- this will be replaced by the word to search
                "-over",
              },
            },

            -- Use the default prefix extraction
            get_prefix = function(context)
              return context.line:sub(1, context.cursor[2]):match("([%w_]*)$") or ""
            end,

            -- Handle errors gracefully
            on_error = function(return_value, standard_error)
              if standard_error and standard_error ~= "" then
                vim.schedule(function()
                  vim.notify("Dictionary completion error: " .. standard_error, vim.log.levels.ERROR)
                end)
                return true
              end
              return false
            end,
          },
        },
        codeium = {
          name = "Codeium",
          module = "blink.compat.source",
          score_offset = 100, -- High priority for AI suggestions
          async = true,
          opts = {
            -- This will be passed to the codeium nvim-cmp source
          },
        },
        codecompanion = {
          name = "CodeCompanion",
          module = "codecompanion.providers.completion.blink",
          enabled = true,
          async = true,
          score_offset = 95, -- High priority, slightly below codeium
        },
      },
    })

    opts.cmdline = {
      -- command line completion, thanks to dpetka2001 in reddit
      -- https://www.reddit.com/r/neovim/comments/1hjjf21/comment/m37fe4d/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
      sources = function()
        local type = vim.fn.getcmdtype()
        if type == "/" or type == "?" then
          return { "buffer" }
        end
        if type == ":" then
          return { "cmdline" }
        end
        return {}
      end,
    }

    opts.completion = {
      --   keyword = {
      --     -- 'prefix' will fuzzy match on the text before the cursor
      --     -- 'full' will fuzzy match on the text before *and* after the cursor
      --     -- example: 'foo_|_bar' will match 'foo_' for 'prefix' and 'foo__bar' for 'full'
      --     range = "full",
      --   },
      menu = {
        border = "rounded",
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 500,
        window = {
          border = "rounded",
        },
      },
      -- Displays a preview of the selected item on the current line
      ghost_text = {
        enabled = true,
      },
    }

    -- Merge snippets configuration with existing options
    opts.snippets = vim.tbl_deep_extend("force", opts.snippets or {}, {
      preset = "luasnip",
      expand = function(snippet)
        require("luasnip").lsp_expand(snippet)
      end,
      active = function(filter)
        if filter and filter.direction then
          return require("luasnip").jumpable(filter.direction)
        end
        return require("luasnip").in_snippet()
      end,
      jump = function(direction)
        require("luasnip").jump(direction)
      end,
    })

    -- The default preset used by lazyvim accepts completions with enter
    -- I don't like using enter because if on markdown and typing
    -- something, but you want to go to the line below, if you press enter,
    -- the completion will be accepted
    -- https://cmp.saghen.dev/configuration/keymap.html#default
    opts.keymap = {
      -- 'default' (recommended) for mappings similar to built-in completions
      --   <c-y> to accept ([y]es) the completion.
      --    This will auto-import if your LSP supports it.
      --    This will expand snippets if the LSP sent a snippet.
      preset = "default",

      -- Custom keymaps that preserve your existing settings
      ["<Tab>"] = { "snippet_forward", "fallback" },
      ["<S-Tab>"] = { "snippet_backward", "fallback" },

      ["<Up>"] = { "select_prev", "fallback" },
      ["<Down>"] = { "select_next", "fallback" },
      ["<C-p>"] = { "select_prev", "fallback" },
      ["<C-n>"] = { "select_next", "fallback" },

      ["<C-b>"] = { "scroll_documentation_up", "fallback" },
      ["<C-f>"] = { "scroll_documentation_down", "fallback" },

      ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-e>"] = { "hide", "fallback" },
    }

    -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
    -- which automatically downloads a prebuilt binary when enabled.
    -- By default, we use the Lua implementation instead, but you may enable
    -- the rust implementation via `'prefer_rust_with_warning'`
    opts.fuzzy = { implementation = "prefer_rust_with_warning" }

    -- Shows a signature help window while you type arguments for a function
    opts.signature = { enabled = true }

    return opts
  end,
}
