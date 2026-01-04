# Cilium Integration with FZF
# Interactive cilium operations using fuzzy finder
# Commands: cfp (pods), cfs (status), cft (test), cfe (endpoints), cfm (monitor),
#           cfl (policies), cfv (services), cfu (hubble-ui), cfo (observe), cfh (health), cfd (debug)
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

  # Cilium Pod Selector - cfp
  # Browse and select Cilium pods
  cfp() {
    is_cilium_available || return
    local namespace="$(kubectl get pods -A -l k8s-app=cilium -o jsonpath='{.items[0].metadata.namespace}' 2>/dev/null || echo 'kube-system')"

    kubectl get pods -n "$namespace" -l k8s-app=cilium --no-headers -o custom-columns=":metadata.name,:status.phase,:spec.nodeName" |
    fzf-cilium --ansi \
      --preview "kubectl describe pod {1} -n $namespace" \
      --header "Cilium pods in namespace: $namespace" \
      --preview-window right:60% |
    awk '{print $1}'
  }

  # Cilium Status - cfs
  # Interactive Cilium status viewer
  cfs() {
    is_cilium_available || return
    echo "=== Cilium Status ==="
    cilium status --wait 2>/dev/null || echo "Unable to fetch Cilium status"
  }

  # Cilium Connectivity Test - cft
  # Run Cilium connectivity tests
  cft() {
    is_cilium_available || return
    echo "Running Cilium connectivity test..."
    echo "This may take several minutes..."
    cilium connectivity test
  }

  # Cilium Endpoint Selector - cfe
  # Browse Cilium endpoints with detailed info
  cfe() {
    is_cilium_available || return
    local namespace="$(kubectl get pods -A -l k8s-app=cilium -o jsonpath='{.items[0].metadata.namespace}' 2>/dev/null || echo 'kube-system')"

    local pod
    pod="$(kubectl get pods -n "$namespace" -l k8s-app=cilium --no-headers -o custom-columns=":metadata.name,:status.phase,:spec.nodeName" |
    fzf-cilium --ansi \
      --preview "kubectl exec -n $namespace {1} -c cilium-agent -- cilium endpoint list 2>/dev/null || echo 'Unable to fetch endpoints'" \
      --header "Select Cilium pod to view endpoints" \
      --preview-window right:60% |
    awk '{print $1}')"

    if [ -n "$pod" ]; then
      kubectl exec -n "$namespace" "$pod" -c cilium-agent -- cilium endpoint list
    fi
  }

  # Cilium Monitor - cfm
  # Start Cilium monitor on selected pod
  cfm() {
    is_cilium_available || return
    local namespace="$(kubectl get pods -A -l k8s-app=cilium -o jsonpath='{.items[0].metadata.namespace}' 2>/dev/null || echo 'kube-system')"

    local pod
    pod="$(kubectl get pods -n "$namespace" -l k8s-app=cilium --no-headers -o custom-columns=":metadata.name,:status.phase,:spec.nodeName" |
    fzf-cilium --ansi \
      --preview "kubectl exec -n $namespace {1} -c cilium-agent -- cilium status --brief 2>/dev/null || echo 'Unable to fetch status'" \
      --header "Select Cilium pod to monitor" \
      --preview-window right:60% |
    awk '{print $1}')"

    if [ -n "$pod" ]; then
      echo "Starting Cilium monitor on $pod..."
      kubectl exec -n "$namespace" "$pod" -c cilium-agent -- cilium monitor
    fi
  }

  # Cilium Policy Selector - cfl
  # Browse and view Cilium network policies
  cfl() {
    is_cilium_available || return
    local namespace="$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)"
    namespace="''${namespace:-default}"

    kubectl get cnp,ccnp -A --no-headers -o custom-columns=":metadata.namespace,:metadata.name,:kind" 2>/dev/null |
    fzf-cilium --ansi \
      --preview "kubectl describe {3} {2} -n {1} 2>/dev/null" \
      --header 'Cilium Network Policies (CNP/CCNP)' \
      --preview-window right:60%
  }

  # Cilium Service Map - cfv
  # View cluster-wide service map (auto-selects first pod)
  cfv() {
    is_cilium_available || return
    local namespace="$(kubectl get pods -A -l k8s-app=cilium -o jsonpath='{.items[0].metadata.namespace}' 2>/dev/null || echo 'kube-system')"
    local pod="$(kubectl get pods -n "$namespace" -l k8s-app=cilium --no-headers -o custom-columns=":metadata.name" 2>/dev/null | head -1)"

    if [ -n "$pod" ]; then
      kubectl exec -n "$namespace" "$pod" -c cilium-agent -- cilium service list
    else
      echo "No Cilium pods found"
    fi
  }

  # Cilium Hubble UI - cfu
  # Open Hubble UI with port-forward
  cfu() {
    is_cilium_available || return
    echo "Starting Hubble UI port-forward on localhost:12000..."
    cilium hubble ui
  }

  # Cilium Hubble Observe - cfo
  # Interactive Hubble flow observation
  cfo() {
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

  # Cilium Health Check - cfh
  # Quick health overview of Cilium
  cfh() {
    is_cilium_available || return
    echo "=== Cilium Health Overview ==="
    echo "\n--- Cilium Status ---"
    cilium status 2>/dev/null || echo "Unable to fetch status"
    echo "\n--- Connectivity Status ---"
    cilium connectivity test --test-concurrency=1 --single-node=1 2>/dev/null | head -20 || echo "Quick connectivity check unavailable"
  }

  # Cilium Debug Info - cfd
  # Gather debug information from Cilium pod
  cfd() {
    is_cilium_available || return
    local namespace="$(kubectl get pods -A -l k8s-app=cilium -o jsonpath='{.items[0].metadata.namespace}' 2>/dev/null || echo 'kube-system')"

    local pod
    pod="$(kubectl get pods -n "$namespace" -l k8s-app=cilium --no-headers -o custom-columns=":metadata.name,:status.phase,:spec.nodeName" |
    fzf-cilium --ansi \
      --preview "echo '=== Version ===' && kubectl exec -n $namespace {1} -c cilium-agent -- cilium version 2>/dev/null && echo && echo '=== Status ===' && kubectl exec -n $namespace {1} -c cilium-agent -- cilium status --brief 2>/dev/null" \
      --header "Select Cilium pod for debug info" \
      --preview-window right:60% |
    awk '{print $1}')"

    if [ -n "$pod" ]; then
      echo "=== Debug Info from $pod ==="
      echo "\n--- Cilium Version ---"
      kubectl exec -n "$namespace" "$pod" -c cilium-agent -- cilium version 2>/dev/null
      echo "\n--- Cilium Agent Status ---"
      kubectl exec -n "$namespace" "$pod" -c cilium-agent -- cilium status --brief 2>/dev/null
      echo "\n--- Recent Events ---"
      kubectl get events -n "$namespace" --field-selector involvedObject.name="$pod" --sort-by='.lastTimestamp' | tail -10
    fi
  }
''
