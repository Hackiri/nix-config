# Cilium Integration with FZF
# Interactive cilium operations using fuzzy finder
# Keybindings: Ctrl+C followed by Ctrl+[key]
_: ''
  # Cilium Integration Helper Functions

  # Check if cilium CLI is available
  is_cilium_available() {
    command -v cilium > /dev/null 2>&1
  }

  # Standard FZF configuration for cilium operations
  fzf-cilium() {
    fzf --height 50% --min-height 20 --border --bind ctrl-/:toggle-preview "$@"
  }

  # Cilium Pod Selector (^c^p)
  # Browse and select Cilium pods
  _cp() {
    is_cilium_available || return
    local namespace="$(kubectl get pods -A -l k8s-app=cilium -o jsonpath='{.items[0].metadata.namespace}' 2>/dev/null || echo 'kube-system')"

    kubectl get pods -n "$namespace" -l k8s-app=cilium --no-headers -o custom-columns=":metadata.name,:status.phase,:spec.nodeName" |
    fzf-cilium --ansi \
      --preview "kubectl describe pod {1} -n $namespace" \
      --header "Cilium pods in namespace: $namespace" \
      --preview-window right:60% |
    awk '{print $1}'
  }

  # Cilium Status (^c^s)
  # Interactive Cilium status viewer
  _cs() {
    is_cilium_available || return
    echo "=== Cilium Status ==="
    cilium status --wait 2>/dev/null || echo "Unable to fetch Cilium status"
  }

  # Cilium Connectivity Test (^c^t)
  # Run Cilium connectivity tests
  _ct() {
    is_cilium_available || return
    echo "Running Cilium connectivity test..."
    echo "This may take several minutes..."
    cilium connectivity test
  }

  # Cilium Endpoint Selector (^c^e)
  # Browse Cilium endpoints with detailed info
  _ce() {
    is_cilium_available || return
    local pod
    pod="$(_cp)"
    if [ -n "$pod" ]; then
      local namespace="$(kubectl get pods -A -l k8s-app=cilium -o jsonpath='{.items[0].metadata.namespace}' 2>/dev/null || echo 'kube-system')"

      kubectl exec -n "$namespace" "$pod" -c cilium-agent -- cilium endpoint list -o json 2>/dev/null |
      jq -r '.[] | [.id, .status.state, .status.identity.id, (.status.policy.realized.policy-enabled // "N/A")] | @tsv' |
      fzf-cilium --ansi --header-lines=0 \
        --preview "kubectl exec -n $namespace $pod -c cilium-agent -- cilium endpoint get {1} 2>/dev/null" \
        --header "Endpoints on pod: $pod" \
        --preview-window right:60% |
      awk '{print $1}'
    fi
  }

  # Cilium Monitor (^c^m)
  # Start Cilium monitor on selected pod
  _cm() {
    is_cilium_available || return
    local pod
    pod="$(_cp)"
    if [ -n "$pod" ]; then
      local namespace="$(kubectl get pods -A -l k8s-app=cilium -o jsonpath='{.items[0].metadata.namespace}' 2>/dev/null || echo 'kube-system')"
      echo "Starting Cilium monitor on $pod..."
      kubectl exec -n "$namespace" "$pod" -c cilium-agent -- cilium monitor
    fi
  }

  # Cilium Policy Selector (^c^l)
  # Browse and view Cilium network policies
  _cl() {
    is_cilium_available || return
    local namespace="$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)"
    namespace="''${namespace:-default}"

    kubectl get cnp,ccnp -A --no-headers -o custom-columns=":metadata.namespace,:metadata.name,:kind" 2>/dev/null |
    fzf-cilium --ansi \
      --preview "kubectl describe {3} {2} -n {1} 2>/dev/null" \
      --header 'Cilium Network Policies (CNP/CCNP)' \
      --preview-window right:60%
  }

  # Cilium Service Map (^c^v)
  # View service dependencies and connectivity
  _cv() {
    is_cilium_available || return
    local pod
    pod="$(_cp)"
    if [ -n "$pod" ]; then
      local namespace="$(kubectl get pods -A -l k8s-app=cilium -o jsonpath='{.items[0].metadata.namespace}' 2>/dev/null || echo 'kube-system')"
      echo "Service map from $pod:"
      kubectl exec -n "$namespace" "$pod" -c cilium-agent -- cilium service list
    fi
  }

  # Cilium BPF Map Selector (^c^b)
  # Browse and inspect BPF maps
  _cb() {
    is_cilium_available || return
    local pod
    pod="$(_cp)"
    if [ -n "$pod" ]; then
      local namespace="$(kubectl get pods -A -l k8s-app=cilium -o jsonpath='{.items[0].metadata.namespace}' 2>/dev/null || echo 'kube-system')"

      kubectl exec -n "$namespace" "$pod" -c cilium-agent -- cilium bpf map list 2>/dev/null |
      fzf-cilium --ansi \
        --preview "kubectl exec -n $namespace $pod -c cilium-agent -- cilium bpf map get {1} 2>/dev/null || echo 'Map details unavailable'" \
        --header "BPF maps on pod: $pod" \
        --preview-window right:60%
    fi
  }

  # Cilium Hubble UI (^c^u)
  # Open Hubble UI with port-forward
  _cu() {
    is_cilium_available || return
    echo "Starting Hubble UI port-forward on localhost:12000..."
    cilium hubble ui
  }

  # Cilium Hubble Observe (^c^o)
  # Interactive Hubble flow observation
  _co() {
    is_cilium_available || return
    echo "=== Hubble Flow Observation ==="
    echo "Filter options:"
    echo "1. All flows"
    echo "2. Flows from specific namespace"
    echo "3. Flows to/from specific pod"
    echo "4. Dropped flows only"
    echo ""
    echo -n "Select option (1-4): "
    read option

    case "$option" in
      1)
        cilium hubble observe --follow
        ;;
      2)
        echo -n "Enter namespace: "
        read ns
        cilium hubble observe --namespace "$ns" --follow
        ;;
      3)
        echo -n "Enter pod name: "
        read pod_name
        cilium hubble observe --pod "$pod_name" --follow
        ;;
      4)
        cilium hubble observe --verdict DROPPED --follow
        ;;
      *)
        echo "Invalid option"
        ;;
    esac
  }

  # Cilium Health Check (^c^h)
  # Quick health overview of Cilium
  _ch() {
    is_cilium_available || return
    echo "=== Cilium Health Overview ==="
    echo "\n--- Cilium Status ---"
    cilium status 2>/dev/null || echo "Unable to fetch status"
    echo "\n--- Connectivity Status ---"
    cilium connectivity test --test-concurrency=1 --single-node=1 2>/dev/null | head -20 || echo "Quick connectivity check unavailable"
  }

  # Cilium Debug Info (^c^d)
  # Gather debug information from Cilium pod
  _cd() {
    is_cilium_available || return
    local pod
    pod="$(_cp)"
    if [ -n "$pod" ]; then
      local namespace="$(kubectl get pods -A -l k8s-app=cilium -o jsonpath='{.items[0].metadata.namespace}' 2>/dev/null || echo 'kube-system')"
      echo "=== Debug Info from $pod ==="
      echo "\n--- Cilium Version ---"
      kubectl exec -n "$namespace" "$pod" -c cilium-agent -- cilium version 2>/dev/null
      echo "\n--- Cilium Agent Status ---"
      kubectl exec -n "$namespace" "$pod" -c cilium-agent -- cilium status --brief 2>/dev/null
      echo "\n--- Recent Events ---"
      kubectl get events -n "$namespace" --field-selector involvedObject.name="$pod" --sort-by='.lastTimestamp' | tail -10
    fi
  }

  # Function to bind all Cilium helper functions to keyboard shortcuts
  bind-cilium-helper() {
    local c
    for c in $@; do
      eval "fzf-c$c-widget() { local result=\$(_c$c | join-lines); zle reset-prompt; LBUFFER+=\$result }"
      eval "zle -N fzf-c$c-widget"
      eval "bindkey '^c^$c' fzf-c$c-widget"
    done
  }

  # Bind Cilium helper functions
  # p=pods, s=status, t=connectivity-test, e=endpoints, m=monitor, l=policies, v=service-map, b=bpf-maps, u=hubble-ui, o=hubble-observe, h=health, d=debug
  bind-cilium-helper p s t e m l v b u o h d
  unset -f bind-cilium-helper
''
