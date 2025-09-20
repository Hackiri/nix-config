# Icons configuration
ICON_USER="󰀄"           # User icon
ICON_ROOT=""           # Root/admin icon
ICON_DIRECTORY="󰉋"      # Directory icon
ICON_TIME="󰥔"           # Clock icon
ICON_CALENDAR="󰃭"       # Calendar icon
ICON_NODE="󰎙"           # Node.js icon
ICON_PYTHON=""         # Python icon
ICON_RUBY=""           # Ruby icon
ICON_RUST=""          # Rust icon
ICON_GO=""            # Go icon
ICON_JAVA=""          # Java icon
ICON_GIT=""           # Git icon
ICON_GITHUB=""         # GitHub icon
ICON_GITLAB=""         # GitLab icon
ICON_BITBUCKET=""      # Bitbucket icon
ICON_AWS=""           # AWS icon
ICON_DOCKER=""         # Docker icon
ICON_KUBERNETES="󱃾"    # Kubernetes icon
ICON_VIM=""           # Vim icon
ICON_TERMINAL=""       # Terminal icon
ICON_ZSH=""           # Zsh icon
ICON_ERROR=""         # Error icon
ICON_SUCCESS="󰄬"       # Success icon
ICON_WARNING=""       # Warning icon
ICON_INFO="󰋽"          # Info icon
ICON_BRANCH=""        # Branch icon
ICON_RAM="󰍛"           # RAM icon
ICON_CPU=""           # CPU icon
ICON_NETWORK_UP="󰁝"    # Network upload icon
ICON_NETWORK_DOWN="󰁅"  # Network download icon

function theme_precmd {
  local TERMWIDTH=$(( COLUMNS - ${ZLE_RPROMPT_INDENT:-1} ))

  PR_FILLBAR=""
  PR_PWDLEN=""

  local promptsize=${#${(%):---(%n@%m:%l)---()--}}
  local rubypromptsize=${#${(%)$(ruby_prompt_info)}}
  local pwdsize=${#${(%):-%~}}
  local venvpromptsize=$((${#$(virtualenv_prompt_info)}))

  # Truncate the path if it's too long.
  if (( promptsize + rubypromptsize + pwdsize + venvpromptsize > TERMWIDTH )); then
    (( PR_PWDLEN = TERMWIDTH - promptsize ))
  elif [[ "${langinfo[CODESET]}" = UTF-8 ]]; then
    PR_FILLBAR="\${(l:$(( TERMWIDTH - (promptsize + rubypromptsize + pwdsize + venvpromptsize ) ))::${PR_HBAR}:)}"
  else
    PR_FILLBAR="${PR_SHIFT_IN}\${(l:$(( TERMWIDTH - (promptsize + rubypromptsize + pwdsize + venvpromptsize ) ))::${altchar[q]:--}:)}${PR_SHIFT_OUT}"
  fi
}

function theme_preexec {
  setopt local_options extended_glob
  if [[ "$TERM" = "screen" ]]; then
    local CMD=${1[(wr)^(*=*|sudo|-*)]}
    echo -n "\ek$CMD\e\\"
  fi
}

function preexec() {
  timer=$(($(date +%s%0N)/1000000))
}

function precmd() {
  if [ $timer ]; then
    now=$(($(date +%s%0N)/1000000))
    elapsed=$(($now-$timer))
    
    if [ $elapsed -gt 1000 ]; then
      timer_show="${elapsed}ms"
    else
      timer_show="${elapsed}ms"
    fi
    unset timer
  fi
}

autoload -U add-zsh-hook
add-zsh-hook precmd  theme_precmd
add-zsh-hook preexec theme_preexec
add-zsh-hook preexec preexec
add-zsh-hook precmd precmd

# Set the prompt

# Need this so the prompt will work.
setopt prompt_subst

# See if we can use colors.
autoload zsh/terminfo
for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE GREY; do
  typeset -g PR_$color="%{$terminfo[bold]$fg[${(L)color}]%}"
  typeset -g PR_LIGHT_$color="%{$fg[${(L)color}]%}"
done
PR_NO_COLOUR="%{$terminfo[sgr0]%}"

# Language version display functions
function node_version_prompt() {
  if [ -f package.json ] || [ -d node_modules ]; then
    echo "%{$fg[green]%}${ICON_NODE} $(node -v)%{$reset_color%}"
  fi
}

function python_version_prompt() {
  if [ -f requirements.txt ] || [ -f setup.py ] || [ -f Pipfile ] || [ -f pyproject.toml ]; then
    echo "%{$fg[blue]%}${ICON_PYTHON} $(python3 --version 2>&1 | cut -d' ' -f2)%{$reset_color%}"
  fi
}

function ruby_version_prompt() {
  if [ -f Gemfile ] || [ -f .ruby-version ]; then
    echo "%{$fg[red]%}${ICON_RUBY} $(ruby --version | cut -d' ' -f2)%{$reset_color%}"
  fi
}

function rust_version_prompt() {
  if [ -f Cargo.toml ]; then
    echo "%{$fg[yellow]%}${ICON_RUST} $(rustc --version | cut -d' ' -f2)%{$reset_color%}"
  fi
}

# System status functions
function system_status() {
  local cpu_usage=$(ps -A -o %cpu | awk '{s+=$1} END {print s}' | awk '{printf "%.1f", $1}')
  local memory_usage=$(ps -A -o %mem | awk '{s+=$1} END {print s}' | awk '{printf "%.1f", $1}')
  echo "%{$fg[cyan]%}${ICON_CPU} ${cpu_usage}% ${ICON_RAM} ${memory_usage}%%{$reset_color%}"
}

# Enhanced battery status with icons
function battery_status() {
  if command -v pmset &> /dev/null; then
    battery_info=$(pmset -g batt)
    if [[ $battery_info =~ ([0-9]+)%.*'Battery Power' ]]; then
      battery_percent="${match[1]}"
      if [ $battery_percent -gt 75 ]; then
        echo "%{$fg[green]%} ${battery_percent}%%%{$reset_color%}"
      elif [ $battery_percent -gt 25 ]; then
        echo "%{$fg[yellow]%} ${battery_percent}%%%{$reset_color%}"
      else
        echo "%{$fg[red]%} ${battery_percent}%%%{$reset_color%}"
      fi
    elif [[ $battery_info =~ ([0-9]+)%.*'AC Power' ]]; then
      battery_percent="${match[1]}"
      echo "%{$fg[cyan]%} ${battery_percent}%%%{$reset_color%}"
    fi
  fi
}

# Git status with enhanced icons
ZSH_THEME_GIT_PROMPT_PREFIX=" ${ICON_GIT} %{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%} ${ICON_WARNING}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%} ${ICON_SUCCESS}"
ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[green]%} "
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[yellow]%} "
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%} "
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[magenta]%} "
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[yellow]%} "
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[cyan]%} "
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[blue]%}${ICON_NETWORK_UP}"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg[red]%}${ICON_NETWORK_DOWN}"

