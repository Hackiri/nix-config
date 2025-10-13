-- Go forward/backward with square brackets
return {
  "nvim-mini/mini.bracketed",
  event = "BufReadPost",
  version = "*",
  config = function()
    local bracketed = require("mini.bracketed")
    bracketed.setup({
      file = { suffix = "" },
      window = { suffix = "" },
      quickfix = { suffix = "" },
      yank = { suffix = "" },
      treesitter = { suffix = "n" },
    })
  end,
}
