# Talos Integration with FZF
# Interactive talosctl operations using fuzzy finder
# Keybindings: Ctrl+T followed by Ctrl+[key]
_: ''
  # Talos Integration Helper Functions

  # Check if talosctl is available
  is_talosctl_available() {
    command -v talosctl > /dev/null 2>&1
  }

  # Standard FZF configuration for talos operations
  fzf-talos() {
    fzf --height 50% --min-height 20 --border --bind ctrl-/:toggle-preview "$@"
  }

  # Talos Node Selector (^t^n)
  # Browse and select Talos nodes
  _tn() {
    is_talosctl_available || return
    talosctl get members --nodes "$(talosctl config info -o json 2>/dev/null | jq -r '.endpoints[0]' 2>/dev/null || echo '127.0.0.1')" 2>/dev/null |
    grep -v "^NODE" |
    fzf-talos --ansi \
      --preview "talosctl version --nodes {1} 2>/dev/null || echo 'Unable to fetch version'" \
      --header 'Select Talos node' \
      --preview-window right:60% |
    awk '{print $1}'
  }

  # Talos Dashboard (^t^d)
  # Interactive node health and status viewer
  _td() {
    is_talosctl_available || return
    local node
    node="$(_tn)"
    if [ -n "$node" ]; then
      talosctl dashboard --nodes "$node"
    fi
  }

  # Talos Logs Viewer (^t^l)
  # Browse and view service logs on Talos nodes
  _tl() {
    is_talosctl_available || return
    local node
    node="$(_tn)"
    if [ -n "$node" ]; then
      # Get list of services
      local service
      service="$(talosctl services --nodes "$node" 2>/dev/null |
      grep -v "^NODE" |
      fzf-talos --ansi \
        --preview "talosctl logs --nodes $node {2} --tail 50 2>/dev/null || echo 'No logs available'" \
        --header "Services on node: $node" \
        --preview-window right:60% |
      awk '{print $2}')"

      if [ -n "$service" ]; then
        talosctl logs --nodes "$node" "$service" --follow
      fi
    fi
  }

  # Talos Dmesg Viewer (^t^m)
  # View kernel logs from Talos node
  _tm() {
    is_talosctl_available || return
    local node
    node="$(_tn)"
    if [ -n "$node" ]; then
      talosctl dmesg --nodes "$node" --follow
    fi
  }

  # Talos Container Selector (^t^c)
  # Browse and interact with containers on Talos nodes
  _tc() {
    is_talosctl_available || return
    local node
    node="$(_tn)"
    if [ -n "$node" ]; then
      local container
      container="$(talosctl containers --nodes "$node" 2>/dev/null |
      grep -v "^NODE" |
      fzf-talos --ansi \
        --preview "talosctl inspect --nodes $node container {4} 2>/dev/null || echo 'Details unavailable'" \
        --header "Containers on node: $node (Enter=logs, Ctrl-E=exec)" \
        --bind "ctrl-e:execute(talosctl exec --nodes $node {4})+abort" \
        --preview-window right:60% |
      awk '{print $4}')"

      if [ -n "$container" ]; then
        talosctl logs --nodes "$node" -k "$container" --tail 100
      fi
    fi
  }

  # Talos Config Context Selector (^t^x)
  # Switch between Talos config contexts
  _tx() {
    is_talosctl_available || return
    local context
    context="$(talosctl config contexts 2>/dev/null |
    fzf-talos --ansi \
      --preview "talosctl config info --context {} 2>/dev/null || echo 'Context details unavailable'" \
      --header 'Select Talos context' \
      --preview-window right:60%)"

    if [ -n "$context" ]; then
      talosctl config context "$context"
      echo "Switched to Talos context: $context"
    fi
  }

  # Talos Upgrade Helper (^t^u)
  # Interactive node upgrade workflow
  _tu() {
    is_talosctl_available || return
    local node
    node="$(_tn)"
    if [ -n "$node" ]; then
      echo "Current version on $node:"
      talosctl version --nodes "$node" 2>/dev/null
      echo "\nEnter Talos version to upgrade to (e.g., v1.8.0):"
      read version
      if [ -n "$version" ]; then
        echo "Upgrading $node to $version..."
        talosctl upgrade --nodes "$node" --image "ghcr.io/siderolabs/installer:$version"
      fi
    fi
  }

  # Talos Health Check (^t^h)
  # Quick health overview of Talos cluster
  _th() {
    is_talosctl_available || return
    echo "=== Talos Cluster Health ==="
    echo "\n--- Node Status ---"
    talosctl health 2>/dev/null || echo "Unable to fetch health status"
    echo "\n--- Service Status ---"
    talosctl services 2>/dev/null | head -20
  }

  # Function to bind all Talos helper functions to keyboard shortcuts
  bind-talos-helper() {
    local c
    for c in $@; do
      eval "fzf-t$c-widget() { local result=\$(_t$c | join-lines); zle reset-prompt; LBUFFER+=\$result }"
      eval "zle -N fzf-t$c-widget"
      eval "bindkey '^t^$c' fzf-t$c-widget"
    done
  }

  # Bind Talos helper functions
  # n=nodes, d=dashboard, l=logs, m=dmesg, c=containers, x=context, u=upgrade, h=health
  bind-talos-helper n d l m c x u h
  unset -f bind-talos-helper
''
