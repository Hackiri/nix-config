return {
  "hedyhli/outline.nvim",
  lazy = true,
  cmd = { "Outline", "OutlineOpen" },
  keys = {
    -- Changed from vo/vO to so/sO to avoid conflicts
    { "<leader>so", "<cmd>Outline<CR>", desc = "Toggle Code Outline" },
    { "<leader>sO", "<cmd>OutlineOpen<CR>", desc = "Open Code Outline" },
  },
  opts = {
    -- Outline configuration
    outline_window = {
      -- Width of the outline window
      width = 35,
      -- Position of the window can be "left" or "right"
      position = "right",
      -- Show relative line numbers in the outline window
      relative_numbers = true,
      -- Hide the cursor in the outline window
      hide_cursor = true,
      -- Auto focus on hover
      auto_hover = true,
    },
    -- Symbol folding
    symbol_folding = {
      -- Unfold entire symbol tree by default
      autofold_depth = false,
    },
    -- Symbols to show in the outline window
    symbols = {
      -- Show these symbols in the outline window
      filter = {
        "Class",
        "Constructor",
        "Enum",
        "Function",
        "Interface",
        "Method",
        "Struct",
        "Variable",
        "Field",
        "Property",
      },
      -- Configure symbol icons
      icons = {
        File = { icon = "󰈙", hl = "Identifier" },
        Module = { icon = "󰆧", hl = "Include" },
        Namespace = { icon = "󰌗", hl = "Include" },
        Package = { icon = "󰏖", hl = "Include" },
        Class = { icon = "󰌗", hl = "Type" },
        Method = { icon = "󰆧", hl = "Function" },
        Property = { icon = "", hl = "Identifier" },
        Field = { icon = "󰆨", hl = "Identifier" },
        Constructor = { icon = "", hl = "Special" },
        Enum = { icon = "󰕘", hl = "Type" },
        Interface = { icon = "", hl = "Type" },
        Function = { icon = "󰊕", hl = "Function" },
        Variable = { icon = "", hl = "Constant" },
        Constant = { icon = "", hl = "Constant" },
        String = { icon = "󰀬", hl = "String" },
        Number = { icon = "󰎠", hl = "Number" },
        Boolean = { icon = "", hl = "Boolean" },
        Array = { icon = "󰅪", hl = "Constant" },
        Object = { icon = "󰅩", hl = "Type" },
        Key = { icon = "󰌋", hl = "Type" },
        Null = { icon = "", hl = "Type" },
        EnumMember = { icon = "", hl = "Identifier" },
        Struct = { icon = "󰌗", hl = "Type" },
        Event = { icon = "", hl = "Type" },
        Operator = { icon = "󰆕", hl = "Operator" },
        TypeParameter = { icon = "󰊄", hl = "Type" },
      },
    },
    -- Guide lines and markers
    guides = {
      enabled = true,
      markers = {
        bottom = "└",
        middle = "├",
        vertical = "│",
      },
    },
    -- Preview configuration
    preview_window = {
      -- Auto preview when cursor moves in outline window
      auto_preview = true,
      -- Width of the preview window (percentage or number of columns)
      width = 50,
      -- Hide the preview window when outline window is closed
      auto_close = true,
    },
    -- Keymaps in the outline window
    keymaps = {
      -- Show help message
      show_help = "?",
      -- Close outline window
      close = "q",
      -- Jump to symbol under cursor
      goto_location = "<Cr>",
      -- Fold symbol under cursor
      fold = "h",
      -- Unfold symbol under cursor
      unfold = "l",
      -- Fold all symbols
      fold_all = "<leader>zc", -- Changed from W
      -- Unfold all symbols
      unfold_all = "<leader>zo", -- Changed from E
      -- Fold other symbols
      fold_reset = "<leader>zr", -- Changed from R
      -- Toggle preview
      hover_symbol = "K",
    },
  },
}
