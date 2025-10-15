return {
  "folke/trouble.nvim",
  cmd = "Trouble",
  opts = {
    -- Auto-refresh on diagnostic changes
    auto_refresh = true,
    auto_close = false,
    auto_preview = true,

    -- Focus the window when opened
    focus = true,

    -- Follow the cursor in the source window
    follow = true,

    -- Restore the last filter state
    restore = true,

    -- Window options
    win = {
      type = "split",
      position = "bottom",
      size = { height = 0.3 },
    },

    -- Preview window options
    preview = {
      type = "main",
      scratch = true,
    },

    -- Icons and signs
    icons = {
      indent = {
        fold_open = "▾",
        fold_closed = "▸",
      },
      folder_closed = "",
      folder_open = "",
    },

    -- Define custom modes
    modes = {
      -- Diagnostics modes
      diagnostics = {
        mode = "diagnostics",
        preview = {
          type = "split",
          relative = "win",
          position = "right",
          size = 0.4,
        },
      },

      buffer_diagnostics = {
        mode = "diagnostics",
        filter = { buf = 0 },
        preview = {
          type = "split",
          relative = "win",
          position = "right",
          size = 0.4,
        },
      },

      -- LSP modes
      lsp = {
        mode = "lsp",
        win = { position = "right" },
      },

      lsp_references = {
        mode = "lsp_references",
        auto_refresh = false,
      },

      lsp_definitions = {
        mode = "lsp_definitions",
        auto_refresh = false,
      },

      lsp_implementations = {
        mode = "lsp_implementations",
        auto_refresh = false,
      },

      lsp_type_definitions = {
        mode = "lsp_type_definitions",
        auto_refresh = false,
      },

      lsp_document_symbols = {
        mode = "lsp_document_symbols",
        win = { position = "right", size = 0.3 },
      },

      lsp_workspace_symbols = {
        mode = "lsp_workspace_symbols",
        win = { position = "right", size = 0.3 },
      },

      lsp_incoming_calls = {
        mode = "lsp_incoming_calls",
      },

      lsp_outgoing_calls = {
        mode = "lsp_outgoing_calls",
      },

      -- Quickfix and location list
      quickfix = {
        mode = "quickfix",
      },

      loclist = {
        mode = "loclist",
      },

      -- Custom symbols mode with better organization
      symbols = {
        mode = "lsp_document_symbols",
        focus = false,
        win = {
          type = "split",
          position = "right",
          size = 0.25,
        },
        filter = {
          -- Filter out some symbol types if needed
          -- kind = { "Class", "Function", "Method" },
          any = {
            buf = 0,
            {
              kind = {
                "Class",
                "Constructor",
                "Enum",
                "Field",
                "Function",
                "Interface",
                "Method",
                "Module",
                "Namespace",
                "Package",
                "Property",
                "Struct",
                "Trait",
              },
            },
          },
        },
      },
    },

    -- Key mappings within Trouble window
    keys = {
      ["?"] = "help",
      ["q"] = "close",
      ["<esc>"] = "close",
      ["<cr>"] = "jump",
      ["<2-leftmouse>"] = "jump",
      ["o"] = "jump",
      ["<c-s>"] = "jump_split",
      ["<c-v>"] = "jump_vsplit",
      ["<c-t>"] = "jump_tab",
      ["{"] = "prev",
      ["}"] = "next",
      ["]]"] = "next",
      ["[["] = "prev",
      ["dd"] = "delete",
      ["d"] = { action = "delete", mode = "v" },
      ["i"] = "inspect",
      ["p"] = "preview",
      ["P"] = "toggle_preview",
      ["zo"] = "fold_open",
      ["zO"] = "fold_open_recursive",
      ["zc"] = "fold_close",
      ["zC"] = "fold_close_recursive",
      ["za"] = "fold_toggle",
      ["zA"] = "fold_toggle_recursive",
      ["zm"] = "fold_more",
      ["zM"] = "fold_close_all",
      ["zr"] = "fold_reduce",
      ["zR"] = "fold_open_all",
      ["zx"] = "fold_update",
      ["zX"] = "fold_update_all",
      ["zn"] = "fold_disable",
      ["zN"] = "fold_enable",
      ["zi"] = "fold_toggle_enable",
      ["gb"] = { action = "toggle_fold", mode = "n" },
      ["<space>"] = "fold_toggle",
      ["r"] = "refresh",
      ["R"] = "toggle_refresh",
      ["<tab>"] = "next",
      ["<s-tab>"] = "prev",
    },
  },
}
