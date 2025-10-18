-- Set leader key before lazy
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- Enable editorconfig
vim.g.editorconfig = true

-- General
vim.opt.mouse = "a" -- Enable mouse support
vim.opt.clipboard = "unnamedplus" -- Use system clipboard
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.conceallevel = 3 -- Hide * markup for bold and italic
vim.opt.confirm = true -- Confirm to save changes before exiting modified buffer
vim.opt.formatoptions = "jcroqlnt" -- tcqj
vim.opt.grepformat = "%f:%l:%c:%m"
vim.opt.grepprg = "rg --vimgrep"

-- Enable break indent (from kickstart)
vim.opt.breakindent = true

-- Decrease update time (from kickstart)
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time (from kickstart)
vim.opt.timeoutlen = 300

-- Preview substitutions live, as you type (from kickstart)
vim.opt.inccommand = "split"

-- UI
vim.opt.termguicolors = true -- True color support
vim.opt.background = "dark" -- Set background to dark
vim.opt.number = true -- Print line number
vim.opt.relativenumber = true -- Relative line numbers
vim.opt.showmode = false -- Don't show mode since we have a statusline
vim.opt.signcolumn = "yes" -- Always show signcolumn
vim.opt.scrolloff = 10 -- Number of lines to keep above and below the cursor (kickstart uses 10)
vim.opt.cursorline = true -- Enable highlighting of the current line
vim.opt.cmdheight = 0 -- Hide command line unless needed
vim.opt.laststatus = 3 -- Global statusline
vim.opt.guicursor = "n-v-c:block-Cursor/lCursor" -- Cursor shape
vim.opt.winborder = "rounded" -- Rounded window borders

-- Visualize whitespace (from kickstart)
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Indenting
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.shiftwidth = 2 -- Shift 2 spaces when tab
vim.opt.tabstop = 2 -- 1 tab == 2 spaces
vim.opt.softtabstop = 2 -- 1 tab == 2 spaces
vim.opt.smartindent = true -- Autoindent new lines
vim.opt.autoindent = true -- Copy indent from current line when starting new one
vim.opt.wrap = false -- Don't wrap lines

-- Files
vim.opt.backup = false -- No backup file
vim.opt.swapfile = false -- No swap file
vim.opt.undofile = true -- Enable persistent undo
vim.opt.undolevels = 10000 -- Number of undo levels
vim.opt.writebackup = false -- No backup file

-- Search
vim.opt.ignorecase = true -- Ignore case when searching
vim.opt.smartcase = true -- Don't ignore case with capitals
vim.opt.hlsearch = true -- Highlight search results
vim.opt.incsearch = true -- Show search matches as you type

-- Windows
vim.opt.splitbelow = true -- Put new windows below current
vim.opt.splitright = true -- Put new windows right of current

-- Better buffer handling
vim.opt.hidden = true -- Enable background buffers

-- Status column and signs
vim.opt.statuscolumn = "" -- Reset statuscolumn to default
vim.opt.signcolumn = "yes" -- Always show sign column

-- Decrease update time
vim.opt.updatetime = 250 -- Faster completion
vim.opt.timeout = true
vim.opt.timeoutlen = 300 -- Time to wait for a mapped sequence to complete

-- Wild menu
vim.opt.wildmode = "longest:full,full" -- Command-line completion mode
vim.opt.wildmenu = true -- Command-line completion
vim.opt.wildignore = {
  "*.pyc",
  "**/.git/*",
  "**/.svn/*",
  "**/.hg/*",
  "**/CVS/*",
  "**/.DS_Store",
  "**/node_modules/*",
  "**/dist/*",
}

-- Fold settings
vim.opt.fillchars:append({
  eob = " ",
  fold = " ",
  foldopen = "▾",
  foldsep = " ",
  foldclose = "▸",
})
vim.opt.foldcolumn = "1"
vim.opt.foldenable = true
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99

-- Fix markdown indentation settings
vim.g.markdown_recommended_style = 2

-- backspace
vim.opt.backspace = "indent,eol,start"

-- Neovide-specific settings
if vim.g.neovide then
  -- Performance settings
  vim.g.neovide_refresh_rate = 120 -- Adjust to your monitor's refresh rate
  vim.g.neovide_refresh_rate_idle = 5 -- Lower refresh rate when idle to save resources

  -- Cursor animations
  vim.g.neovide_cursor_animation_length = 0.08 -- Cursor animation duration
  vim.g.neovide_cursor_trail_size = 0.4 -- Cursor trail length
  vim.g.neovide_cursor_antialiasing = true -- Smooth cursor rendering
  vim.g.neovide_cursor_animate_in_insert_mode = true -- Animate cursor in insert mode
  vim.g.neovide_cursor_animate_command_line = true -- Animate cursor in command line
  vim.g.neovide_cursor_unfocused_outline_width = 0.125 -- Outline width when unfocused

  -- Cursor particle effects (choose one style)
  -- Options: "", "railgun", "torpedo", "pixiedust", "sonicboom", "ripple", "wireframe"
  vim.g.neovide_cursor_vfx_mode = "railgun" -- Fun cursor trail effect
  vim.g.neovide_cursor_vfx_opacity = 200.0 -- Particle opacity
  vim.g.neovide_cursor_vfx_particle_lifetime = 1.2 -- Particle lifetime
  vim.g.neovide_cursor_vfx_particle_density = 7.0 -- Particle density
  vim.g.neovide_cursor_vfx_particle_speed = 10.0 -- Particle speed

  -- Padding (window inner padding in pixels)
  vim.g.neovide_padding_top = 0
  vim.g.neovide_padding_bottom = 0
  vim.g.neovide_padding_right = 0
  vim.g.neovide_padding_left = 0

  -- Transparency (0.0 = fully transparent, 1.0 = opaque)
  vim.g.neovide_transparency = 0.95 -- Slight transparency for modern look
  vim.g.neovide_window_blurred = true -- Blur background on macOS

  -- Floating window transparency
  vim.g.neovide_floating_blur_amount_x = 2.0
  vim.g.neovide_floating_blur_amount_y = 2.0
  vim.g.neovide_floating_shadow = true
  vim.g.neovide_floating_z_height = 10
  vim.g.neovide_light_angle_degrees = 45
  vim.g.neovide_light_radius = 5

  -- Scroll animation
  vim.g.neovide_scroll_animation_length = 0.3 -- Smooth scrolling
  vim.g.neovide_scroll_animation_far_lines = 1 -- Start animation on far scrolls

  -- Hiding the mouse when typing
  vim.g.neovide_hide_mouse_when_typing = true

  -- Underline automatic scaling (adjusts underline stroke width based on font size)
  vim.g.neovide_underline_stroke_scale = 1.0

  -- Theme (sync with system theme)
  vim.g.neovide_theme = "auto" -- "auto", "light", or "dark"

  -- Remember window size and position
  vim.g.neovide_remember_window_size = true

  -- Fullscreen
  vim.g.neovide_fullscreen = false -- Start in windowed mode

  -- Input settings
  vim.g.neovide_input_use_logo = true -- Use CMD key on macOS
  vim.g.neovide_input_macos_option_key_is_meta = "only_left" -- Left option as meta, right option for special chars

  -- Confirm quit
  vim.g.neovide_confirm_quit = true -- Ask before quitting with unsaved changes

  -- Touch deadzone (for touchpad scrolling)
  vim.g.neovide_touch_deadzone = 6.0

  -- Position animation
  vim.g.neovide_position_animation_length = 0.15

  -- Profiler (for debugging performance)
  vim.g.neovide_profiler = false -- Set to true if you need to debug performance
end
