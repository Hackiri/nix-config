# Claude Code Integration with FZF
# Interactive search through Claude Code chat history
# Keybindings: Ctrl+C followed by Ctrl+[key]
_: ''
  # Claude Code directory
  CLAUDE_DIR="$HOME/.claude"

  # Standard FZF configuration for Claude operations
  fzf-claude() {
    fzf --height 70% --min-height 30 --border --bind ctrl-/:toggle-preview "$@"
  }

  # Search Global History (^c^h)
  # Browse all prompts across all projects
  _claude_history() {
    local history_file="$CLAUDE_DIR/history.jsonl"
    [[ -f "$history_file" ]] || { echo "No Claude history found"; return 1; }

    jq -r '[.timestamp, .project, .display] | @tsv' "$history_file" 2>/dev/null |
    while IFS=$'\t' read -r ts project display; do
      # Convert timestamp to readable date
      local date=$(date -r $((ts / 1000)) "+%Y-%m-%d %H:%M" 2>/dev/null || echo "unknown")
      local proj=$(basename "$project" 2>/dev/null || echo "unknown")
      printf "%s | %-20s | %s\n" "$date" "$proj" "$display"
    done |
    fzf-claude --ansi --tac \
      --header 'Claude Code History - Enter to copy prompt' \
      --preview-window right:50%:wrap \
      --preview 'echo {} | cut -d"|" -f3-' |
    cut -d'|' -f3- | sed 's/^ *//'
  }

  # Search Sessions for Current Project (^c^s)
  # Browse sessions in current project directory
  _claude_sessions() {
    local project_dir="''${PWD//\//-}"
    project_dir="''${project_dir#-}"
    local sessions_dir="$CLAUDE_DIR/projects/-$project_dir"

    [[ -d "$sessions_dir" ]] || { echo "No Claude sessions for this project"; return 1; }

    # List session files with their first user message
    for f in "$sessions_dir"/*.jsonl; do
      [[ -f "$f" ]] || continue
      [[ $(basename "$f") == agent-* ]] && continue  # Skip agent files

      local session_id=$(basename "$f" .jsonl)
      local date=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$f" 2>/dev/null || stat -c "%y" "$f" 2>/dev/null | cut -d' ' -f1,2)
      local first_msg=$(jq -r 'select(.type == "user") | .content' "$f" 2>/dev/null | head -1 | cut -c1-80)

      [[ -n "$first_msg" ]] && printf "%s | %s | %s\n" "$date" "''${session_id:0:8}" "$first_msg"
    done |
    sort -r |
    fzf-claude --ansi \
      --header 'Claude Sessions (Current Project) - Enter to view' \
      --preview-window right:60%:wrap \
      --preview '
        session_id=$(echo {} | cut -d"|" -f2 | tr -d " ")
        project_dir=$(echo "$PWD" | sed "s|/|-|g" | sed "s|^-||")
        file="$HOME/.claude/projects/-$project_dir/''${session_id}"*.jsonl
        if [[ -f $file ]]; then
          jq -r "select(.type == \"user\" or .type == \"assistant\") | \"\n[\(.type | ascii_upcase)]:\n\(.content)\"" $file 2>/dev/null | head -100
        fi
      '
  }

  # Search All Conversations (^c^a)
  # Full-text search across all Claude conversations
  _claude_search() {
    local query="$1"
    [[ -z "$query" ]] && read -p "Search: " query
    [[ -z "$query" ]] && return 1

    # Search across all session files
    rg -l "$query" "$CLAUDE_DIR/projects" --glob "*.jsonl" --glob "!agent-*.jsonl" 2>/dev/null |
    while read -r f; do
      local session_id=$(basename "$f" .jsonl)
      local project=$(dirname "$f" | xargs basename | sed 's/^-//' | tr '-' '/')
      local matches=$(rg -c "$query" "$f" 2>/dev/null)
      printf "%s | %s | %s matches\n" "''${session_id:0:8}" "$project" "$matches"
    done |
    fzf-claude --ansi \
      --header "Search results for: $query" \
      --preview-window right:60%:wrap \
      --preview "
        session_id=\$(echo {} | cut -d'|' -f1 | tr -d ' ')
        file=\$(find \"$CLAUDE_DIR/projects\" -name \"''${session_id}*.jsonl\" -type f 2>/dev/null | head -1)
        if [[ -f \"\$file\" ]]; then
          rg --color=always -C 2 \"$query\" \"\$file\" 2>/dev/null | head -50
        fi
      "
  }

  # Browse Projects (^c^p)
  # List all projects with Claude conversations
  _claude_projects() {
    for d in "$CLAUDE_DIR/projects"/-*; do
      [[ -d "$d" ]] || continue
      local project=$(basename "$d" | sed 's/^-//' | tr '-' '/')
      local count=$(find "$d" -name "*.jsonl" ! -name "agent-*.jsonl" -type f 2>/dev/null | wc -l | tr -d ' ')
      local last=$(stat -f "%Sm" -t "%Y-%m-%d" "$d" 2>/dev/null || stat -c "%y" "$d" 2>/dev/null | cut -d' ' -f1)
      printf "%s | %3s sessions | %s\n" "$last" "$count" "$project"
    done |
    sort -r |
    fzf-claude --ansi \
      --header 'Claude Projects - Enter to browse sessions' \
      --preview-window right:50%:wrap \
      --preview '
        project=$(echo {} | cut -d"|" -f3- | tr -d " " | tr "/" "-")
        dir="$HOME/.claude/projects/-$project"
        if [[ -d "$dir" ]]; then
          echo "Sessions:"
          for f in "$dir"/*.jsonl; do
            [[ $(basename "$f") == agent-* ]] && continue
            first=$(jq -r "select(.type == \"user\") | .content" "$f" 2>/dev/null | head -1 | cut -c1-60)
            [[ -n "$first" ]] && echo "  - $first"
          done | head -20
        fi
      '
  }

  # Recent Conversations (^c^r)
  # Quick access to recent Claude conversations
  _claude_recent() {
    find "$CLAUDE_DIR/projects" -name "*.jsonl" ! -name "agent-*.jsonl" -type f -mtime -7 2>/dev/null |
    while read -r f; do
      local session_id=$(basename "$f" .jsonl)
      local project=$(dirname "$f" | xargs basename | sed 's/^-//' | tr '-' '/' | cut -c1-30)
      local date=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$f" 2>/dev/null || stat -c "%y" "$f" 2>/dev/null | cut -d' ' -f1,2)
      local first_msg=$(jq -r 'select(.type == "user") | .content' "$f" 2>/dev/null | head -1 | cut -c1-50)
      [[ -n "$first_msg" ]] && printf "%s | %-30s | %s\n" "$date" "$project" "$first_msg"
    done |
    sort -r |
    head -50 |
    fzf-claude --ansi \
      --header 'Recent Claude Conversations (Last 7 Days)' \
      --preview-window right:60%:wrap \
      --preview '
        project=$(echo {} | cut -d"|" -f2 | tr -d " " | tr "/" "-")
        prompt=$(echo {} | cut -d"|" -f3-)
        dir="$HOME/.claude/projects/-$project"
        if [[ -d "$dir" ]]; then
          file=$(ls -t "$dir"/*.jsonl 2>/dev/null | head -1)
          if [[ -f "$file" ]]; then
            jq -r "select(.type == \"user\" or .type == \"assistant\") | \"\n[\(.type | ascii_upcase)]:\n\(.content)\"" "$file" 2>/dev/null | head -80
          fi
        fi
      '
  }

  # Helper function to join multiple selected items
  join-claude-lines() {
    local item
    while read item; do
      echo -n "''${(q)item} "
    done
  }

  # Bind Claude helper functions to keyboard shortcuts
  bind-claude-helper() {
    local c
    for c in $@; do
      eval "fzf-claude-$c-widget() { local result=\$(_claude_$c | join-claude-lines); zle reset-prompt; LBUFFER+=\$result }"
      eval "zle -N fzf-claude-$c-widget"
      eval "bindkey '^c^$c' fzf-claude-$c-widget"
    done
  }

  # Bind shortcuts:
  # ^c^h = history (global prompts)
  # ^c^s = sessions (current project)
  # ^c^p = projects (all projects)
  # ^c^r = recent (last 7 days)
  bind-claude-helper h s p r
  unset -f bind-claude-helper

  # Alias for full-text search (not bound to key due to input requirement)
  alias claude-search='_claude_search'
''
