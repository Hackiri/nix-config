--[[ Alt-Alt Navigation
Alternative to vim's "alternative file" that improves its functionality.

1. gotoAltFile() - Improved `:buffer #` that avoids special buffers, deleted buffers, etc.
2. gotoMostChangedFile() - Go to the file in cwd with most git changes
3. Statusbar components for displaying alt file and most changed file
]]

local M = {}

local config = {
  statusbarMaxLength = 30,
  icons = {
    oldFile = "󰋚",
    altBuf = "󰐤",
    mostChangedFile = "󰓏",
  },
  ignore = {
    oldfiles = {
      "/COMMIT_EDITMSG",
      "/git-rebase-todo",
    },
    mostChangedFiles = {
      "/info.plist", -- Alfred workflows
      "/prefs.plist",
      "lazy-lock.json",
      ".lazy-lock.json",
    },
  },
}

---@param path string
---@param type "oldfiles"|"mostChangedFiles"
local function isIgnored(path, type)
  return vim.iter(config.ignore[type]):any(function(p)
    return path:find(p, nil, true) ~= nil
  end)
end

---@param msg string
---@param level? "info"|"trace"|"debug"|"warn"|"error"
---@param icon string
local function notify(msg, level, icon)
  level = level or "info"
  local lvl = vim.log.levels[level:upper()]
  vim.notify(msg, lvl, { title = "Alt-Alt", icon = icon })
end

---Get the alternate buffer
---@return string|nil altBufferName, nil if no alt buffer
local function getAltBuffer()
  local altBufnr = vim.fn.bufnr("#")
  if altBufnr < 0 then
    return
  end

  local valid = vim.api.nvim_buf_is_valid(altBufnr)
  local nonSpecial = vim.bo[altBufnr].buftype == "" or vim.bo[altBufnr].buftype == "help"
  local moreThanOneBuffer = #(vim.fn.getbufinfo({ buflisted = 1 })) > 1
  local currentBufNotAlt = vim.api.nvim_get_current_buf() ~= altBufnr
  local altBufName = vim.api.nvim_buf_get_name(altBufnr)
  local altBufExists = vim.uv.fs_stat(altBufName) ~= nil

  if valid and nonSpecial and moreThanOneBuffer and currentBufNotAlt and altBufExists then
    return altBufName
  end
end

---Get the alternate oldfile, accounting for non-existing files
---@return string|nil oldfile; nil if none exists
local function getAltOldfile()
  local curPath = vim.api.nvim_buf_get_name(0)
  for _, path in ipairs(vim.v.oldfiles) do
    local exists = vim.uv.fs_stat(path) ~= nil
    local sameFile = path == curPath
    local ignored = isIgnored(path, "oldfiles")
    if exists and not ignored and not sameFile then
      return path
    end
  end
end

---Get the file with most git changes in current directory
---@return string? filepath
---@return string? errmsg
local function getMostChangedFile()
  -- Get list of changed files
  local gitResponse = vim.system({ "git", "diff", "--numstat", "." }):wait()
  if gitResponse.code ~= 0 or not gitResponse.stdout then
    return nil, "Not in git repo."
  end

  local changedFiles = vim.split(gitResponse.stdout, "\n", { trimempty = true })
  if #changedFiles == 0 then
    return nil, "No files with changes found."
  end

  local gitroot = vim.trim(vim.system({ "git", "rev-parse", "--show-toplevel" }):wait().stdout or "")

  -- Identify file with most changes
  local targetFile
  local mostChanges = 0

  for _, line in ipairs(changedFiles) do
    local added, deleted, relPath = line:match("(%d+)%s+(%d+)%s+(.+)")
    if added and deleted and relPath then
      local absPath = vim.fs.normalize(gitroot .. "/" .. relPath)
      local ignored = isIgnored(absPath, "mostChangedFiles")
      local nonExistent = vim.uv.fs_stat(absPath) == nil

      if not ignored and not nonExistent then
        local changes = tonumber(added) + tonumber(deleted)
        if changes > mostChanges then
          mostChanges = changes
          targetFile = absPath
        end
      end
    end
  end

  if not targetFile then
    return nil, "No valid changed files found."
  end

  return targetFile, nil
end

---Format filename for statusbar display
---@param path string
---@return string
local function nameForStatusbar(path)
  local displayName = vim.fs.basename(path)

  -- Add parent if displayname is same as basename of current file
  local currentBasename = vim.fs.basename(vim.api.nvim_buf_get_name(0))
  if currentBasename == displayName then
    local parent = vim.fs.basename(vim.fs.dirname(path))
    displayName = parent .. "/" .. displayName
  end

  -- Truncate if too long
  local maxLength = config.statusbarMaxLength
  if #displayName > maxLength then
    displayName = vim.trim(displayName:sub(1, maxLength)) .. "…"
  end

  return displayName
end

--------------------------------------------------------------------------------
-- Public Functions

---Go to alternate file or oldfile
function M.gotoAltFile()
  if vim.bo.buftype ~= "" then
    notify("Cannot do that in special buffer.", "warn", config.icons.altBuf)
    return
  end

  local altBuf = getAltBuffer()
  local altOld = getAltOldfile()

  if altBuf then
    vim.api.nvim_set_current_buf(vim.fn.bufnr("#"))
  elseif altOld then
    vim.cmd.edit(altOld)
  else
    notify("No alt file or oldfile available.", "error", config.icons.oldFile)
  end
end

---Go to file with most changes
function M.gotoMostChangedFile()
  local targetFile, errmsg = getMostChangedFile()
  if errmsg then
    notify(errmsg, "warn", config.icons.mostChangedFile)
    return
  end

  local currentFile = vim.api.nvim_buf_get_name(0)
  if targetFile == currentFile then
    notify("Already at the most changed file.", "trace", config.icons.mostChangedFile)
  else
    vim.cmd.edit(targetFile)
  end
end

--------------------------------------------------------------------------------
-- Statusbar Components

local mostChangedFile

-- Update most changed file cache
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained" }, {
  desc = "Alt-alt: Update most changed file cache",
  group = vim.api.nvim_create_augroup("AltAltStatusbar", { clear = true }),
  callback = function()
    vim.defer_fn(function()
      mostChangedFile = getMostChangedFile()
    end, 1)
  end,
})

---Statusbar component for most changed file
---@return string
function M.mostChangedFileStatusbar()
  local targetFile = mostChangedFile
  if not targetFile then
    return ""
  end

  local currentFile = vim.api.nvim_buf_get_name(0)
  local altFile = getAltBuffer() or getAltOldfile()
  if targetFile == currentFile or targetFile == altFile then
    return ""
  end

  local icon = config.icons.mostChangedFile
  return vim.trim(icon .. " " .. nameForStatusbar(targetFile))
end

---Statusbar component for alt file
---@return string
function M.altFileStatusbar()
  local altBuf = getAltBuffer()
  local altOld = getAltOldfile()
  local path = altBuf or altOld

  if not path then
    return ""
  end

  local icon = altBuf and config.icons.altBuf or config.icons.oldFile
  return vim.trim(icon .. " " .. nameForStatusbar(path))
end

--------------------------------------------------------------------------------
return M
