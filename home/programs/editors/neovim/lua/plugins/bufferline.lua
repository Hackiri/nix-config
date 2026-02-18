return {
  "akinsho/bufferline.nvim",
  version = "*",
  event = "VeryLazy", -- Load after initial UI is rendered
  dependencies = {
    "moll/vim-bbye",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    -- Icons
    local icons = {
      buffer = {
        close = "✗",
        modified = "●",
        locked = "",
        pinned = "󰐃",
        duplicate = "󰈢",
        separator = "│",
        pick = "󰛖",
      },
      diagnostics = {
        error = " ",
        warning = " ",
        info = " ",
        hint = " ",
      },
      git = {
        added = " ",
        modified = " ",
        removed = " ",
      },
      filetype = {
        default = "",
        terminal = "",
      },
    }

    -- Colors from Tokyo Night theme
    local colors = {
      bg = "#0a0a0d", -- Terminal background
      fg = "#787c99", -- Terminal foreground
      selected = "#7aa2f7", -- Blue
      visible = "#363b54", -- Bright black
      filled = "#1a1b26", -- Slightly lighter than bg
      error = "#f7768e", -- Red
      warning = "#e0af68", -- Yellow
      info = "#7aa2f7", -- Blue
      hint = "#7dcfff", -- Cyan
      modified = "#e0af68", -- Yellow
      added = "#41a6b5", -- Green
      removed = "#f7768e", -- Red
    }

    require("bufferline").setup({
      highlights = {
        -- Regular buffer
        background = {
          fg = colors.fg,
          bg = colors.bg,
        },
        buffer_visible = {
          fg = colors.fg,
          bg = colors.visible,
        },
        buffer_selected = {
          fg = colors.selected,
          bg = colors.filled,
          bold = true,
          italic = true,
        },

        -- Close button
        close_button = {
          fg = colors.fg,
          bg = colors.bg,
        },
        close_button_visible = {
          fg = colors.fg,
          bg = colors.visible,
        },
        close_button_selected = {
          fg = colors.selected,
          bg = colors.filled,
        },

        -- Modified
        modified = {
          fg = colors.modified,
          bg = colors.bg,
        },
        modified_visible = {
          fg = colors.modified,
          bg = colors.visible,
        },
        modified_selected = {
          fg = colors.modified,
          bg = colors.filled,
        },

        -- Separators
        separator = {
          fg = colors.bg,
          bg = colors.bg,
        },
        separator_visible = {
          fg = colors.visible,
          bg = colors.visible,
        },
        separator_selected = {
          fg = colors.filled,
          bg = colors.filled,
        },

        -- Indicators
        indicator_selected = {
          fg = colors.selected,
          bg = colors.filled,
        },

        -- Diagnostics
        error = {
          fg = colors.error,
          bg = colors.bg,
        },
        error_visible = {
          fg = colors.error,
          bg = colors.visible,
        },
        error_selected = {
          fg = colors.error,
          bg = colors.filled,
          bold = true,
          italic = true,
        },
        error_diagnostic = {
          fg = colors.error,
          bg = colors.bg,
        },
        error_diagnostic_visible = {
          fg = colors.error,
          bg = colors.visible,
        },
        error_diagnostic_selected = {
          fg = colors.error,
          bg = colors.filled,
        },

        warning = {
          fg = colors.warning,
          bg = colors.bg,
        },
        warning_visible = {
          fg = colors.warning,
          bg = colors.visible,
        },
        warning_selected = {
          fg = colors.warning,
          bg = colors.filled,
          bold = true,
          italic = true,
        },
        warning_diagnostic = {
          fg = colors.warning,
          bg = colors.bg,
        },
        warning_diagnostic_visible = {
          fg = colors.warning,
          bg = colors.visible,
        },
        warning_diagnostic_selected = {
          fg = colors.warning,
          bg = colors.filled,
        },

        info = {
          fg = colors.info,
          bg = colors.bg,
        },
        info_visible = {
          fg = colors.info,
          bg = colors.visible,
        },
        info_selected = {
          fg = colors.info,
          bg = colors.filled,
          bold = true,
          italic = true,
        },
        info_diagnostic = {
          fg = colors.info,
          bg = colors.bg,
        },
        info_diagnostic_visible = {
          fg = colors.info,
          bg = colors.visible,
        },
        info_diagnostic_selected = {
          fg = colors.info,
          bg = colors.filled,
        },

        hint = {
          fg = colors.hint,
          bg = colors.bg,
        },
        hint_visible = {
          fg = colors.hint,
          bg = colors.visible,
        },
        hint_selected = {
          fg = colors.hint,
          bg = colors.filled,
          bold = true,
          italic = true,
        },
        hint_diagnostic = {
          fg = colors.hint,
          bg = colors.bg,
        },
        hint_diagnostic_visible = {
          fg = colors.hint,
          bg = colors.visible,
        },
        hint_diagnostic_selected = {
          fg = colors.hint,
          bg = colors.filled,
        },
      },
      options = {
        -- Basic settings
        mode = "buffers",
        themable = true,
        numbers = "none",

        -- Commands
        close_command = "Bdelete! %d",
        right_mouse_command = "Bdelete! %d",
        left_mouse_command = "buffer %d",
        middle_mouse_command = nil,

        -- Icons
        buffer_close_icon = icons.buffer.close,
        modified_icon = icons.buffer.modified,
        close_icon = icons.buffer.close,
        left_trunc_marker = "",
        right_trunc_marker = "",

        -- Appearance
        separator_style = { icons.buffer.separator, icons.buffer.separator },
        indicator = {
          icon = "☕", -- Coffee cup indicator (fun visual marker)
          style = "icon",
        },

        -- Naming
        name_formatter = function(buf)
          return " " .. buf.name
        end,

        -- Tab size
        max_name_length = 18,
        max_prefix_length = 15,
        tab_size = 18,

        -- Diagnostics
        diagnostics = "nvim_lsp",
        diagnostics_update_in_insert = false,
        diagnostics_indicator = function(count, level)
          local icon = icons.diagnostics[level:lower()]
          return " " .. icon .. count
        end,

        -- Behavior
        color_icons = true,
        show_buffer_icons = true,
        show_buffer_close_icons = true,
        show_close_icon = true,
        show_tab_indicators = true,
        persist_buffer_sort = true,
        enforce_regular_tabs = true,
        always_show_bufferline = true,
        sort_by = "id",
        hover = {
          enabled = true,
          delay = 0,
          reveal = { "close" },
        },

        -- Offsets
        offsets = {
          -- Removed neo-tree offset since we're using Snacks explorer + mini.files + Oil
        },
      },
    })

    -- Custom keymaps (LazyVim provides: <leader>bp=pin, <leader>bP=delete-unpinned,
    -- <S-h>/<S-l>=navigate, [b/]b=navigate, [B/]B=move, <leader>br/bl=close right/left)
    local map = vim.keymap.set
    local opts = { noremap = true, silent = true }

    -- Close buffers (vim-bbye for clean close)
    map("n", "<leader>bx", "<cmd>Bdelete!<cr>", opts) -- Close current buffer
    map("n", "<leader>bX", "<cmd>BufferLineCloseOthers<cr>", opts) -- Close other buffers

    -- Magic buffer-picking mode
    map("n", "<leader>bk", "<cmd>BufferLinePick<cr>", opts)

    -- Sort by tabs or buffers
    map("n", "<leader>bb", "<cmd>BufferLineToggleMode<cr>", opts)

    -- Jump to buffer number
    for i = 1, 9 do
      map("n", string.format("<leader>b%d", i), string.format("<cmd>BufferLineGoToBuffer %d<cr>", i), opts)
    end
  end,
}
