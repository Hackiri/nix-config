# Git Integration with FZF
# Interactive git operations using fuzzy finder
# Keybindings: Ctrl+G followed by Ctrl+[key]
_: ''
  # Git Integration Helper Functions

  # Check if current directory is a git repository
  is_in_git_repo() {
    git rev-parse HEAD > /dev/null 2>&1
  }

  # Standard FZF configuration for git operations
  # Creates a dropdown with preview toggle (ctrl-/)
  fzf-down() {
    fzf --height 50% --min-height 20 --border --bind ctrl-/:toggle-preview "$@"
  }

  # Git File Status Browser (^g^f)
  # Shows modified/untracked files with diff preview
  _gf() {
    is_in_git_repo || return
    git -c color.status=always status --short |
    fzf-down -m --ansi --nth 2..,.. \
      --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1})' |
    cut -c4- | sed 's/.* -> //'
  }

  # Git Branch Browser (^g^b)
  # Shows local and remote branches with commit history preview
  _gb() {
    is_in_git_repo || return
    git branch -a --color=always | grep -v '/HEAD\s' | sort |
    fzf-down --ansi --multi --tac --preview-window right:70% \
      --preview 'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1)' |
    sed 's/^..//' | cut -d' ' -f1 |
    sed 's#^remotes/##'
  }

  # Git Tag Browser (^g^t)
  # Lists all tags with their details in preview
  _gt() {
    is_in_git_repo || return
    git tag --sort -version:refname |
    fzf-down --multi --preview-window right:70% \
      --preview 'git show --color=always {}'
  }

  # Git History Browser (^g^h)
  # Interactive commit history with diff preview
  # Use ctrl-s to toggle sort order
  _gh() {
    is_in_git_repo || return
    git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=always |
    fzf-down --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
      --header 'Press CTRL-S to toggle sort' \
      --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always' |
    grep -o "[a-f0-9]\{7,\}"
  }

  # Git Remote Browser (^g^r)
  # Lists remotes with their commit history
  _gr() {
    is_in_git_repo || return
    git remote -v | awk '{print $1 "\t" $2}' | uniq |
    fzf-down --tac \
      --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" {1}' |
    cut -d$'\t' -f1
  }

  # Git Stash Browser (^g^s)
  # Browse and view stashed changes
  _gs() {
    is_in_git_repo || return
    git stash list | fzf-down --reverse -d: --preview 'git show --color=always {1}' |
    cut -d: -f1
  }

  # Helper function to join multiple selected items
  # Used when multiple selections are made in FZF
  join-lines() {
    local item
    while read item; do
      echo -n "''${(q)item} "
    done
  }

  # Function to bind all git helper functions to keyboard shortcuts
  # Creates widgets and binds them to ctrl-g + ctrl-[key] combinations
  bind-git-helper() {
    local c
    for c in $@; do
      # Create widget function that calls the corresponding _g[key] function
      eval "fzf-g$c-widget() { local result=\$(_g$c | join-lines); zle reset-prompt; LBUFFER+=\$result }"
      # Register the widget with ZLE (Zsh Line Editor)
      eval "zle -N fzf-g$c-widget"
      # Bind widget to ctrl-g + ctrl-[key]
      eval "bindkey '^g^$c' fzf-g$c-widget"
    done
  }

  # Enhanced Git Status Browser (^g^st)
  # Interactive status view with detailed file information and actions
  _gst() {
    is_in_git_repo || return
    git status --short | fzf-down --ansi \
      --preview 'git diff --color=always {2}' \
      --header 'Press CTRL-A to add/unstage, CTRL-C to commit' \
      --bind 'ctrl-a:execute(git add {2} || git restore --staged {2})' \
      --bind 'ctrl-c:execute(git commit)' \
      --preview-window right:70%
  }

  # Interactive Git Add (^g^a)
  # Multi-select files to stage with preview
  _ga() {
    is_in_git_repo || return
    # Show both unstaged and untracked files
    git ls-files --modified --others --exclude-standard |
    fzf-down --ansi --multi \
      --preview 'git diff --color=always {} || bat --color=always {}' \
      --header 'Select files to stage (TAB to multi-select)' \
      --bind 'enter:execute(git add {})' \
      --preview-window right:70%
  }

  # Detailed Git Commit Browser (^g^c)
  # Interactive commit creation with template and preview
  _gc() {
    is_in_git_repo || return
    # Show staged files with their diffs
    local staged_files="$(git diff --cached --name-only)"
    if [ -z "$staged_files" ]; then
      echo "No files staged for commit"
      return 1
    fi

    # Create a temporary file for the commit message
    local temp_msg="$(mktemp)"
    echo "# Write your commit message (first line is the subject)
  #
  # Changes to be committed:
  #" > "$temp_msg"
    git diff --cached --name-status >> "$temp_msg"

    # Open commit message in preferred editor with preview
    "$EDITOR" "$temp_msg" && {
      # Remove comments and empty lines
      local commit_msg="$(grep -v '^#' "$temp_msg" | sed '/^$/d')"
      if [ -n "$commit_msg" ]; then
        git commit -F "$temp_msg"
      fi
    }
    rm "$temp_msg"
  }

  # Bind git helper functions
  # f=files, b=branches, t=tags, r=remotes, h=history, s=stash, st=status, a=add, c=commit
  bind-git-helper f b t r h s st a c
  unset -f bind-git-helper
''
