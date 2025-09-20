-- Neovim Lua colors configuration

-- Load the colors once when the module is required and then expose the colors
-- directly. This avoids the need to call load_colors() in every file

-- Function to load colors from the external file
local function load_colors()
  local colors = {}

  -- First try to find the file in the current config directory
  local config_paths = {
    vim.fn.stdpath("config") .. "/lua/config/active-colorscheme.sh",
    vim.fn.expand("~/nix-config/home/programs/editors/neovim/lua/config/active-colorscheme/active-colorscheme.sh"),
  }

  local file
  local active_file

  -- Try each possible path
  for _, path in ipairs(config_paths) do
    file = io.open(path, "r")
    if file then
      active_file = path
      break
    end
  end

  -- If file not found, use default colors
  if not file then
    vim.notify("Could not open active colorscheme file. Using default colors.", vim.log.levels.WARN)
    return {
      color0 = "#282c34",
      color1 = "#e06c75",
      color2 = "#98c379",
      color3 = "#e5c07b",
      color4 = "#61afef",
      color5 = "#c678dd",
      color6 = "#56b6c2",
      color7 = "#abb2bf",
      color8 = "#545862",
      color9 = "#e06c75",
      color10 = "#98c379",
      color11 = "#e5c07b",
      color12 = "#61afef",
      color13 = "#c678dd",
      color14 = "#56b6c2",
      color15 = "#c8ccd4",
      background = "#282c34",
      foreground = "#abb2bf",
    }
  end

  -- Parse the file
  for line in file:lines() do
    if not line:match("^%s*#") and not line:match("^%s*$") and not line:match("^wallpaper=") then
      local name, value = line:match("^(%S+)=%s*(.+)")
      if name and value then
        colors[name] = value:gsub('"', "")
      end
    end
  end

  file:close()
  return colors
end

-- Load colors when the module is required
local colors = load_colors()

-- Check if the 'vim' global exists (i.e., if running in Neovim)
if _G.vim then
  for name, hex in pairs(colors) do
    vim.api.nvim_set_hl(0, name, { fg = hex })
  end
end

-- Return the colors table for external usage (like wezterm)
return colors
