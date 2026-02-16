# Claude Code - rich statusline configuration with advanced analytics
{pkgs, ...}: {
  # Deploy statusline script to ~/.claude/ (Claude Code's expected location)
  home.file.".claude/statusline-command.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Claude Code rich status line script with advanced analytics
      # Features: Cache tracking, response time, token speed, session duration, costs, emojis

      input=$(cat)

      # ============================================================================
      # CONFIGURATION - Toggle which fields to display (true/false)
      # ============================================================================
      SHOW_EMOJI=true
      SHOW_GIT=true
      SHOW_MODEL=true
      SHOW_CONTEXT=true
      SHOW_TOKENS=true
      SHOW_CACHE=true
      SHOW_COST=true
      SHOW_SPEED=true
      SHOW_DURATION=true
      SHOW_STYLE=true
      SHOW_VIM=true
      SHOW_BLOCK_TIMER=true

      # ============================================================================
      # TOOLS
      # ============================================================================
      JQ="${pkgs.jq}/bin/jq"
      BC="${pkgs.bc}/bin/bc"

      # ============================================================================
      # PARSE JSON INPUT
      # ============================================================================
      model_id=$(echo "$input" | $JQ -r '.model.id // .model // "unknown"')
      model_display=$(echo "$input" | $JQ -r '.model.display_name // .model // "unknown"')
      output_style=$(echo "$input" | $JQ -r '.output_style.name // .outputStyle // "default"')
      vim_mode=$(echo "$input" | $JQ -r '.vim.mode // .vimMode // ""')
      session_id=$(echo "$input" | $JQ -r '.session_id // "default"')

      # Context window data
      total_input=$(echo "$input" | $JQ -r '.context_window.total_input_tokens // 0')
      total_output=$(echo "$input" | $JQ -r '.context_window.total_output_tokens // 0')
      context_size=$(echo "$input" | $JQ -r '.context_window.context_window_size // 0')
      remaining_pct=$(echo "$input" | $JQ -r '.context_window.remaining_percentage // .contextPercentage // 0')

      # Current usage (from last API call) - for cache breakdown
      current_input=$(echo "$input" | $JQ -r '.context_window.current_usage.input_tokens // 0')
      current_output=$(echo "$input" | $JQ -r '.context_window.current_usage.output_tokens // 0')
      cache_write=$(echo "$input" | $JQ -r '.context_window.current_usage.cache_creation_input_tokens // 0')
      cache_read=$(echo "$input" | $JQ -r '.context_window.current_usage.cache_read_input_tokens // 0')

      # ============================================================================
      # STATE DIRECTORY FOR TRACKING
      # ============================================================================
      STATE_DIR="$HOME/.claude/statusline-state"
      mkdir -p "$STATE_DIR" 2>/dev/null

      # Cleanup stale session files older than 24 hours (runs at most once per hour)
      cleanup_marker="$STATE_DIR/.last-cleanup"
      if [[ ! -f "$cleanup_marker" ]] || (( $(date +%s) - $(cat "$cleanup_marker" 2>/dev/null || echo 0) > 3600 )); then
        find "$STATE_DIR" -name "session-*" -mtime +1 -delete 2>/dev/null &
        date +%s > "$cleanup_marker"
      fi

      # ============================================================================
      # SESSION DURATION TRACKING
      # ============================================================================
      duration_fmt=""
      if [[ "$SHOW_DURATION" == "true" ]]; then
        session_start_file="$STATE_DIR/session-''${session_id}-start"
        if [[ ! -f "$session_start_file" ]]; then
          date +%s > "$session_start_file"
        fi

        start_time=$(cat "$session_start_file" 2>/dev/null || date +%s)
        current_time=$(date +%s)
        duration=$((current_time - start_time))

        # Format duration
        if (( duration < 60 )); then
          duration_fmt="''${duration}s"
        elif (( duration < 3600 )); then
          duration_fmt="$((duration / 60))m"
        else
          duration_fmt="$((duration / 3600))h$((duration % 3600 / 60))m"
        fi
      fi

      # ============================================================================
      # BLOCK TIMER TRACKING (5-hour conversation blocks)
      # ============================================================================
      block_remaining_fmt=""
      block_emoji=""
      block_bar=""
      if [[ "$SHOW_BLOCK_TIMER" == "true" ]]; then
        # Global block timer — persists across sessions (tracks 5h usage window)
        block_start_file="$STATE_DIR/global-block-start"
        current_time=''${current_time:-$(date +%s)}
        block_duration=18000  # 5 hours in seconds

        if [[ ! -f "$block_start_file" ]]; then
          echo "$current_time" > "$block_start_file"
        fi

        block_start=$(cat "$block_start_file" 2>/dev/null || echo "$current_time")
        block_elapsed=$((current_time - block_start))

        # Auto-reset if block has expired
        if (( block_elapsed >= block_duration )); then
          echo "$current_time" > "$block_start_file"
          block_elapsed=0
        fi

        block_remaining=$((block_duration - block_elapsed))
        block_remaining_h=$((block_remaining / 3600))
        block_remaining_m=$(( (block_remaining % 3600) / 60 ))
        block_remaining_fmt="''${block_remaining_h}h ''${block_remaining_m}m"

        # Progress bar (10 chars)
        block_pct=$((100 * block_elapsed / block_duration))
        filled=$((block_pct / 10))
        empty=$((10 - filled))
        block_bar="["
        for ((i=0; i<filled; i++)); do block_bar+="█"; done
        for ((i=0; i<empty; i++)); do block_bar+="░"; done
        block_bar+="]"

        # Emoji indicator based on remaining time
        if [[ "$SHOW_EMOJI" == "true" ]]; then
          if (( block_remaining > 10800 )); then
            block_emoji="🟢"
          elif (( block_remaining > 3600 )); then
            block_emoji="🟡"
          else
            block_emoji="🔴"
          fi
        fi
      fi

      # ============================================================================
      # RESPONSE TIME & TOKEN GENERATION SPEED
      # ============================================================================
      tokens_per_sec=""
      if [[ "$SHOW_SPEED" == "true" ]]; then
        last_call_file="$STATE_DIR/session-''${session_id}-lastcall"
        current_time=''${current_time:-$(date +%s)}

        if [[ -f "$last_call_file" ]]; then
          read last_time last_output < "$last_call_file"
          if [[ "$total_output" -gt "$last_output" && -n "$last_time" ]]; then
            call_duration=$((current_time - last_time))
            tokens_generated=$((total_output - last_output))
            if (( call_duration > 0 )); then
              tps=$(echo "scale=1; $tokens_generated / $call_duration" | $BC 2>/dev/null)
              [[ -n "$tps" ]] && tokens_per_sec="''${tps}t/s"
            fi
          fi
        fi
        echo "$current_time $total_output" > "$last_call_file"
      fi

      # ============================================================================
      # CACHE HIT RATE CALCULATION
      # ============================================================================
      cache_rate=""
      cache_emoji=""
      if [[ "$SHOW_CACHE" == "true" && "$current_input" != "0" && "$current_input" != "null" && -n "$current_input" ]]; then
        if (( current_input > 0 )); then
          cache_pct=$(echo "scale=1; 100 * $cache_read / $current_input" | $BC 2>/dev/null)
          if [[ -n "$cache_pct" ]]; then
            cache_rate="''${cache_pct}%"

            # Cache hit emoji indicators
            if [[ "$SHOW_EMOJI" == "true" ]]; then
              pct_int=''${cache_pct%.*}
              if (( pct_int >= 70 )); then
                cache_emoji="🔥"  # Hot cache
              elif (( pct_int >= 30 )); then
                cache_emoji="💾"  # Warm cache
              else
                cache_emoji="❄️"   # Cold cache
              fi
            fi
          fi
        fi
      fi

      # ============================================================================
      # COST CALCULATION (Claude API Pricing — updated Feb 2026)
      # Models: opus-4/4.6, sonnet-4/4.5/3.5, haiku-4.5/3.5
      # ============================================================================
      session_cost=""
      if [[ "$SHOW_COST" == "true" ]]; then
        # Pricing per million tokens
        case "$model_id" in
          *opus-4-6*|*opus-4*)
            input_price=15.00; output_price=75.00
            cache_write_price=18.75; cache_read_price=1.50 ;;
          *sonnet-4-5*|*sonnet-4*|*sonnet-3-5*)
            input_price=3.00; output_price=15.00
            cache_write_price=3.75; cache_read_price=0.30 ;;
          *haiku-4-5*|*haiku-3-5*|*haiku*)
            input_price=0.80; output_price=4.00
            cache_write_price=1.00; cache_read_price=0.08 ;;
          *)
            input_price=0; output_price=0
            cache_write_price=0; cache_read_price=0 ;;
        esac

        if (( $(echo "$input_price > 0" | $BC -l 2>/dev/null) )); then
          base_input=$((total_input - cache_read))
          cost=$(echo "scale=4; ($base_input * $input_price + $total_output * $output_price + $cache_write * $cache_write_price + $cache_read * $cache_read_price) / 1000000" | $BC 2>/dev/null)

          if [[ -n "$cost" ]]; then
            # Format cost
            if (( $(echo "$cost < 0.01" | $BC -l 2>/dev/null) )); then
              session_cost="<\$0.01"
            else
              session_cost=$(printf "\$%.2f" "$cost")
            fi
          fi
        fi
      fi

      # ============================================================================
      # TOKEN FORMATTING
      # ============================================================================
      format_tokens() {
        local n=$1
        if (( n >= 1000000 )); then
          printf "%.1fM" "$(echo "scale=1; $n/1000000" | $BC)"
        elif (( n >= 1000 )); then
          printf "%.0fk" "$(echo "scale=1; $n/1000" | $BC)"
        else
          echo "$n"
        fi
      }

      total_input_fmt=$(format_tokens "$total_input")
      total_output_fmt=$(format_tokens "$total_output")
      ctx_fmt=$(format_tokens "$context_size")

      # Input token breakdown
      base_input=$((current_input - cache_read))
      base_fmt=$(format_tokens "$base_input")
      cache_write_fmt=$(format_tokens "$cache_write")
      cache_read_fmt=$(format_tokens "$cache_read")

      # ============================================================================
      # GIT INFORMATION
      # ============================================================================
      git_info=""
      if [[ "$SHOW_GIT" == "true" ]] && git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
        branch=$(git --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)

        if git --no-optional-locks diff --quiet HEAD 2>/dev/null && \
           git --no-optional-locks diff --cached --quiet HEAD 2>/dev/null; then
          dirty="✓"
        else
          dirty="±"
        fi

        ahead_behind=""
        ahead=$(git --no-optional-locks rev-list --count @{u}..HEAD 2>/dev/null || echo 0)
        behind=$(git --no-optional-locks rev-list --count HEAD..@{u} 2>/dev/null || echo 0)
        [[ "$ahead" -gt 0 ]] && ahead_behind="↑$ahead"
        [[ "$behind" -gt 0 ]] && ahead_behind="$ahead_behind↓$behind"

        git_info=" [$branch $dirty$ahead_behind]"
      fi

      # ============================================================================
      # MODEL DISPLAY WITH EMOJI
      # ============================================================================
      model_short="$model_display"
      model_emoji=""

      case "$model_id" in
        *opus*) model_short="opus"; [[ "$SHOW_EMOJI" == "true" ]] && model_emoji="🧠 " ;;
        *sonnet*) model_short="sonnet"; [[ "$SHOW_EMOJI" == "true" ]] && model_emoji="🎼 " ;;
        *haiku*) model_short="haiku"; [[ "$SHOW_EMOJI" == "true" ]] && model_emoji="🍃 " ;;
      esac

      # ============================================================================
      # CONTEXT PERCENTAGE WITH COLOR CODING
      # ============================================================================
      context_display=""
      reset="\033[0m"
      dim="\033[2m"

      if [[ "$SHOW_CONTEXT" == "true" ]]; then
        remaining=$(printf "%.0f" "$remaining_pct" 2>/dev/null || echo "0")

        if (( remaining > 50 )); then
          context_color="\033[32m"  # green
          [[ "$SHOW_EMOJI" == "true" ]] && context_emoji="📊"
        elif (( remaining > 20 )); then
          context_color="\033[33m"  # yellow
          [[ "$SHOW_EMOJI" == "true" ]] && context_emoji="📈"
        else
          context_color="\033[31m"  # red
          [[ "$SHOW_EMOJI" == "true" ]] && context_emoji="⚠️ "
        fi

        if [[ "$SHOW_EMOJI" == "true" && -n "$context_emoji" ]]; then
          context_display="''${context_emoji}''${context_color}''${remaining}%''${reset}"
        else
          context_display="⚡''${context_color}''${remaining}%''${reset}"
        fi
      fi

      # ============================================================================
      # BUILD STATUS LINE SECTIONS
      # ============================================================================
      cwd=$(pwd | sed "s|^$HOME|~|")

      # Token section with breakdown
      token_section=""
      if [[ "$SHOW_TOKENS" == "true" && "$total_input" != "0" ]]; then
        token_section=" | 📥''${total_input_fmt} 📤''${total_output_fmt}"
        # Add breakdown if cache data available
        if [[ "$cache_read" != "0" || "$cache_write" != "0" ]]; then
          token_section="$token_section (r:''${cache_read_fmt} w:''${cache_write_fmt})"
        fi
      fi

      # Cache hit rate section
      cache_section=""
      if [[ "$SHOW_CACHE" == "true" && -n "$cache_rate" ]]; then
        cache_section=" | ''${cache_emoji}''${cache_rate}"
      fi

      # Cost section
      cost_section=""
      if [[ "$SHOW_COST" == "true" && -n "$session_cost" ]]; then
        [[ "$SHOW_EMOJI" == "true" ]] && cost_section=" | 💰''${session_cost}" || cost_section=" | ''${session_cost}"
      fi

      # Speed section
      speed_section=""
      if [[ "$SHOW_SPEED" == "true" && -n "$tokens_per_sec" ]]; then
        [[ "$SHOW_EMOJI" == "true" ]] && speed_section=" | ⚡''${tokens_per_sec}" || speed_section=" | ''${tokens_per_sec}"
      fi

      # Duration section
      duration_section=""
      if [[ "$SHOW_DURATION" == "true" && -n "$duration_fmt" ]]; then
        [[ "$SHOW_EMOJI" == "true" ]] && duration_section=" | ⏱️''${duration_fmt}" || duration_section=" | ''${duration_fmt}"
      fi

      # Context size section
      ctx_section=""
      if [[ "$SHOW_CONTEXT" == "true" && "$context_size" != "0" ]]; then
        ctx_section=" | ''${ctx_fmt} ctx"
      fi

      # Output style section
      style_section=""
      if [[ "$SHOW_STYLE" == "true" && "$output_style" != "default" && -n "$output_style" ]]; then
        [[ "$SHOW_EMOJI" == "true" ]] && style_section=" | 🎨''${output_style}" || style_section=" | [''${output_style}]"
      fi

      # Block timer section
      block_section=""
      if [[ "$SHOW_BLOCK_TIMER" == "true" && -n "$block_remaining_fmt" ]]; then
        block_section=" | ''${block_emoji}''${block_remaining_fmt} ''${block_bar}"
      fi

      # Vim mode section
      vim_section=""
      if [[ "$SHOW_VIM" == "true" && -n "$vim_mode" ]]; then
        vim_section=" -- ''${vim_mode} --"
      fi

      # ============================================================================
      # ASSEMBLE FINAL STATUS LINE
      # ============================================================================
      model_section=""
      if [[ "$SHOW_MODEL" == "true" ]]; then
        model_section="''${model_emoji}''${model_short}"
      fi

      echo -e "''${dim}''${cwd}''${git_info} | ''${model_section} ''${context_display}''${token_section}''${cache_section}''${cost_section}''${speed_section}''${duration_section}''${block_section}''${ctx_section}''${style_section}''${vim_section}''${reset}"
    '';
  };
}
