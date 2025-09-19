return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require("harpoon")
    harpoon:setup()
  end,
  keys = {
    {
      "<leader>ma",
      function()
        require("harpoon"):list():append()
      end,
      desc = "Add file to harpoon",
    },
    {
      "<leader>mm",
      function()
        local harpoon = require("harpoon")
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end,
      desc = "Show harpoon marks",
    },
    {
      "<leader>mn",
      function()
        require("harpoon"):list():next()
      end,
      desc = "Next harpoon mark",
    },
    {
      "<leader>mp",
      function()
        require("harpoon"):list():prev()
      end,
      desc = "Prev harpoon mark",
    },
    {
      "<leader>m1",
      function()
        require("harpoon"):list():select(1)
      end,
      desc = "Harpoon buffer 1",
    },
    {
      "<leader>m2",
      function()
        require("harpoon"):list():select(2)
      end,
      desc = "Harpoon buffer 2",
    },
    {
      "<leader>m3",
      function()
        require("harpoon"):list():select(3)
      end,
      desc = "Harpoon buffer 3",
    },
    {
      "<leader>m4",
      function()
        require("harpoon"):list():select(4)
      end,
      desc = "Harpoon buffer 4",
    },
  },
}
