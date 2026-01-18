# Claude Code - rich statusline configuration
{pkgs, ...}: {
  # Deploy statusline script to ~/.claude/ (Claude Code's expected location)
  home.file.".claude/statusline-command.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Claude Code rich status line script
      # Displays: Directory [git] | Model ⚡Context% | Xk/Xk tokens | Xk ctx [style] -- VIM MODE --

      input=$(cat)

      # Parse JSON input using jq
      JQ="${pkgs.jq}/bin/jq"
      model=$(echo "$input" | $JQ -r '.model // "unknown"')
      context=$(echo "$input" | $JQ -r '.contextPercentage // 0')
      output_style=$(echo "$input" | $JQ -r '.outputStyle // "default"')
      vim_mode=$(echo "$input" | $JQ -r '.vimMode // ""')

      # Parse token and context info
      input_tokens=$(echo "$input" | $JQ -r '.context_window.total_input_tokens // 0')
      output_tokens=$(echo "$input" | $JQ -r '.context_window.total_output_tokens // 0')
      context_size=$(echo "$input" | $JQ -r '.context_window.context_window_size // 0')

      # Format token count (1234 -> 1k, 12345 -> 12k)
      format_tokens() {
        local n=$1
        if (( n >= 1000 )); then
          printf "%.0fk" "$(echo "scale=1; $n/1000" | ${pkgs.bc}/bin/bc)"
        else
          echo "$n"
        fi
      }

      input_fmt=$(format_tokens "$input_tokens")
      output_fmt=$(format_tokens "$output_tokens")
      ctx_fmt=$(format_tokens "$context_size")

      # Current directory with ~ abbreviation
      cwd=$(pwd | sed "s|^$HOME|~|")

      # Git info (use --no-optional-locks to avoid lock issues)
      git_info=""
      if git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
        branch=$(git --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)

        # Check dirty/clean status
        if git --no-optional-locks diff --quiet HEAD 2>/dev/null && \
           git --no-optional-locks diff --cached --quiet HEAD 2>/dev/null; then
          dirty="✓"
        else
          dirty="±"
        fi

        # Check ahead/behind
        ahead_behind=""
        ahead=$(git --no-optional-locks rev-list --count @{u}..HEAD 2>/dev/null || echo 0)
        behind=$(git --no-optional-locks rev-list --count HEAD..@{u} 2>/dev/null || echo 0)
        [[ "$ahead" -gt 0 ]] && ahead_behind="↑$ahead"
        [[ "$behind" -gt 0 ]] && ahead_behind="$ahead_behind↓$behind"

        git_info=" [$branch $dirty$ahead_behind]"
      fi

      # Shorten model name for display
      case "$model" in
        *opus*) model_short="opus" ;;
        *sonnet*) model_short="sonnet" ;;
        *haiku*) model_short="haiku" ;;
        *) model_short="$model" ;;
      esac

      # Format context percentage with color coding
      context_pct=$(printf "%.0f" "$context")
      # ANSI colors: green=32, yellow=33, red=31
      if (( context_pct > 50 )); then
        context_color="\033[32m"  # green - plenty of context
      elif (( context_pct > 20 )); then
        context_color="\033[33m"  # yellow - moderate
      else
        context_color="\033[31m"  # red - low context remaining
      fi
      reset="\033[0m"
      dim="\033[2m"

      # Output style (only show if non-default)
      style_info=""
      if [[ "$output_style" != "default" && -n "$output_style" ]]; then
        style_info=" [$output_style]"
      fi

      # Vim mode indicator
      vim_indicator=""
      if [[ -n "$vim_mode" ]]; then
        vim_indicator=" -- $vim_mode --"
      fi

      # Build token info section
      token_info=""
      if [[ "$input_tokens" != "0" && "$input_tokens" != "null" ]]; then
        token_info=" | ''${input_fmt}/''${output_fmt} tokens | ''${ctx_fmt} ctx"
      fi

      # Build the status line with dimmed style for consistency
      echo -e "''${dim}$cwd$git_info | $model_short ⚡''${reset}''${context_color}$context_pct%''${reset}''${dim}$token_info$style_info$vim_indicator''${reset}"
    '';
  };
}
