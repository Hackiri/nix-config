{
  config,
  lib,
  pkgs,
  ...
}: let
  homeDir = config.home.homeDirectory;
  tmux_config = builtins.readFile ./tmux.conf;
  catppuccin_plugin = "${pkgs.tmuxPlugins.catppuccin}/share/tmux-plugins/catppuccin";
  tmux_thumbs_plugin = "${pkgs.tmuxPlugins.tmux-thumbs}/share/tmux-plugins/tmux-thumbs";
  fzf_tmux_url_plugin = "${pkgs.tmuxPlugins.fzf-tmux-url}/share/tmux-plugins/fzf-tmux-url";

  truncate_path = pkgs.writeScriptBin "truncate_path" ''
    #!/bin/sh

    path="$1"
    max_length="''${2:-50}"  # Default to 50 if not specified
    user_home="${homeDir}"

    # Exit if no path is provided
    if [ -z "$path" ]; then
        echo "Usage: $0 <path> [max_length]"
        exit 1
    fi

    # Replace $user_home with ~ in the path
    path="''${path/#$user_home/\~}"

    # Truncate path if it's longer than max_length
    if [ "''${#path}" -gt "$max_length" ]; then
        # Keep the last $max_length characters
        path="...''${path:$(( ''${#path} - $max_length + 3 ))}"

        # Ensure we don't break directory separators
        if ! echo "$path" | grep -q "^/\|^\\.\\./" ; then
            path="''${path#*/}"
            path=".../$path"
        fi
    fi

    echo "$path"
  '';

  git_branch = pkgs.writeScriptBin "git_branch" ''
    #!/bin/sh
    cd "$1" 2>/dev/null || exit 0
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || exit 0
    if [ -n "$(git status --porcelain 2>/dev/null | head -1)" ]; then
      echo "''${branch}*"
    else
      echo "$branch"
    fi
  '';

  tmux_popup = pkgs.writeScriptBin "tmux-popup" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail

    session="popup"

    if ! tmux has-session -t "$session" 2>/dev/null; then
      tmux new-session -d -s "$session" -c "$PWD"
      tmux set-option -t "$session" key-table popup
      tmux set-option -t "$session" status off
      tmux set-option -t "$session" prefix None
    fi

    exec tmux attach-session -t "$session" >/dev/null
  '';

  tmux_codex_popup = pkgs.writeScriptBin "tmux-codex-popup" ''
    #!${pkgs.bash}/bin/bash
    set +e

    codex_bin="$(command -v codex 2>/dev/null || true)"
    [ -n "$codex_bin" ] || [ ! -x /opt/homebrew/bin/codex ] || codex_bin=/opt/homebrew/bin/codex
    [ -n "$codex_bin" ] || [ ! -x /usr/local/bin/codex ] || codex_bin=/usr/local/bin/codex

    if [ -n "$codex_bin" ]; then
      "$codex_bin"
      status=$?
      printf '\n[codex exited: %s]\n' "$status"
    else
      printf 'codex was not found on PATH. Install it with Homebrew or npm, then rerun this popup.\n'
      printf 'Expected commands include: codex, /opt/homebrew/bin/codex, /usr/local/bin/codex\n'
    fi

    exec ${pkgs.zsh}/bin/zsh -l
  '';

  tmux_kube_status = pkgs.writeScriptBin "tmux-kube-status" ''
    #!${pkgs.bash}/bin/bash

    command -v kubectl >/dev/null 2>&1 || exit 0

    ctx="$(kubectl config current-context 2>/dev/null || true)"
    [ -n "$ctx" ] || exit 0

    ns="$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null || true)"
    [ -n "$ns" ] || ns="default"

    short_ctx="$ctx"
    if [ "''${#short_ctx}" -gt 28 ]; then
      short_ctx="...''${short_ctx: -25}"
    fi

    color="#37f499"
    scope="$(printf '%s/%s' "$ctx" "$ns" | tr '[:upper:]' '[:lower:]')"
    case "$scope" in
      *prod*|*production*|*prd*) color="#f16c75" ;;
      *stage*|*staging*) color="#f1fc79" ;;
    esac

    printf '#[bg=default,fg=#565f89]│#[fg=%s] ⎈ %s/%s ' "$color" "$short_ctx" "$ns"
  '';

  tmux_kube_menu = pkgs.writeScriptBin "tmux-kube-menu" ''
    #!${pkgs.bash}/bin/bash
    set -u

    pause() {
      printf '\nPress Enter to close...'
      read -r _
    }

    need() {
      command -v "$1" >/dev/null 2>&1 && return 0
      printf '%s is not installed or not on PATH\n' "$1"
      pause
      exit 1
    }

    pick() {
      local prompt="$1"
      shift
      fzf --height 100% --border --layout=reverse --bind 'ctrl-/:toggle-preview' --prompt "$prompt" "$@"
    }

    current_ns() {
      local ns
      ns="$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null || true)"
      [ -n "$ns" ] || ns="default"
      printf '%s\n' "$ns"
    }

    select_namespace() {
      kubectl get namespaces --no-headers -o custom-columns='NAME:.metadata.name,STATUS:.status.phase,AGE:.metadata.creationTimestamp' |
        pick 'ns> ' --preview 'kubectl get all -n {1} 2>/dev/null | head -80' --preview-window right:60% |
        awk '{print $1}'
    }

    select_pod() {
      local ns="$1"
      kubectl get pods -n "$ns" -o wide --no-headers |
        pick 'pod> ' --preview "kubectl describe pod {1} -n $ns" --preview-window right:60% |
        awk '{print $1}'
    }

    select_service() {
      local ns="$1"
      kubectl get svc -n "$ns" -o wide --no-headers |
        pick 'svc> ' --preview "kubectl describe svc {1} -n $ns && echo && kubectl get endpoints {1} -n $ns" --preview-window right:60% |
        awk '{print $1}'
    }

    select_container() {
      local ns="$1"
      local pod="$2"
      local containers count
      containers="$(kubectl get pod "$pod" -n "$ns" -o jsonpath='{range .spec.containers[*]}{.name}{"\n"}{end}' 2>/dev/null || true)"
      count="$(printf '%s\n' "$containers" | sed '/^$/d' | wc -l | tr -d ' ')"

      if [ "$count" -gt 1 ]; then
        printf '%s\n' "$containers" | sed '/^$/d' | pick 'container> '
      else
        printf '%s\n' "$containers" | sed '/^$/d' | head -1
      fi
    }

    pod_logs() {
      local ns pod container
      ns="$(current_ns)"
      pod="$(select_pod "$ns")"
      [ -n "$pod" ] || return 0
      container="$(select_container "$ns" "$pod")"

      local args=(-n "$ns" "$pod" --tail=200 -f)
      [ -n "$container" ] && args=(-n "$ns" "$pod" -c "$container" --tail=200 -f)
      kubectl logs "''${args[@]}"
    }

    pod_exec() {
      local ns pod container
      ns="$(current_ns)"
      pod="$(select_pod "$ns")"
      [ -n "$pod" ] || return 0
      container="$(select_container "$ns" "$pod")"

      local args=(-n "$ns" "$pod")
      [ -n "$container" ] && args+=(-c "$container")
      kubectl exec -it "''${args[@]}" -- /bin/sh -lc 'bash || ash || sh'
    }

    port_forward() {
      local ns kind name port
      ns="$(current_ns)"
      kind="$(printf 'service\npod\n' | pick 'target> ')"
      [ -n "$kind" ] || return 0

      case "$kind" in
        service)
          name="$(select_service "$ns")"
          [ -n "$name" ] || return 0
          printf 'Port forward for svc/%s (local:remote or remote): ' "$name"
          read -r port
          [ -n "$port" ] && kubectl port-forward -n "$ns" "svc/$name" "$port"
          ;;
        pod)
          name="$(select_pod "$ns")"
          [ -n "$name" ] || return 0
          printf 'Port forward for pod/%s (local:remote or remote): ' "$name"
          read -r port
          [ -n "$port" ] && kubectl port-forward -n "$ns" "pod/$name" "$port"
          ;;
      esac
    }

    need fzf
    need kubectl

    ctx="$(kubectl config current-context 2>/dev/null || true)"
    ns="$(current_ns)"
    choice="$(
      printf '%s\t%s\n' \
        k9s 'K9s dashboard' \
        contexts 'Switch context' \
        namespaces 'Switch namespace' \
        pods 'Describe pod' \
        logs 'Follow pod logs' \
        stern 'Stern namespace logs' \
        exec 'Shell into pod' \
        services 'Browse services' \
        port-forward 'Port forward pod/service' \
        events 'Namespace events' \
        popeye 'Popeye scan' \
        cilium 'Cilium status' |
        pick 'kube> ' --delimiter=$'\t' --with-nth=2.. --header "ctx: ''${ctx:-none}  ns: $ns" |
        cut -f1
    )"

    case "$choice" in
      k9s)
        need k9s
        k9s
        ;;
      contexts)
        selected="$(kubectl config get-contexts --no-headers -o name | pick 'context> ' --preview 'kubectl config view --context={} --minify 2>/dev/null' --preview-window right:60%)"
        [ -n "$selected" ] && kubectl config use-context "$selected"
        pause
        ;;
      namespaces)
        selected="$(select_namespace)"
        [ -n "$selected" ] && kubectl config set-context --current --namespace="$selected"
        pause
        ;;
      pods)
        pod="$(select_pod "$ns")"
        [ -n "$pod" ] && kubectl describe pod "$pod" -n "$ns" | less -R
        ;;
      logs)
        pod_logs
        ;;
      stern)
        need stern
        printf 'stern pattern [.*]: '
        read -r pattern
        [ -n "$pattern" ] || pattern='.*'
        stern "$pattern" -n "$ns"
        ;;
      exec)
        pod_exec
        ;;
      services)
        svc="$(select_service "$ns")"
        [ -n "$svc" ] && kubectl describe svc "$svc" -n "$ns" | less -R
        ;;
      port-forward)
        port_forward
        ;;
      events)
        kubectl get events -n "$ns" --sort-by=.metadata.creationTimestamp | less -R
        ;;
      popeye)
        need popeye
        popeye -n "$ns"
        pause
        ;;
      cilium)
        need cilium
        cilium status
        pause
        ;;
    esac
  '';

  tmux_pf_manager = pkgs.writeScriptBin "tmux-pf-manager" ''
    #!${pkgs.bash}/bin/bash
    set -u

    pause() {
      printf '\nPress Enter to close...'
      read -r _
    }

    pick() {
      local prompt="$1"
      shift
      fzf --height 100% --border --layout=reverse --bind 'ctrl-/:toggle-preview' --prompt "$prompt" "$@"
    }

    need() {
      command -v "$1" >/dev/null 2>&1 && return 0
      printf '%s is not installed or not on PATH\n' "$1"
      pause
      exit 1
    }

    current_ns() {
      local ns
      ns="$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null || true)"
      [ -n "$ns" ] || ns="default"
      printf '%s\n' "$ns"
    }

    # Window names use prefix "pf:" so we can list them across all sessions.
    list_pf_windows() {
      tmux list-windows -a -F '#{session_name}:#{window_index} #{window_name}' 2>/dev/null |
        awk '$2 ~ /^pf:/ { printf "%s\t%s\n", $1, $2 }'
    }

    start_pf() {
      need kubectl
      local ns kind name port target window_name
      ns="$(current_ns)"
      kind="$(printf 'service\npod\n' | pick 'target> ')"
      [ -n "$kind" ] || return 0

      case "$kind" in
        service)
          name="$(kubectl get svc -n "$ns" -o wide --no-headers |
            pick 'svc> ' --preview "kubectl describe svc {1} -n $ns && echo && kubectl get endpoints {1} -n $ns" --preview-window right:60% |
            awk '{print $1}')"
          [ -n "$name" ] || return 0
          target="svc/$name"
          ;;
        pod)
          name="$(kubectl get pods -n "$ns" -o wide --no-headers |
            pick 'pod> ' --preview "kubectl describe pod {1} -n $ns" --preview-window right:60% |
            awk '{print $1}')"
          [ -n "$name" ] || return 0
          target="pod/$name"
          ;;
      esac

      printf 'Port (local:remote or remote): '
      read -r port
      [ -n "$port" ] || return 0

      window_name="pf:$ns/$name:$port"
      tmux new-window -d -n "$window_name" "kubectl port-forward -n '$ns' '$target' '$port' 2>&1; printf '\nport-forward exited. Press Enter...'; read -r _"
      printf 'Started port-forward window: %s\n' "$window_name"
      sleep 0.6
    }

    manage_pf() {
      local rows selection target_window
      rows="$(list_pf_windows)"
      if [ -z "$rows" ]; then
        echo 'No active port-forward windows (named pf:*)'
        pause
        return 0
      fi

      selection="$(printf '%s\n' "$rows" |
        pick 'pf> ' --delimiter=$'\t' --with-nth=2 --header 'enter=switch  ctrl-x=kill')"
      [ -n "$selection" ] || return 0
      target_window="$(printf '%s\n' "$selection" | cut -f1)"

      local action
      action="$(printf 'switch\nkill\n' | pick 'action> ')"
      case "$action" in
        switch) tmux switch-client -t "$target_window" ;;
        kill) tmux kill-window -t "$target_window" ;;
      esac
    }

    need fzf

    choice="$(printf '%s\t%s\n' \
      start 'Start a new port-forward (window pf:*)' \
      manage 'Switch or kill an active port-forward window' |
      pick 'port-forward> ' --delimiter=$'\t' --with-nth=2 |
      cut -f1)"

    case "$choice" in
      start) start_pf ;;
      manage) manage_pf ;;
    esac
  '';

  tmux_podman_menu = pkgs.writeScriptBin "tmux-podman-menu" ''
    #!${pkgs.bash}/bin/bash
    set -u

    pause() {
      printf '\nPress Enter to close...'
      read -r _
    }

    pick() {
      local prompt="$1"
      shift
      fzf --height 100% --border --layout=reverse --bind 'ctrl-/:toggle-preview' --prompt "$prompt" "$@"
    }

    need_fzf() {
      command -v fzf >/dev/null 2>&1 && return 0
      echo 'fzf is not installed or not on PATH'
      pause
      exit 1
    }

    container_cmd="$(command -v podman 2>/dev/null || command -v docker 2>/dev/null || true)"
    compose_cmd="$(command -v podman-compose 2>/dev/null || command -v docker-compose 2>/dev/null || true)"

    need_container_cmd() {
      [ -n "$container_cmd" ] && return 0
      echo 'podman/docker is not installed or not on PATH'
      pause
      exit 1
    }

    need_compose_cmd() {
      [ -n "$compose_cmd" ] && return 0
      echo 'podman-compose/docker-compose is not installed or not on PATH'
      pause
      return 1
    }

    has_compose_file() {
      [ -f compose.yml ] || [ -f compose.yaml ] || [ -f docker-compose.yml ] || [ -f docker-compose.yaml ]
    }

    select_container() {
      "$container_cmd" ps -a --format '{{.Names}}\t{{.Status}}\t{{.Image}}' |
        pick 'container> ' --delimiter=$'\t' --with-nth=1.. --preview "$container_cmd logs --tail=100 {1} 2>/dev/null || $container_cmd inspect {1}" --preview-window right:60% |
        cut -f1
    }

    select_image() {
      "$container_cmd" images --format '{{.Repository}}:{{.Tag}}\t{{.ID}}\t{{.Size}}' |
        pick 'image> ' --delimiter=$'\t' --with-nth=1.. --preview "$container_cmd image inspect {1} 2>/dev/null" --preview-window right:60% |
        cut -f1
    }

    inspect_json() {
      if command -v bat >/dev/null 2>&1; then
        bat -l json --paging=always
      else
        less -R
      fi
    }

    container_actions() {
      local container action answer
      container="$(select_container)"
      [ -n "$container" ] || return 0
      action="$(printf 'logs\nshell\ninspect\nstats\nrestart\nstop\nremove\n' | pick 'action> ')"

      case "$action" in
        logs) "$container_cmd" logs -f --tail=200 "$container" ;;
        shell) "$container_cmd" exec -it "$container" /bin/sh -lc 'bash || ash || sh' ;;
        inspect) "$container_cmd" inspect "$container" | inspect_json ;;
        stats) "$container_cmd" stats "$container" ;;
        restart) "$container_cmd" restart "$container"; pause ;;
        stop) "$container_cmd" stop "$container"; pause ;;
        remove)
          printf 'Remove container %s? [y/N] ' "$container"
          read -r answer
          case "$answer" in y|Y|yes|YES) "$container_cmd" rm "$container" ;; esac
          pause
          ;;
      esac
    }

    image_actions() {
      local image action answer
      image="$(select_image)"
      [ -n "$image" ] || return 0
      action="$(printf 'inspect\ndive\ntrivy\nremove\n' | pick 'action> ')"

      case "$action" in
        inspect) "$container_cmd" image inspect "$image" | inspect_json ;;
        dive)
          if command -v dive >/dev/null 2>&1; then
            dive "$image"
          else
            echo 'dive is not installed or not on PATH'
            pause
          fi
          ;;
        trivy)
          if command -v trivy >/dev/null 2>&1; then
            trivy image "$image"
          else
            echo 'trivy is not installed or not on PATH'
            pause
          fi
          ;;
        remove)
          printf 'Remove image %s? [y/N] ' "$image"
          read -r answer
          case "$answer" in y|Y|yes|YES) "$container_cmd" rmi "$image" ;; esac
          pause
          ;;
      esac
    }

    compose_action() {
      local action="$1"
      need_compose_cmd || return 0
      if ! has_compose_file; then
        echo 'No compose.yml, compose.yaml, docker-compose.yml, or docker-compose.yaml in this directory'
        pause
        return 0
      fi

      case "$action" in
        up) "$compose_cmd" up -d; pause ;;
        down) "$compose_cmd" down; pause ;;
        logs) "$compose_cmd" logs -f ;;
        ps) "$compose_cmd" ps; pause ;;
        restart) "$compose_cmd" restart; pause ;;
      esac
    }

    need_fzf
    need_container_cmd

    choice="$(
      printf '%s\t%s\n' \
        containers 'Containers: logs/shell/inspect/stop/remove' \
        images 'Images: inspect/dive/trivy/remove' \
        ps 'Container table' \
        stats 'Live container stats' \
        compose-up 'Compose up -d' \
        compose-down 'Compose down' \
        compose-logs 'Compose logs -f' \
        compose-ps 'Compose ps' \
        compose-restart 'Compose restart' \
        prune 'System prune' |
        pick 'podman> ' --delimiter=$'\t' --with-nth=2.. --header "cwd: $PWD" |
        cut -f1
    )"

    case "$choice" in
      containers) container_actions ;;
      images) image_actions ;;
      ps) "$container_cmd" ps -a; pause ;;
      stats) "$container_cmd" stats ;;
      compose-up) compose_action up ;;
      compose-down) compose_action down ;;
      compose-logs) compose_action logs ;;
      compose-ps) compose_action ps ;;
      compose-restart) compose_action restart ;;
      prune)
        printf 'Run %s system prune? [y/N] ' "$container_cmd"
        read -r answer
        case "$answer" in y|Y|yes|YES) "$container_cmd" system prune; pause ;; esac
        ;;
    esac
  '';

  tmux_layout_picker = pkgs.writeScriptBin "tmux-layout-picker" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail

    # Layout options with icons
    declare -A layouts
    layouts=(
      ["󰕰 Tall (Main + Side Stack)"]="Tall"
      ["󰕬 Fat  (Main + Bottom Stack)"]="Fat"
      ["󰕫 Grid (Balanced)"]="Grid"
      ["󰊓 Focus (Zoom toggle)"]="Focus"
    )

    # Use FZF to pick a layout
    choice=$(printf "%s\n" "''${!layouts[@]}" | fzf \
      --header=" iKitty Layouts " \
      --layout=reverse \
      --border \
      --height=100% \
      --prompt="  " \
      --pointer="▶" \
      --color="header:#37f499,pointer:#37f499")

    [ -n "$choice" ] || exit 0
    selected="''${layouts[$choice]}"

    case "$selected" in
      Tall)
        tmux set-window-option main-pane-width 66%
        tmux select-layout main-vertical
        ;;
      Fat)
        tmux set-window-option main-pane-height 66%
        tmux select-layout main-horizontal
        ;;
      Grid)
        tmux select-layout tiled
        ;;
      Focus)
        tmux resize-pane -Z
        ;;
    esac
  '';