# Use extended characters to look nicer if supported.
if [[ "${langinfo[CODESET]}" = UTF-8 ]]; then
  PR_SET_CHARSET=""
  PR_HBAR="─"
  PR_ULCORNER="┌"
  PR_LLCORNER="└"
  PR_LRCORNER="┘"
  PR_URCORNER="┐"
else
  typeset -g -A altchar
  set -A altchar ${(s..)terminfo[acsc]}
  # Some stuff to help us draw nice lines
  PR_SET_CHARSET="%{$terminfo[enacs]%}"
  PR_SHIFT_IN="%{$terminfo[smacs]%}"
  PR_SHIFT_OUT="%{$terminfo[rmacs]%}"
  PR_HBAR="${PR_SHIFT_IN}${altchar[q]:--}${PR_SHIFT_OUT}"
  PR_ULCORNER="${PR_SHIFT_IN}${altchar[l]:--}${PR_SHIFT_OUT}"
  PR_LLCORNER="${PR_SHIFT_IN}${altchar[m]:--}${PR_SHIFT_OUT}"
  PR_LRCORNER="${PR_SHIFT_IN}${altchar[j]:--}${PR_SHIFT_OUT}"
  PR_URCORNER="${PR_SHIFT_IN}${altchar[k]:--}${PR_SHIFT_OUT}"
fi

# Decide if we need to set titlebar text.
case $TERM in
  xterm*)
    PR_TITLEBAR=$'%{\e]0;%(!.-=*[ROOT]*=- | .)%n@%m:%~ | ${COLUMNS}x${LINES} | %y\a%}'
    ;;
  screen)
    PR_TITLEBAR=$'%{\e_screen \005 (\005t) | %(!.-=[ROOT]=- | .)%n@%m:%~ | ${COLUMNS}x${LINES} | %y\e\\%}'
    ;;
  *)
    PR_TITLEBAR=""
    ;;
esac

# Decide whether to set a screen title
if [[ "$TERM" = "screen" ]]; then
  PR_STITLE=$'%{\ekzsh\e\\%}'
else
  PR_STITLE=""
fi

# Finally, the prompt.
PROMPT='${PR_SET_CHARSET}${PR_STITLE}${(e)PR_TITLEBAR}\
${PR_CYAN}${PR_ULCORNER}${PR_HBAR}${PR_GREY}(\
${ICON_DIRECTORY} ${PR_GREEN}%${PR_PWDLEN}<...<%~%<<\
${PR_GREY})$(virtualenv_prompt_info)$(node_version_prompt)$(python_version_prompt)$(ruby_version_prompt)$(rust_version_prompt)${PR_CYAN}${PR_HBAR}${PR_HBAR}${(e)PR_FILLBAR}${PR_HBAR}${PR_GREY}(\
${PR_CYAN}%(!.${ICON_ROOT}.${ICON_USER})%(!.%SROOT%s.%n)${PR_GREY}@${PR_GREEN}%m${ICON_TERMINAL}\
${PR_GREY})${PR_CYAN}${PR_HBAR}${PR_URCORNER}\

${PR_CYAN}${PR_LLCORNER}${PR_BLUE}${PR_HBAR}(\
${ICON_TIME} ${PR_YELLOW}%D{%H:%M:%S}\
${PR_LIGHT_BLUE}%{$reset_color%}$(git_prompt_info)$(git_prompt_status)${PR_BLUE})${PR_CYAN}${PR_HBAR}\
${PR_HBAR}\
>${PR_NO_COLOUR} '

# Update right prompt with system status and icons
return_code="%(?..%{$fg[red]%}${ICON_ERROR} %? ${ICON_WARNING} %{$reset_color%})"
RPROMPT=' $return_code${timer_show:+" ${ICON_TIME} $timer_show "}$(system_status) $(battery_status)${PR_CYAN}${PR_HBAR}${PR_BLUE}${PR_HBAR}\
(${ICON_CALENDAR} ${PR_YELLOW}%D{%a,%b%d}${PR_BLUE})${PR_HBAR}${PR_CYAN}${PR_LRCORNER}${PR_NO_COLOUR}'

PS2='${PR_CYAN}${PR_HBAR}\
${PR_BLUE}${PR_HBAR}(\
${PR_LIGHT_GREEN}%_${PR_BLUE})${PR_HBAR}\
${PR_CYAN}${PR_HBAR}${PR_NO_COLOUR} '
