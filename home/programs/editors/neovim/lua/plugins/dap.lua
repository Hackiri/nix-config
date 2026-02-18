-- Debug Adapter Protocol configuration
return {
  -- DAP client for neovim
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      -- UI for DAP
      { "rcarriga/nvim-dap-ui" },
      -- Virtual text for DAP
      { "theHamsta/nvim-dap-virtual-text" },
      -- Mason integration
      { "jay-babu/mason-nvim-dap.nvim" },
      -- Python adapter
      { "mfussenegger/nvim-dap-python" },
      -- Go adapter
      { "leoluz/nvim-dap-go" },
    },
    keys = {
      {
        "<leader>dB",
        function()
          require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end,
        desc = "Breakpoint Condition",
      },
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Toggle Breakpoint",
      },
      {
        "<leader>dc",
        function()
          require("dap").continue()
        end,
        desc = "Continue",
      },
      {
        "<leader>dC",
        function()
          require("dap").run_to_cursor()
        end,
        desc = "Run to Cursor",
      },
      {
        "<leader>dg",
        function()
          require("dap").goto_()
        end,
        desc = "Go to Line (no execute)",
      },
      {
        "<leader>di",
        function()
          require("dap").step_into()
        end,
        desc = "Step Into",
      },
      {
        "<leader>dj",
        function()
          require("dap").down()
        end,
        desc = "Down",
      },
      {
        "<leader>dk",
        function()
          require("dap").up()
        end,
        desc = "Up",
      },
      {
        "<leader>dl",
        function()
          require("dap").run_last()
        end,
        desc = "Run Last",
      },
      {
        "<leader>do",
        function()
          require("dap").step_out()
        end,
        desc = "Step Out",
      },
      {
        "<leader>dO",
        function()
          require("dap").step_over()
        end,
        desc = "Step Over",
      },
      {
        "<leader>dp",
        function()
          require("dap").pause()
        end,
        desc = "Pause",
      },
      {
        "<leader>dr",
        function()
          require("dap").repl.toggle()
        end,
        desc = "Toggle REPL",
      },
      {
        "<leader>ds",
        function()
          require("dap").session()
        end,
        desc = "Session",
      },
      {
        "<leader>dt",
        function()
          require("dap").terminate()
        end,
        desc = "Terminate",
      },
      {
        "<leader>dw",
        function()
          require("dap.ui.widgets").hover()
        end,
        desc = "Widgets",
      },
    },
    config = function()
      -- Use _G.dap if it exists, otherwise require it
      local dap = _G.dap or require("dap")

      -- Safely require dapui
      local ok, dapui = pcall(require, "dapui")
      if not ok then
        vim.notify("Could not load dapui", vim.log.levels.WARN)
        return
      end

      -- Set up UI with custom icons
      dapui.setup({
        icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
        controls = {
          icons = {
            pause = "⏸",
            play = "▶",
            step_into = "⏎",
            step_over = "⏭",
            step_out = "⏮",
            step_back = "b",
            run_last = "▶▶",
            terminate = "⏹",
            disconnect = "⏏",
          },
        },
      })

      -- Set up virtual text
      require("nvim-dap-virtual-text").setup({
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = false,
        show_stop_reason = true,
        commented = false,
      })

      -- Automatically open/close the UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- Python configuration
      -- Use system Python path instead of a virtual environment
      local python_path = vim.fn.exepath("python3")
      if python_path == "" then
        python_path = vim.fn.exepath("python")
      end

      -- Safely set up Python debugging
      local dap_python_ok, dap_python = pcall(require, "dap-python")
      if dap_python_ok then
        -- Try Mason's debugpy installation first ($MASON/packages/ is the install root)
        local mason_debugpy = vim.fn.expand("$MASON/packages/debugpy/venv/bin/python")
        if vim.fn.executable(mason_debugpy) == 1 then
          dap_python.setup(mason_debugpy)
        else
          dap_python.setup(python_path)
        end
      end

      -- Go configuration
      local dap_go_ok, dap_go = pcall(require, "dap-go")
      if dap_go_ok then
        dap_go.setup()
      end

      -- LLDB adapter for C/C++/Rust
      local lldb_path = vim.fn.exepath("lldb-dap")
      if lldb_path ~= "" then
        dap.adapters.lldb = {
          type = "executable",
          command = lldb_path,
          name = "lldb",
        }

        dap.configurations.cpp = {
          {
            name = "Launch",
            type = "lldb",
            request = "launch",
            program = function()
              return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
            args = {},
          },
        }
        dap.configurations.c = dap.configurations.cpp
        dap.configurations.rust = dap.configurations.cpp
      end

      -- JavaScript/TypeScript debugging with vscode-js-debug
      -- This uses mason to install the adapter
      local mason_dap_ok, mason_dap = pcall(require, "mason-nvim-dap")
      if mason_dap_ok then
        mason_dap.setup({
          ensure_installed = { "js-debug-adapter" },
          automatic_installation = true,
          handlers = {
            function(config)
              -- All sources with no handler get passed here
              -- Keep original functionality
              mason_dap.default_setup(config)
            end,
          },
        })
      end

      -- Set up js-debug-adapter with multiple path finding strategies
      local function find_js_debug()
        -- Strategy 1: Check if installed via Mason ($MASON/packages/)
        local mason_path = vim.fn.expand("$MASON/packages/js-debug-adapter")
        if vim.fn.isdirectory(mason_path) == 1 then
          local possible_paths = {
            mason_path .. "/js-debug/src/dapDebugServer.js",
            mason_path .. "/src/dapDebugServer.js",
            mason_path .. "/out/src/dapDebugServer.js",
          }

          for _, path in ipairs(possible_paths) do
            if vim.fn.filereadable(path) == 1 then
              return path
            end
          end

          local found_files = vim.fn.glob(mason_path .. "/**/dapDebugServer.js", true, true)
          if #found_files > 0 then
            return found_files[1]
          end
        end

        -- Strategy 2: Check if installed via Nix
        local nix_paths = {
          "/run/current-system/sw/lib/vscode-js-debug/js-debug/src/dapDebugServer.js",
          "/run/current-system/sw/share/vscode-js-debug/js-debug/src/dapDebugServer.js",
          "/nix/store/*-vscode-js-debug/lib/vscode-js-debug/js-debug/src/dapDebugServer.js",
        }

        for _, pattern in ipairs(nix_paths) do
          local found_files = vim.fn.glob(pattern, true, true)
          if #found_files > 0 then
            return found_files[1]
          end
        end

        -- Strategy 3: Try to find it in the PATH
        local handle =
          io.popen("find /nix/store -path '*/vscode-js-debug/*' -name 'dapDebugServer.js' 2>/dev/null | head -n 1")
        if handle then
          local result = handle:read("*a")
          handle:close()
          if result and result ~= "" then
            return result:gsub("%s+$", "") -- Trim whitespace
          end
        end

        -- Not found
        return nil
      end

      -- Find the debug server path
      local debug_server_path = find_js_debug()

      -- Set up the adapter with the found path
      if debug_server_path then
        vim.notify("Found js-debug-adapter at: " .. debug_server_path, vim.log.levels.INFO)
        dap.adapters["pwa-node"] = {
          type = "server",
          host = "localhost",
          port = "${port}",
          executable = {
            command = "node",
            args = { debug_server_path, "${port}" },
          },
        }
      else
        vim.notify("Could not find js-debug-adapter. JavaScript debugging will not work.", vim.log.levels.WARN)
      end

      -- Configure JavaScript/TypeScript debugging
      dap.configurations.javascript = {
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          cwd = "${workspaceFolder}",
          sourceMaps = true,
        },
      }

      dap.configurations.typescript = dap.configurations.javascript
    end,
  },

  -- UI for DAP
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio", -- Required dependency for nvim-dap-ui
    },
    keys = {
      {
        "<leader>du",
        function()
          require("dapui").toggle()
        end,
        desc = "Toggle DAP UI",
      },
    },
    config = function()
      -- Ensure dapui is properly loaded (setup handled in main dap config)
      require("dapui")
    end,
  },

  -- Mason DAP integration
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = { "mason-org/mason.nvim", "mfussenegger/nvim-dap" },
    opts = {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_setup = true,
      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},
      ensure_installed = {
        "python", -- Python debugging
        "js-debug-adapter", -- JavaScript/TypeScript debugging
      },
    },
  },
}
