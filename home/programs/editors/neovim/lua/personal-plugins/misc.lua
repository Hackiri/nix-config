-- Miscellaneous utilities from v12 config
local M = {}

---Smart duplicate: duplicates line or visual selection
function M.smartDuplicate()
  local mode = vim.fn.mode()

  if mode == "n" then
    -- Normal mode: duplicate current line
    local line = vim.api.nvim_get_current_line()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    vim.api.nvim_buf_set_lines(0, row, row, false, { line })
  elseif mode == "V" or mode == "v" or mode == "\22" then -- visual modes
    -- Visual mode: duplicate selection
    vim.cmd('normal! "zy')
    vim.cmd("normal! gv")
    vim.cmd('normal! "zp')
  end
end

---Toggle between common word pairs (true/false, yes/no, etc.)
---If no match found, increment number instead
function M.toggleOrIncrement()
  local togglePairs = {
    { "true", "false" },
    { "True", "False" },
    { "yes", "no" },
    { "Yes", "No" },
    { "on", "off" },
    { "On", "Off" },
    { "enable", "disable" },
    { "enabled", "disabled" },
    { "Enable", "Disable" },
    { "Enabled", "Disabled" },
    { "public", "private" },
    { "Public", "Private" },
    { "show", "hide" },
    { "Show", "Hide" },
    { "left", "right" },
    { "Left", "Right" },
    { "top", "bottom" },
    { "Top", "Bottom" },
    { "up", "down" },
    { "Up", "Down" },
    { "first", "last" },
    { "First", "Last" },
    { "start", "end" },
    { "Start", "End" },
    { "begin", "end" },
    { "Begin", "End" },
    { "open", "close" },
    { "Open", "Close" },
    { "min", "max" },
    { "Min", "Max" },
    { "minimum", "maximum" },
    { "Minimum", "Maximum" },
  }

  local cword = vim.fn.expand("<cword>")
  local toggled = false

  for _, pair in ipairs(togglePairs) do
    if cword == pair[1] then
      vim.cmd("normal! ciw" .. pair[2])
      toggled = true
      break
    elseif cword == pair[2] then
      vim.cmd("normal! ciw" .. pair[1])
      toggled = true
      break
    end
  end

  -- If no toggle found, increment number
  if not toggled then
    vim.cmd("normal! <C-a>")
  end
end

---Toggle between lowercase and Title Case for word under cursor
function M.toggleTitleCase()
  local cword = vim.fn.expand("<cword>")
  local isLower = cword:match("^%l")

  if isLower then
    -- Convert to Title Case
    local titleCase = cword:sub(1, 1):upper() .. cword:sub(2)
    vim.cmd("normal! ciw" .. titleCase)
  else
    -- Convert to lowercase
    vim.cmd("normal! guiw")
  end
end

---Fast warp: jump to next occurrence of character without entering search
---@param direction "forward"|"backward"
function M.fastWarp(direction)
  local char = vim.fn.getcharstr()
  if char == "" or char == "\27" then
    return
  end -- ESC pressed

  local searchCmd = direction == "forward" and "/" or "?"
  vim.fn.setreg("/", char)

  if direction == "forward" then
    vim.cmd("normal! n")
  else
    vim.cmd("normal! N")
  end
end

---Inspect LSP capabilities for current buffer
function M.lspCapabilities()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    vim.notify("No LSP clients attached", vim.log.levels.WARN)
    return
  end

  local capabilities = {}
  for _, client in ipairs(clients) do
    table.insert(capabilities, {
      name = client.name,
      capabilities = client.server_capabilities,
    })
  end

  vim.notify(vim.inspect(capabilities), nil, {
    title = "LSP Capabilities",
    timeout = false,
  })
end

---Inspect current buffer information
function M.inspectBuffer()
  local buf = vim.api.nvim_get_current_buf()
  local info = {
    bufnr = buf,
    name = vim.api.nvim_buf_get_name(buf),
    filetype = vim.bo[buf].filetype,
    buftype = vim.bo[buf].buftype,
    modified = vim.bo[buf].modified,
    modifiable = vim.bo[buf].modifiable,
    readonly = vim.bo[buf].readonly,
    lines = vim.api.nvim_buf_line_count(buf),
  }

  vim.notify(vim.inspect(info), nil, {
    title = "Buffer Info",
    timeout = false,
  })
end

---LSP rename with automatic camel/snake case conversion
function M.camelSnakeLspRename()
  local cword = vim.fn.expand("<cword>")

  -- Detect current case style
  local isSnake = cword:match("_")
  local newName

  if isSnake then
    -- Convert snake_case to camelCase
    newName = cword:gsub("_(%w)", function(c)
      return c:upper()
    end)
  else
    -- Convert camelCase to snake_case
    newName = cword:gsub("(%u)", function(c)
      return "_" .. c:lower()
    end)
    if newName:sub(1, 1) == "_" then
      newName = newName:sub(2)
    end
  end

  -- Set up LSP rename with the converted name
  vim.lsp.buf.rename(newName)
end

---Start or stop macro recording
---@param toggleKey string
---@param register string
function M.startOrStopRecording(toggleKey, register)
  local isRecording = vim.fn.reg_recording() ~= ""

  if isRecording then
    vim.cmd("normal! q")
    vim.notify("Recording stopped", vim.log.levels.INFO, { icon = "󰃽" })
  else
    vim.cmd("normal! q" .. register)
    vim.notify("Recording to register '" .. register .. "'", vim.log.levels.INFO, { icon = "󰃽" })
  end
end

---Play recording from register
---@param register string
function M.playRecording(register)
  local content = vim.fn.getreg(register)
  if content == "" then
    vim.notify("Register '" .. register .. "' is empty", vim.log.levels.WARN)
    return
  end

  vim.cmd("normal! @" .. register)
end

return M
