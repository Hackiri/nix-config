local M = {}

local function is_darwin()
  return vim.uv.os_uname().sysname == "Darwin"
end

local function copy_osc52(text)
  if type(text) ~= "string" or text == "" then
    return
  end

  local encoded = vim.base64.encode(text)
  local osc52 = ("\x1b]52;c;%s\x07"):format(encoded)
  pcall(vim.fn.chansend, vim.v.stderr, osc52)
end

function M.setup_provider()
  if vim.env.SSH_TTY then
    vim.g.clipboard = {
      name = "OSC 52",
      copy = {
        ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
        ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
      },
      paste = {
        ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
        ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
      },
    }
  elseif is_darwin() then
    vim.g.clipboard = {
      name = "macOS-clipboard",
      copy = {
        ["+"] = "pbcopy",
        ["*"] = "pbcopy",
      },
      paste = {
        ["+"] = "pbpaste",
        ["*"] = "pbpaste",
      },
    }
  end
end

function M.setup()
  M.setup_provider()

  vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("user_clipboard_yank_sync", { clear = true }),
    desc = "Copy real yanks to system, OSC52, and tmux clipboards",
    callback = M.sync_yank_to_clipboards,
  })
end

function M.sync_yank_to_clipboards()
  if vim.v.event.operator ~= "y" then
    return
  end

  local ok, text = pcall(vim.fn.getreg, "0")
  if not ok or type(text) ~= "string" or text == "" then
    return
  end

  local copied_to_provider = false
  if vim.fn.has("clipboard") == 1 then
    copied_to_provider = pcall(vim.fn.setreg, "+", text)
  end

  if not copied_to_provider and (vim.env.SSH_CONNECTION or vim.env.SSH_TTY) then
    copy_osc52(text)
  end

  if vim.env.TMUX and vim.fn.executable("tmux") == 1 then
    pcall(function()
      vim.system({ "tmux", "set-buffer", "-w", text }):wait()
    end)
  end
end

return M
