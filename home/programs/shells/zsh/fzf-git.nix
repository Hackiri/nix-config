# Git Integration with FZF
# Interactive git operations using fuzzy finder
# Commands: gff (files), gfb (branches), gft (tags), gfh (history), gfr (remotes),
#           gfs (stash), gfst (status), gfa (add), gfc (commit)
_: {
  programs.zsh.initContent = ''
    if command -v git &>/dev/null; then
      # Check if current directory is a git repository
      is_in_git_repo() {
        git rev-parse HEAD > /dev/null 2>&1
      }

      # Git File Status Browser — gff
      # Shows modified/untracked files with diff preview
      gff() {
        is_in_git_repo || return
        git -c color.status=always status --short |
        fzf-down -m --ansi --nth 2..,.. \
          --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1})' |
        cut -c4- | sed 's/.* -> //'
      }

      # Git Branch Browser — gfb
      # Shows local and remote branches with commit history preview
      gfb() {
        is_in_git_repo || return
        git branch -a --color=always | grep -v '/HEAD' | sort |
        fzf-down --ansi --multi --tac --preview-window right:70% \
          --preview 'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1)' |
        sed 's/^..//' | cut -d' ' -f1 |
        sed 's#^remotes/##'
      }

      # Git Tag Browser — gft
      # Lists all tags with their details in preview
      gft() {
        is_in_git_repo || return
        git tag --sort -version:refname |
        fzf-down --multi --preview-window right:70% \
          --preview 'git show --color=always {}'
      }

      # Git History Browser — gfh
      # Interactive commit history with diff preview
      # Use ctrl-s to toggle sort order
      gfh() {
        is_in_git_repo || return
        git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=always |
        fzf-down --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
          --header 'Press CTRL-S to toggle sort' \
          --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always' |
        grep -o "[a-f0-9]\{7,\}"
      }

      # Git Remote Browser — gfr
      # Lists remotes with their commit history
      gfr() {
        is_in_git_repo || return
        git remote -v | awk '{print $1 "\t" $2}' | uniq |
        fzf-down --tac \
          --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" {1}' |
        cut -d$'\t' -f1
      }

      # Git Stash Browser — gfs
      # Browse and view stashed changes
      gfs() {
        is_in_git_repo || return
        git stash list | fzf-down --reverse -d: --preview 'git show --color=always {1}' |
        cut -d: -f1
      }

      # Enhanced Git Status Browser — gfst
      # Interactive status view with detailed file information and actions
      gfst() {
        is_in_git_repo || return
        git status --short | fzf-down --ansi \
          --preview 'git diff --color=always {2}' \
          --header 'Press CTRL-A to add/unstage, CTRL-C to commit' \
          --bind 'ctrl-a:execute(git add {2} || git restore --staged {2})' \
          --bind 'ctrl-c:execute(git commit)' \
          --preview-window right:70%
      }

      # Interactive Git Add — gfa
      # Multi-select files to stage with preview
      gfa() {
        is_in_git_repo || return
        # Show both unstaged and untracked files
        git ls-files --modified --others --exclude-standard |
        fzf-down --ansi --multi \
          --preview 'git diff --color=always {} || bat --color=always {}' \
          --header 'Select files to stage (TAB to multi-select)' \
          --bind 'enter:execute(git add {})' \
          --preview-window right:70%
      }

      # Detailed Git Commit Browser — gfc
      # Interactive commit creation with template and preview
      gfc() {
        is_in_git_repo || return
        # Show staged files with their diffs
        local staged_files="$(git diff --cached --name-only)"
        if [ -z "$staged_files" ]; then
          echo "No files staged for commit"
          return 1
        fi

        # Create a temporary file for the commit message
        local temp_msg="$(mktemp)"
        trap "rm -f '$temp_msg'" EXIT INT TERM
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
        rm -f "$temp_msg"
        trap - EXIT INT TERM
      }
    fi
  '';
}
