return {
  "echasnovski/mini.files",
  version = false,
  event = "VeryLazy",
  keys = {
    {
      "<leader>mf",
      function()
        local buf_name = vim.api.nvim_buf_get_name(0)
        local dir_name = vim.fn.fnamemodify(buf_name, ":p:h")
        if vim.fn.filereadable(buf_name) == 1 then
          require("mini.files").open(buf_name, true)
        elseif vim.fn.isdirectory(dir_name) == 1 then
          require("mini.files").open(dir_name, true)
        else
          require("mini.files").open(vim.uv.cwd(), true)
        end
      end,
      desc = "Mini Files (Current File)",
    },
    {
      "<leader>md",
      function()
        require("mini.files").open(vim.uv.cwd(), true)
      end,
      desc = "Mini Files (Directory)",
    },
    {
      "<leader>mh",
      function()
        require("mini.files").open(vim.fn.expand("~"), true)
      end,
      desc = "Mini Files (Home)",
    },
    {
      "<leader>mc",
      function()
        require("mini.files").open(vim.fn.stdpath("config"), true)
      end,
      desc = "Mini Files (Config)",
    },
    {
      "<leader>mp",
      function()
        local mf = require("mini.files")
        if not mf.close() then
          mf.open(mf.get_fs_entry().path)
        end
      end,
      desc = "Mini Files (Toggle Preview)",
    },
  },
  opts = {
    windows = {
      preview = true,
      width_focus = 30,
      width_preview = 80, -- Increased from 50 to 80 for better preview
    },
    options = {
      use_as_default_explorer = true, -- Set to true to use as default explorer
      permanent_delete = false,
    },
    -- Custom keymaps for macOS-specific features
    custom_keymaps = {
      copy_to_clipboard = "<space>y", -- Copy file/directory to macOS clipboard
      paste_from_clipboard = "<space>p", -- Paste from macOS clipboard
      copy_path = "<space>r", -- Copy relative path
      preview_image = "<space>i", -- Preview with macOS Quick Look
    },
    mappings = {
      close = "<esc>",
      go_in = "l",
      go_in_plus = "<CR>",
      go_out = "H",
      go_out_plus = "h",
      reset = "<BS>",
      reveal_cwd = ".",
      show_help = "g?",
      synchronize = "s",
      trim_left = "<",
      trim_right = ">",
      -- Additional file operation mappings
      ["<space>yy"] = function()
        local fs_entry = require("mini.files").get_fs_entry()
        if fs_entry then
          vim.fn.setreg("+", fs_entry.path)
          vim.notify("Copied path to clipboard: " .. fs_entry.path)
        end
      end,
      ["<M-c>"] = function()
        local fs_entry = require("mini.files").get_fs_entry()
        if fs_entry then
          vim.fn.setreg("+", fs_entry.path)
          vim.notify("Copied full path: " .. fs_entry.path)
        end
      end,
    },
  },
  config = function(_, opts)
    require("mini.files").setup(opts)

    -- Set up enhanced Git status indicators (from mini-files-git.lua)
    local nsMiniFiles = vim.api.nvim_create_namespace("mini_files_git")

    -- Cache for git status
    local gitStatusCache = {}
    local cacheTimeout = 2000 -- Cache timeout in milliseconds

    local function isSymlink(path)
      local stat = vim.loop.fs_lstat(path)
      return stat and stat.type == "link"
    end

    -- Map Git status to symbols and highlight groups
    local function mapSymbols(status, is_symlink)
      local statusMap = {
        [" M"] = { symbol = "✹", hlGroup = "MiniDiffSignChange" }, -- Modified in working directory
        ["M "] = { symbol = "•", hlGroup = "MiniDiffSignChange" }, -- Modified in index
        ["MM"] = { symbol = "≠", hlGroup = "MiniDiffSignChange" }, -- Modified in both
        ["A "] = { symbol = "+", hlGroup = "MiniDiffSignAdd" }, -- Added to staging
        ["AA"] = { symbol = "≈", hlGroup = "MiniDiffSignAdd" }, -- Added in both
        ["D "] = { symbol = "-", hlGroup = "MiniDiffSignDelete" }, -- Deleted from staging
        ["AM"] = { symbol = "⊕", hlGroup = "MiniDiffSignChange" }, -- Added in working tree, modified in index
        ["AD"] = { symbol = "-•", hlGroup = "MiniDiffSignChange" }, -- Added in index, deleted in working dir
        ["R "] = { symbol = "→", hlGroup = "MiniDiffSignChange" }, -- Renamed in index
        ["U "] = { symbol = "‖", hlGroup = "MiniDiffSignChange" }, -- Unmerged path
        ["UU"] = { symbol = "⇄", hlGroup = "MiniDiffSignAdd" }, -- Unmerged
        ["UA"] = { symbol = "⊕", hlGroup = "MiniDiffSignAdd" }, -- Unmerged, added in working tree
        ["??"] = { symbol = "?", hlGroup = "MiniDiffSignDelete" }, -- Untracked
        ["!!"] = { symbol = "!", hlGroup = "MiniDiffSignChange" }, -- Ignored
      }

      local result = statusMap[status] or { symbol = "?", hlGroup = "NonText" }
      local gitSymbol = result.symbol
      local gitHlGroup = result.hlGroup

      local symlinkSymbol = is_symlink and "↩" or ""

      -- Combine symlink symbol with Git status if both exist
      local combinedSymbol = (symlinkSymbol .. gitSymbol):gsub("^%s+", ""):gsub("%s+$", "")
      -- Change the color of the symlink icon
      local combinedHlGroup = is_symlink and "MiniDiffSignDelete" or gitHlGroup

      return combinedSymbol, combinedHlGroup
    end

    -- Fetch Git status for the current directory
    local function fetchGitStatus(cwd, callback)
      local function on_exit(content)
        if content.code == 0 then
          callback(content.stdout)
        end
      end
      vim.system({ "git", "status", "--ignored", "--porcelain" }, { text = true, cwd = cwd }, on_exit)
    end

    -- Escape pattern special characters
    local function escapePattern(str)
      if not str then
        return ""
      end
      return (str:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1"))
    end

    -- Update mini.files buffer with Git status
    local function updateMiniWithGit(buf_id, gitStatusMap)
      vim.schedule(function()
        local nlines = vim.api.nvim_buf_line_count(buf_id)
        local cwd = vim.fs.root(buf_id, ".git")
        local escapedcwd = escapePattern(cwd)
        if vim.fn.has("win32") == 1 then
          escapedcwd = escapedcwd:gsub("\\", "/")
        end

        for i = 1, nlines do
          local entry = require("mini.files").get_fs_entry(buf_id, i)
          if not entry then
            break
          end
          local relativePath = entry.path:gsub("^" .. escapedcwd .. "/", "")
          local status = gitStatusMap[relativePath]

          if status then
            local is_symlink = isSymlink(entry.path)
            local symbol, hlGroup = mapSymbols(status, is_symlink)
            vim.api.nvim_buf_set_extmark(buf_id, nsMiniFiles, i - 1, 0, {
              sign_text = symbol,
              sign_hl_group = hlGroup,
              priority = 2,
            })
          end
        end
      end)
    end

    -- Parse Git status output
    local function parseGitStatus(content)
      local gitStatusMap = {}
      for line in content:gmatch("[^\r\n]+") do
        local status, filePath = string.match(line, "^(..)%s+(.*)")
        -- Split the file path into parts
        local parts = {}
        for part in filePath:gmatch("[^/]+") do
          table.insert(parts, part)
        end
        -- Start with the root directory
        local currentKey = ""
        for i, part in ipairs(parts) do
          if i > 1 then
            -- Concatenate parts with a separator to create a unique key
            currentKey = currentKey .. "/" .. part
          else
            currentKey = part
          end
          -- If it's the last part, it's a file, so add it with its status
          if i == #parts then
            gitStatusMap[currentKey] = status
          else
            -- If it's not the last part, it's a directory. Check if it exists, if not, add it.
            if not gitStatusMap[currentKey] then
              gitStatusMap[currentKey] = status
            end
          end
        end
      end
      return gitStatusMap
    end

    -- Update Git status for the current buffer
    local function updateGitStatus(buf_id)
      local cwd = vim.uv.cwd()
      if not cwd or not vim.fs.root(cwd, ".git") then
        return
      end

      local currentTime = os.time()
      if gitStatusCache[cwd] and currentTime - gitStatusCache[cwd].time < cacheTimeout then
        updateMiniWithGit(buf_id, gitStatusCache[cwd].statusMap)
      else
        fetchGitStatus(cwd, function(content)
          local gitStatusMap = parseGitStatus(content)
          gitStatusCache[cwd] = {
            time = currentTime,
            statusMap = gitStatusMap,
          }
          updateMiniWithGit(buf_id, gitStatusMap)
        end)
      end
    end

    -- Clear the Git status cache
    local function clearCache()
      gitStatusCache = {}
    end

    -- Create an augroup for Git status updates
    local function augroup(name)
      return vim.api.nvim_create_augroup("MiniFiles_" .. name, { clear = true })
    end

    -- Set up autocmds for Git status updates
    vim.api.nvim_create_autocmd("User", {
      group = augroup("start"),
      pattern = "MiniFilesExplorerOpen",
      callback = function()
        local bufnr = vim.api.nvim_get_current_buf()
        updateGitStatus(bufnr)
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      group = augroup("close"),
      pattern = "MiniFilesExplorerClose",
      callback = function()
        clearCache()
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      group = augroup("update"),
      pattern = "MiniFilesBufferUpdate",
      callback = function(sii)
        local bufnr = sii.data.buf_id
        local cwd = vim.fn.expand("%:p:h")
        if gitStatusCache[cwd] then
          updateMiniWithGit(bufnr, gitStatusCache[cwd].statusMap)
        end
      end,
    })

    -- Add macOS-specific keymaps from mini-files-km.lua
    -- Only add these if we're on macOS
    if vim.fn.has("mac") == 1 then
      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
          local buf_id = args.data.buf_id
          local mini_files = require("mini.files")
          local keymaps = opts.custom_keymaps or {}

          -- Copy the current file or directory to the system clipboard (macOS only)
          vim.keymap.set("n", keymaps.copy_to_clipboard, function()
            local curr_entry = mini_files.get_fs_entry()
            if curr_entry then
              local path = curr_entry.path
              local cmd = string.format([[osascript -e 'set the clipboard to POSIX file "%s"' ]], path)
              local result = vim.fn.system(cmd)
              if vim.v.shell_error ~= 0 then
                vim.notify("Copy failed: " .. result, vim.log.levels.ERROR)
              else
                vim.notify(vim.fn.fnamemodify(path, ":t"), vim.log.levels.INFO)
                vim.notify("Copied to system clipboard", vim.log.levels.INFO)
              end
            else
              vim.notify("No file or directory selected", vim.log.levels.WARN)
            end
          end, { buffer = buf_id, noremap = true, silent = true, desc = "Copy file/directory to clipboard" })

          -- Paste from system clipboard (macOS only)
          vim.keymap.set("n", keymaps.paste_from_clipboard, function()
            local curr_entry = mini_files.get_fs_entry()
            if not curr_entry then
              vim.notify("Failed to retrieve current entry in mini.files.", vim.log.levels.ERROR)
              return
            end

            local curr_dir = curr_entry.fs_type == "directory" and curr_entry.path
              or vim.fn.fnamemodify(curr_entry.path, ":h")

            local script = [[
              tell application "System Events"
                try
                  set theFile to the clipboard as alias
                  set posixPath to POSIX path of theFile
                  return posixPath
                on error
                  return "error"
                end try
              end tell
            ]]

            local output = vim.fn.system("osascript -e " .. vim.fn.shellescape(script))
            if vim.v.shell_error ~= 0 or output:find("error") then
              vim.notify("Clipboard does not contain a valid file or directory.", vim.log.levels.WARN)
              return
            end

            local source_path = output:gsub("%s+$", "")
            if source_path == "" then
              vim.notify("Clipboard is empty or invalid.", vim.log.levels.WARN)
              return
            end

            local dest_path = curr_dir .. "/" .. vim.fn.fnamemodify(source_path, ":t")
            local copy_cmd = vim.fn.isdirectory(source_path) == 1 and { "cp", "-R", source_path, dest_path }
              or { "cp", source_path, dest_path }

            local result = vim.fn.system(copy_cmd)
            if vim.v.shell_error ~= 0 then
              vim.notify("Paste operation failed: " .. result, vim.log.levels.ERROR)
              return
            end

            mini_files.synchronize()
            vim.notify("Pasted successfully.", vim.log.levels.INFO)
          end, { buffer = buf_id, noremap = true, silent = true, desc = "Paste from clipboard" })

          -- Copy relative path to clipboard
          vim.keymap.set("n", keymaps.copy_path, function()
            local curr_entry = mini_files.get_fs_entry()
            if curr_entry then
              local home_dir = vim.fn.expand("~")
              local relative_path = curr_entry.path:gsub("^" .. home_dir, "~")
              vim.fn.setreg("+", relative_path)
              vim.notify(vim.fn.fnamemodify(relative_path, ":t"), vim.log.levels.INFO)
              vim.notify("Path copied to clipboard: ", vim.log.levels.INFO)
            else
              vim.notify("No file or directory selected", vim.log.levels.WARN)
            end
          end, { buffer = buf_id, noremap = true, silent = true, desc = "Copy relative path to clipboard" })

          -- Preview with macOS Quick Look
          vim.keymap.set("n", keymaps.preview_image, function()
            local curr_entry = mini_files.get_fs_entry()
            if curr_entry then
              vim.system({ "qlmanage", "-p", curr_entry.path }, {
                stdout = false,
                stderr = false,
              })
              vim.defer_fn(function()
                vim.system({ "osascript", "-e", 'tell application "qlmanage" to activate' })
              end, 200)
            else
              vim.notify("No file selected", vim.log.levels.WARN)
            end
          end, { buffer = buf_id, noremap = true, silent = true, desc = "Preview with macOS Quick Look" })
        end,
      })
    end
  end,
}