in {
  config =
    lib.mkIf
    (
      (config.profiles.workspace.enable or true)
      && (config.profiles.workspace.terminals.enable or true)
    )
    {
      home.packages = [
        truncate_path # Custom path truncation script
        git_branch # Git branch for tmux status bar
        tmux_popup # Persistent tmux shell popup
        tmux_codex_popup # Codex popup launcher
        tmux_kube_status # Kubernetes context/namespace for tmux status
        tmux_kube_menu # Kubernetes tmux popup workflow
        tmux_pf_manager # Port-forward window manager
        tmux_podman_menu # Podman/Compose tmux popup workflow
        tmux_layout_picker # Interactive tmux layout picker
      ];

      programs.tmux = {
        enable = true;
        shell = "${pkgs.zsh}/bin/zsh";
        terminal = "tmux-256color";
        historyLimit = 1000000;
        keyMode = "vi";
        customPaneNavigationAndResize = false;
        escapeTime = 0;
        baseIndex = 1;
        mouse = true;

        plugins = with pkgs.tmuxPlugins; [
          vim-tmux-navigator
          better-mouse-mode
          yank
          sensible
          resurrect
          continuum
          # tmux-thumbs, fzf-tmux-url, and catppuccin are loaded manually below
          # so their options can be set before their plugin scripts run.
        ];

        extraConfig = ''
          ${tmux_config}

          # Workflow popups use store paths so they don't depend on tmux server PATH.
          bind M-s display-popup -d "#{pane_current_path}" -E -w 80% -h 80% -T "Shell" "${tmux_popup}/bin/tmux-popup"
          bind -T popup M-s detach-client
          bind -T popup C-a switch-client -T popup-prefix
          bind -T popup-prefix '[' copy-mode
          bind -T popup-prefix Any switch-client -T popup
          bind M-c display-popup -d "#{pane_current_path}" -E -w 80% -h 80% -T "Codex" "${tmux_codex_popup}/bin/tmux-codex-popup"
          bind M-k display-popup -d "#{pane_current_path}" -E -w 90% -h 85% "${tmux_kube_menu}/bin/tmux-kube-menu"
          bind M-f display-popup -d "#{pane_current_path}" -E -w 80% -h 75% "${tmux_pf_manager}/bin/tmux-pf-manager"
          bind M-p display-popup -d "#{pane_current_path}" -E -w 90% -h 85% "${tmux_podman_menu}/bin/tmux-podman-menu"
          bind L display-popup -E -w 40% -h 40% -T " Layouts " "${tmux_layout_picker}/bin/tmux-layout-picker"

          # Load key-option-sensitive plugins AFTER tmux_config sets their options
          run-shell ${tmux_thumbs_plugin}/tmux-thumbs.tmux
          run-shell ${fzf_tmux_url_plugin}/fzf-url.tmux

          # Load catppuccin AFTER options are set (home-manager runs plugins before extraConfig)
          run-shell ${catppuccin_plugin}/catppuccin.tmux

          # Custom git_branch module (defined after catppuccin creates theme variables)
          %hidden MODULE_NAME="git_branch"
          set -ogq "@catppuccin_''${MODULE_NAME}_icon" "󰊢 "
          set -ogq "@catppuccin_''${MODULE_NAME}_color" "#04d1f9"
          set -ogq "@catppuccin_''${MODULE_NAME}_text" " #(git_branch #{pane_current_path})"
          source "${catppuccin_plugin}/utils/status_module.conf"

          # Status line must be set AFTER all modules (built-in + custom) are defined
          # Left: prefix-aware session (red on prefix, catppuccin pill otherwise) + dir + zoom
          set -g  status-left "#{?client_prefix,#{#[bg=#{@thm_red},fg=#{@thm_crust},bold]  #S },#{E:@catppuccin_status_session}}"
          set -ga status-left "#[bg=default,fg=#{@thm_overlay_0},none]│"
          set -ga status-left "#[bg=default,fg=#{@thm_blue}]  #{=/-32/...:#{s|$USER|~|:#{b:pane_current_path}}} "
          set -ga status-left "#[bg=default,fg=#{@thm_overlay_0},none]#{?window_zoomed_flag,│,}"
          set -ga status-left "#[bg=default,fg=#{@thm_yellow}]#{?window_zoomed_flag,  zoom ,}"
          set -g status-right "#{E:@catppuccin_status_git_branch}#(${tmux_kube_status}/bin/tmux-kube-status)#{E:@catppuccin_status_date_time}"
        '';
      };
    };
}
