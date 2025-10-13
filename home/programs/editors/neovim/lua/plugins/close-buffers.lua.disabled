-- Close hidden and nameless buffers
return {
  "kazhala/close-buffers.nvim",
  event = "VeryLazy",
  version = "*",
  keys = {
    {
      "<leader>th",
      function()
        require("close_buffers").delete({ type = "hidden" })
      end,
      desc = "Close Hidden Buffers",
    },
    {
      "<leader>tu",
      function()
        require("close_buffers").delete({ type = "nameless" })
      end,
      desc = "Close Nameless Buffers",
    },
  },
}
