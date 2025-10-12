-- Mason and LSP configuration
return {
  -- Mason package manager for external tools
  {
    "mason-org/mason.nvim",
    version = "2.*", -- LazyVim 15.x requires mason.nvim v2.x
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    -- Load Mason earlier in the startup process
    lazy = false,
    priority = 100,
    opts = {
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
      -- Configure path to Nix Python installation
      PATH = "append",
      -- Add your nix-darwin Python path
      -- This will make Mason use the Python from nix-darwin
      registries = {
        -- Override the default registry
        "github:mason-org/mason-registry",
      },
      -- We'll handle installation through mason-tool-installer instead
      auto_install = false,
      -- Ensure Mason can find the right installation paths
      install_root_dir = vim.fn.stdpath("data") .. "/mason",
    },
    -- Set up Mason to use the nix-darwin Python
    config = function(_, opts)
      require("mason").setup(opts)

      -- Get the path to the nix-darwin Python
      local handle = io.popen("which python3")
      local python_path = handle:read("*a"):gsub("\n$", "")
      handle:close()

      -- Set the Python path for Mason
      vim.g.mason_python_executable = python_path

      -- Configure Mason to use python3 -m pip instead of direct pip command
      -- This is more reliable in Nix environments
      vim.g.mason_pip_cmd = python_path .. " -m pip"

      -- Check if pip module is available
      local pip_check_cmd = python_path .. " -c 'import pip; print(pip.__version__)' 2>/dev/null || echo 'not found'"
      local pip_check = io.popen(pip_check_cmd)
      local pip_result = pip_check:read("*a")
      pip_check:close()

      if not pip_result:match("not found") then
        -- Pip module is available, we can use python3 -m pip
        return
      end

      -- Check for pip3 executable as fallback
      local pip3_check = io.popen("which pip3 2>/dev/null || echo 'not found'")
      local pip3_path = pip3_check:read("*a"):gsub("\n$", "")
      pip3_check:close()

      if pip3_path ~= "not found" then
        -- Use pip3 directly if available
        vim.g.mason_pip_cmd = pip3_path
        return
      end

      -- If we get here, pip is not available in any form
      vim.notify(
        "Mason: pip not found in nix Python. Some Python-based tools may not install correctly.\n"
          .. "Consider adding 'python3Packages.pip' to your nix packages.",
        vim.log.levels.WARN
      )
    end,
  },
}
