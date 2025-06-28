#!/usr/bin/env bash

# Custom colorscheme configuration file
# Used for Neovim and terminal color settings

# These files have to be executable

# Lighter markdown headings
# 4 colors to the right for these ligher headings
# https://www.color-hex.com/color/987afb
#
# Given that color A (#987afb) becomes color B (#5b4996) when darkened 4 steps
# to the right, apply the same darkening ratio/pattern to calculate what color
# C (#37f499) becomes when darkened 4 steps to the right.
#
# Markdown heading 1 - color04
color18=#2d244b
# Markdown heading 2 - color02
color19=#10492d
# Markdown heading 3 - color03
color20=#013e4a
# Markdown heading 4 - color01
color21=#4b314c
# Markdown heading 5 - color05
color22=#1e2b00
# Markdown heading 6 - color08
color23=#2d1c08
# Markdown heading foreground
# usually set to color10 which is the terminal background
color26=#0D1116

color04=#987afb
color02=#37f499
color03=#04d1f9
color01=#fca6ff
color05=#9ad900
color08=#e58f2a
color06=#05ff23

# Colors to the right from https://www.colorhexa.com
# Terminal and neovim background
color10=#0D1116
# Lualine across, 1 color to the right of background
color17=#141b22
# Markdown codeblock, 2 to the right of background
color07=#141b22
# Background of inactive tmux pane, 3 to the right of background
color25=#232e3b
# line across cursor, 5 to the right of background
color13=#232e3b
# Tmux inactive windows, 7 colors to the right of background
color15=#013e4a

# Comments
color09=#b7bfce
# Underline spellbad
color11=#f16c75
# Underline spellcap
color12=#f1fc79
# Cursor and tmux windows text
color14=#ffffff
# Selected text
color16=#e9b3fd
# Cursor color
color24=#f94dff

# Wallpaper for this colorscheme
wallpaper=""
