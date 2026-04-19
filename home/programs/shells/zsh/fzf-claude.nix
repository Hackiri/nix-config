# Claude Code Integration with FZF
# Interactive search through Claude Code chat history
#
# Commands:
#   clc            — continue most recent session in current project
#   cls            — browse sessions for current project
#   clr            — recent conversations (last 7 days)
#   clp            — browse all projects, drill into sessions
#   clh            — global prompt history
#   claude-search  — full-text search across all conversations
#
# Keybindings in FZF:
#   Enter   — resume session
#   Ctrl+F  — fork-resume (new session from that point)
#   Ctrl+E  — export conversation to markdown
#   Ctrl+D  — delete session (with confirmation)
#   Ctrl+Y  — copy session ID to clipboard
#   Ctrl+/  — toggle preview
{
  config,
  lib,
  ...
}: {
  config = lib.mkIf (config.profiles.development.shells.enable or true) {
    programs.zsh.initContent = ''
      if command -v claude &>/dev/null; then
        CLAUDE_DIR="$HOME/.claude"

        # --- Shared jq filters ---

        _CLAUDE_JQ_FIRST_MSG='
          select(.type == "user") |
          if (.message.content | type) == "string" then .message.content
          elif (.message.content | type) == "array" then
            [.message.content[] | select(.type == "text") | .text] | join(" ")
          else empty end
        '

        # === Commands ===

        # Continue most recent session — clc
        clc() {
          claude --continue
        }

        # Prompt History — clh
        # In a project dir: shows only that project's prompts
        # In $HOME or elsewhere: shows all prompts
        clh() {
          local history_file="$CLAUDE_DIR/history.jsonl"
          [[ -f "$history_file" ]] || { echo "No Claude history found"; return 1; }

          local jq_filter header_suffix
          local stripped="''${PWD#/}"
          local project_key="''${stripped//\//-}"
          if [[ "$PWD" != "$HOME" ]] && [[ -d "$CLAUDE_DIR/projects/-$project_key" ]]; then
            jq_filter="select(.project == \"$PWD\")"
            header_suffix=" ($(basename "$PWD"))"
          else
            jq_filter="."
            header_suffix=" (all projects)"
          fi

          jq -r "$jq_filter | [.timestamp, .project, .sessionId, .display] | @tsv" "$history_file" 2>/dev/null |
          while IFS=$'\t' read -r ts project session_id display; do
            local date=$(date -r $((ts / 1000)) "+%Y-%m-%d %H:%M" 2>/dev/null || echo "unknown")
            local proj=$(basename "$project" 2>/dev/null || echo "unknown")
            printf "%s | %-20s | %s | %s\n" "$date" "$proj" "$session_id" "$display"
          done |
          fzf-down --ansi --tac \
            --header "History$header_suffix — Enter: resume | ^F: fork | ^Y: copy ID | ^A: all" \
            --preview-window right:50%:wrap \
            --preview 'echo {} | cut -d"|" -f4-' \
            --bind 'ctrl-y:execute-silent(echo {} | cut -d"|" -f3 | tr -d " " | pbcopy)+close' \
            --bind 'ctrl-f:become(echo {} | cut -d"|" -f3 | tr -d " " | xargs -I{} claude --resume {} --fork-session)' |
          { read -r line && local sid=$(echo "$line" | cut -d'|' -f3 | tr -d ' ') && [[ -n "$sid" ]] && claude --resume "$sid"; }
        }

        # Sessions for Current Project — cls
        cls() {
          local project_dir="''${PWD//\//-}"
          project_dir="''${project_dir#-}"
          local sessions_dir="$CLAUDE_DIR/projects/-$project_dir"

          [[ -d "$sessions_dir" ]] || { echo "No Claude sessions for this project"; return 1; }

          for f in "$sessions_dir"/*.jsonl; do
            [[ -f "$f" ]] || continue
            [[ $(basename "$f") == agent-* ]] && continue

            local session_id=$(basename "$f" .jsonl)
            local date=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$f" 2>/dev/null || stat -c "%y" "$f" 2>/dev/null | cut -d' ' -f1,2)
            local first_msg=$(jq -r "$_CLAUDE_JQ_FIRST_MSG" "$f" 2>/dev/null | head -1 | cut -c1-80)

            printf "%s | %s | %s\n" "$date" "$session_id" "$first_msg"
          done |
          sort -r |
          fzf-down --ansi \
            --header 'Sessions — Enter: resume | ^F: fork | ^E: export | ^D: delete | ^Y: copy ID' \
            --preview-window right:60%:wrap \
            --bind 'ctrl-y:execute-silent(echo {} | cut -d"|" -f2 | tr -d " " | pbcopy)+close' \
            --bind 'ctrl-f:become(echo {} | cut -d"|" -f2 | tr -d " " | xargs -I{} claude --resume {} --fork-session)' \
            --bind "ctrl-e:execute(sid=\$(echo {} | cut -d'|' -f2 | tr -d ' '); f=\$(find \$HOME/.claude/projects -name \"\$sid.jsonl\" -type f 2>/dev/null | head -1); if [[ -n \"\$f\" ]]; then out=\"\$HOME/Desktop/claude-\$sid.md\"; jq -r 'select(.type == \"user\" or .type == \"assistant\") | (if (.message.content | type) == \"string\" then .message.content elif (.message.content | type) == \"array\" then ([.message.content[] | select(.type == \"text\") | .text] | join(\"\\n\")) else \"\" end) as \$text | select(\$text != \"\") | \"## \" + (.type | ascii_upcase) + \"\\n\\n\" + \$text + \"\\n\"' \"\$f\" > \"\$out\" 2>/dev/null && echo \"Exported to \$out\" || echo \"Export failed\"; read -k1; fi)" \
            --bind "ctrl-d:execute(sid=\$(echo {} | cut -d'|' -f2 | tr -d ' '); f=\$(find \$HOME/.claude/projects -name \"\$sid.jsonl\" -type f 2>/dev/null | head -1); if [[ -n \"\$f\" ]]; then echo \"Delete \$f?\"; read -q '?[y/N] ' && rm \"\$f\" && echo ' Deleted' || echo ' Cancelled'; read -k1; fi)" \
            --preview '
              session_id=$(echo {} | cut -d"|" -f2 | tr -d " ")
              project_dir=$(echo "$PWD" | sed "s|/|-|g" | sed "s|^-||")
              file="$HOME/.claude/projects/-$project_dir/''${session_id}.jsonl"
              if [[ -f "$file" ]]; then
                jq -rs '"'"'
                  {
                    total: length,
                    user: [.[] | select(.type == "user")] | length,
                    assistant: [.[] | select(.type == "assistant")] | length,
                    first_ts: (map(select(.timestamp)) | first | .timestamp // ""),
                    last_ts: (map(select(.timestamp)) | last | .timestamp // ""),
                    tools: [.[] | select(.type == "assistant") | .message.content[]? | select(.type == "tool_use") | .name] | group_by(.) | map({name: .[0], count: length}) | sort_by(-.count) | .[:5]
                  } |
                  "━━━ Session Stats ━━━\nDuration:  \(.first_ts[:16] | gsub("T";" ")) → \(.last_ts[11:16])\nMessages:  \(.user) user, \(.assistant) assistant (\(.total) total)" +
                  if (.tools | length) > 0 then
                    "\nTools:     " + ([.tools[] | "\(.name)(\(.count))"] | join(", "))
                  else ""
                  end + "\n━━━━━━━━━━━━━━━━━━━━\n"
                '"'"' "$file" 2>/dev/null
                jq -r '"'"'
                  select(.type == "user" or .type == "assistant") |
                  (if (.message.content | type) == "string" then
                    .message.content
                  elif (.message.content | type) == "array" then
                    ([.message.content[] | select(.type == "text") | .text] | join("\n"))
                  else ""
                  end) as $text |
                  select($text != "") |
                  "\n[\(.type | ascii_upcase)]:\n" + $text
                '"'"' "$file" 2>/dev/null | head -80
              fi
            ' |
          { read -r line && local sid=$(echo "$line" | cut -d'|' -f2 | tr -d ' ') && [[ -n "$sid" ]] && claude --resume "$sid"; }
        }

        # Search All Conversations — claude-search
        claude-search() {
          local query="$1"
          [[ -z "$query" ]] && read -p "Search: " query
          [[ -z "$query" ]] && return 1

          rg -l "$query" "$CLAUDE_DIR/projects" --glob "*.jsonl" --glob "!agent-*.jsonl" 2>/dev/null |
          while read -r f; do
            local session_id=$(basename "$f" .jsonl)
            local project=$(dirname "$f" | xargs basename | sed 's/^-//' | tr '-' '/')
            local matches=$(rg -c "$query" "$f" 2>/dev/null)
            printf "%s | %s | %s matches\n" "$session_id" "$project" "$matches"
          done |
          fzf-down --ansi \
            --header "Search: $query — Enter: resume | ^F: fork | ^Y: copy ID" \
            --preview-window right:60%:wrap \
            --bind 'ctrl-y:execute-silent(echo {} | cut -d"|" -f1 | tr -d " " | pbcopy)+close' \
            --bind 'ctrl-f:become(echo {} | cut -d"|" -f1 | tr -d " " | xargs -I{} claude --resume {} --fork-session)' \
            --preview "
              session_id=\$(echo {} | cut -d'|' -f1 | tr -d ' ')
              file=\$(find \"$CLAUDE_DIR/projects\" -name \"''${session_id}.jsonl\" -type f 2>/dev/null | head -1)
              if [[ -f \"\$file\" ]]; then
                rg --color=always -C 2 \"$query\" \"\$file\" 2>/dev/null | head -50
              fi
            " |
          { read -r line && local sid=$(echo "$line" | cut -d'|' -f1 | tr -d ' ') && [[ -n "$sid" ]] && claude --resume "$sid"; }
        }

        # Browse Projects — clp
        clp() {
          local selected_project
          selected_project=$(
            for d in "$CLAUDE_DIR/projects"/-*; do
              [[ -d "$d" ]] || continue
              local project=$(basename "$d" | sed 's/^-//' | tr '-' '/')
              local count=$(find "$d" -name "*.jsonl" ! -name "agent-*.jsonl" -type f 2>/dev/null | wc -l | tr -d ' ')
              local last=$(stat -f "%Sm" -t "%Y-%m-%d" "$d" 2>/dev/null || stat -c "%y" "$d" 2>/dev/null | cut -d' ' -f1)
              printf "%s | %3s sessions | %s\n" "$last" "$count" "$project"
            done |
            sort -r |
            fzf-down --ansi \
              --header 'Projects — Enter to browse sessions' \
              --preview-window right:50%:wrap \
              --preview '
                project=$(echo {} | cut -d"|" -f3- | tr -d " " | tr "/" "-")
                dir="$HOME/.claude/projects/-$project"
                if [[ -d "$dir" ]]; then
                  echo "Sessions:"
                  for f in "$dir"/*.jsonl; do
                    [[ $(basename "$f") == agent-* ]] && continue
                    first=$(jq -r "select(.type == \"user\") | if (.message.content | type) == \"string\" then .message.content elif (.message.content | type) == \"array\" then [.message.content[] | select(.type == \"text\") | .text] | join(\" \") else empty end" "$f" 2>/dev/null | head -1 | cut -c1-60)
                    [[ -n "$first" ]] && echo "  - $first"
                  done | head -20
                fi
              '
          )

          [[ -z "$selected_project" ]] && return 0

          # Drill into selected project's sessions
          local project_path=$(echo "$selected_project" | cut -d'|' -f3- | tr -d ' ' | tr '/' '-')
          local sessions_dir="$CLAUDE_DIR/projects/-$project_path"
          [[ -d "$sessions_dir" ]] || { echo "Project directory not found"; return 1; }

          for f in "$sessions_dir"/*.jsonl; do
            [[ -f "$f" ]] || continue
            [[ $(basename "$f") == agent-* ]] && continue

            local session_id=$(basename "$f" .jsonl)
            local date=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$f" 2>/dev/null || stat -c "%y" "$f" 2>/dev/null | cut -d' ' -f1,2)
            local first_msg=$(jq -r "$_CLAUDE_JQ_FIRST_MSG" "$f" 2>/dev/null | head -1 | cut -c1-80)

            printf "%s | %s | %s\n" "$date" "$session_id" "$first_msg"
          done |
          sort -r |
          fzf-down --ansi \
            --header "Sessions — Enter: resume | ^F: fork | ^E: export | ^D: delete | ^Y: copy ID" \
            --preview-window right:60%:wrap \
            --bind 'ctrl-y:execute-silent(echo {} | cut -d"|" -f2 | tr -d " " | pbcopy)+close' \
            --bind 'ctrl-f:become(echo {} | cut -d"|" -f2 | tr -d " " | xargs -I{} claude --resume {} --fork-session)' \
            --bind "ctrl-e:execute(sid=\$(echo {} | cut -d'|' -f2 | tr -d ' '); f=\$(find \$HOME/.claude/projects -name \"\$sid.jsonl\" -type f 2>/dev/null | head -1); if [[ -n \"\$f\" ]]; then out=\"\$HOME/Desktop/claude-\$sid.md\"; jq -r 'select(.type == \"user\" or .type == \"assistant\") | (if (.message.content | type) == \"string\" then .message.content elif (.message.content | type) == \"array\" then ([.message.content[] | select(.type == \"text\") | .text] | join(\"\\n\")) else \"\" end) as \$text | select(\$text != \"\") | \"## \" + (.type | ascii_upcase) + \"\\n\\n\" + \$text + \"\\n\"' \"\$f\" > \"\$out\" 2>/dev/null && echo \"Exported to \$out\" || echo \"Export failed\"; read -k1; fi)" \
            --bind "ctrl-d:execute(sid=\$(echo {} | cut -d'|' -f2 | tr -d ' '); f=\$(find \$HOME/.claude/projects -name \"\$sid.jsonl\" -type f 2>/dev/null | head -1); if [[ -n \"\$f\" ]]; then echo \"Delete \$f?\"; read -q '?[y/N] ' && rm \"\$f\" && echo ' Deleted' || echo ' Cancelled'; read -k1; fi)" \
            --preview '
              session_id=$(echo {} | cut -d"|" -f2 | tr -d " ")
              file="'"$sessions_dir"'/''${session_id}.jsonl"
              if [[ -f "$file" ]]; then
                jq -rs '"'"'
                  {
                    total: length,
                    user: [.[] | select(.type == "user")] | length,
                    assistant: [.[] | select(.type == "assistant")] | length,
                    first_ts: (map(select(.timestamp)) | first | .timestamp // ""),
                    last_ts: (map(select(.timestamp)) | last | .timestamp // ""),
                    tools: [.[] | select(.type == "assistant") | .message.content[]? | select(.type == "tool_use") | .name] | group_by(.) | map({name: .[0], count: length}) | sort_by(-.count) | .[:5]
                  } |
                  "━━━ Session Stats ━━━\nDuration:  \(.first_ts[:16] | gsub("T";" ")) → \(.last_ts[11:16])\nMessages:  \(.user) user, \(.assistant) assistant (\(.total) total)" +
                  if (.tools | length) > 0 then
                    "\nTools:     " + ([.tools[] | "\(.name)(\(.count))"] | join(", "))
                  else ""
                  end + "\n━━━━━━━━━━━━━━━━━━━━\n"
                '"'"' "$file" 2>/dev/null
                jq -r '"'"'
                  select(.type == "user" or .type == "assistant") |
                  (if (.message.content | type) == "string" then
                    .message.content
                  elif (.message.content | type) == "array" then
                    ([.message.content[] | select(.type == "text") | .text] | join("\n"))
                  else ""
                  end) as $text |
                  select($text != "") |
                  "\n[\(.type | ascii_upcase)]:\n" + $text
                '"'"' "$file" 2>/dev/null | head -80
              fi
            ' |
          { read -r line && local sid=$(echo "$line" | cut -d'|' -f2 | tr -d ' ') && [[ -n "$sid" ]] && claude --resume "$sid"; }
        }

        # Recent Conversations — clr
        clr() {
          find "$CLAUDE_DIR/projects" -name "*.jsonl" ! -name "agent-*.jsonl" -type f -mtime -7 2>/dev/null |
          while read -r f; do
            local session_id=$(basename "$f" .jsonl)
            local project=$(dirname "$f" | xargs basename | sed 's/^-//' | tr '-' '/' | cut -c1-30)
            local date=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$f" 2>/dev/null || stat -c "%y" "$f" 2>/dev/null | cut -d' ' -f1,2)
            local first_msg=$(jq -r "$_CLAUDE_JQ_FIRST_MSG" "$f" 2>/dev/null | head -1 | cut -c1-50)
            printf "%s | %-30s | %s | %s\n" "$date" "$project" "$session_id" "$first_msg"
          done |
          sort -r |
          head -50 |
          fzf-down --ansi \
            --header 'Recent (7 days) — Enter: resume | ^F: fork | ^E: export | ^D: delete | ^Y: copy ID' \
            --preview-window right:60%:wrap \
            --bind 'ctrl-y:execute-silent(echo {} | cut -d"|" -f3 | tr -d " " | pbcopy)+close' \
            --bind 'ctrl-f:become(echo {} | cut -d"|" -f3 | tr -d " " | xargs -I{} claude --resume {} --fork-session)' \
            --bind "ctrl-e:execute(sid=\$(echo {} | cut -d'|' -f3 | tr -d ' '); f=\$(find \$HOME/.claude/projects -name \"\$sid.jsonl\" -type f 2>/dev/null | head -1); if [[ -n \"\$f\" ]]; then out=\"\$HOME/Desktop/claude-\$sid.md\"; jq -r 'select(.type == \"user\" or .type == \"assistant\") | (if (.message.content | type) == \"string\" then .message.content elif (.message.content | type) == \"array\" then ([.message.content[] | select(.type == \"text\") | .text] | join(\"\\n\")) else \"\" end) as \$text | select(\$text != \"\") | \"## \" + (.type | ascii_upcase) + \"\\n\\n\" + \$text + \"\\n\"' \"\$f\" > \"\$out\" 2>/dev/null && echo \"Exported to \$out\" || echo \"Export failed\"; read -k1; fi)" \
            --bind "ctrl-d:execute(sid=\$(echo {} | cut -d'|' -f3 | tr -d ' '); f=\$(find \$HOME/.claude/projects -name \"\$sid.jsonl\" -type f 2>/dev/null | head -1); if [[ -n \"\$f\" ]]; then echo \"Delete \$f?\"; read -q '?[y/N] ' && rm \"\$f\" && echo ' Deleted' || echo ' Cancelled'; read -k1; fi)" \
            --preview '
              session_id=$(echo {} | cut -d"|" -f3 | tr -d " ")
              file=$(find "$HOME/.claude/projects" -name "''${session_id}.jsonl" -type f 2>/dev/null | head -1)
              if [[ -f "$file" ]]; then
                jq -rs '"'"'
                  {
                    total: length,
                    user: [.[] | select(.type == "user")] | length,
                    assistant: [.[] | select(.type == "assistant")] | length,
                    first_ts: (map(select(.timestamp)) | first | .timestamp // ""),
                    last_ts: (map(select(.timestamp)) | last | .timestamp // ""),
                    tools: [.[] | select(.type == "assistant") | .message.content[]? | select(.type == "tool_use") | .name] | group_by(.) | map({name: .[0], count: length}) | sort_by(-.count) | .[:5]
                  } |
                  "━━━ Session Stats ━━━\nDuration:  \(.first_ts[:16] | gsub("T";" ")) → \(.last_ts[11:16])\nMessages:  \(.user) user, \(.assistant) assistant (\(.total) total)" +
                  if (.tools | length) > 0 then
                    "\nTools:     " + ([.tools[] | "\(.name)(\(.count))"] | join(", "))
                  else ""
                  end + "\n━━━━━━━━━━━━━━━━━━━━\n"
                '"'"' "$file" 2>/dev/null
                jq -r '"'"'
                  select(.type == "user" or .type == "assistant") |
                  (if (.message.content | type) == "string" then
                    .message.content
                  elif (.message.content | type) == "array" then
                    ([.message.content[] | select(.type == "text") | .text] | join("\n"))
                  else ""
                  end) as $text |
                  select($text != "") |
                  "\n[\(.type | ascii_upcase)]:\n" + $text
                '"'"' "$file" 2>/dev/null | head -80
              fi
            ' |
          { read -r line && local sid=$(echo "$line" | cut -d'|' -f3 | tr -d ' ') && [[ -n "$sid" ]] && claude --resume "$sid"; }
        }
      fi
    '';
  };
}
