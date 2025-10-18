# Kubernetes/kubectl Integration with FZF
# Interactive kubectl operations using fuzzy finder
# Keybindings: Ctrl+K followed by Ctrl+[key]
_: ''
  # Kubernetes/kubectl Integration Helper Functions

  # Check if kubectl is available
  is_kubectl_available() {
    command -v kubectl > /dev/null 2>&1
  }

  # Standard FZF configuration for kubectl operations
  fzf-kube() {
    fzf --height 50% --min-height 20 --border --bind ctrl-/:toggle-preview "$@"
  }

  # Kubectl Pod Selector (^k^p)
  # Shows pods with details and allows selection
  _kp() {
    is_kubectl_available || return
    local namespace="$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)"
    namespace="''${namespace:-default}"

    kubectl get pods -n "$namespace" --no-headers -o custom-columns=":metadata.name,:status.phase,:spec.containers[*].name" |
    fzf-kube --ansi --multi \
      --preview "kubectl describe pod {1} -n $namespace" \
      --header "Namespace: $namespace (Use ^k^n to change)" \
      --preview-window right:60% |
    awk '{print $1}'
  }

  # Kubectl Namespace Selector (^k^n)
  # Browse and switch namespaces with resource preview
  _kn() {
    is_kubectl_available || return
    local selected_ns
    selected_ns="$(kubectl get namespaces --no-headers -o custom-columns=":metadata.name,:status.phase,:metadata.creationTimestamp" |
    fzf-kube --ansi \
      --preview "echo '=== Pods ===' && kubectl get pods -n {1} 2>/dev/null | head -20 && echo && echo '=== Services ===' && kubectl get svc -n {1} 2>/dev/null | head -10" \
      --header 'Select namespace to switch to' \
      --preview-window right:60% |
    awk '{print $1}')"

    if [ -n "$selected_ns" ]; then
      kubectl config set-context --current --namespace="$selected_ns"
      echo "Switched to namespace: $selected_ns"
    fi
  }

  # Kubectl Context Selector (^k^c)
  # Browse and switch kubernetes contexts
  _kc() {
    is_kubectl_available || return
    local selected_context
    selected_context="$(kubectl config get-contexts --no-headers -o name |
    fzf-kube --ansi \
      --preview "kubectl config view --context={} --minify | bat --style=plain --color=always -l yaml" \
      --header 'Select context to switch to' \
      --preview-window right:60%)"

    if [ -n "$selected_context" ]; then
      kubectl config use-context "$selected_context"
      echo "Switched to context: $selected_context"
    fi
  }

  # Kubectl Logs Viewer (^k^l)
  # Interactive pod log viewer with follow option
  _kl() {
    is_kubectl_available || return
    local namespace="$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)"
    namespace="''${namespace:-default}"

    local selected
    selected="$(kubectl get pods -n "$namespace" --no-headers -o custom-columns=":metadata.name,:spec.containers[*].name" |
    fzf-kube --ansi \
      --preview "kubectl logs {1} -n $namespace --tail=50 2>/dev/null || echo 'No logs available'" \
      --header 'Select pod to view logs (Enter=tail, Ctrl-F=follow)' \
      --bind "ctrl-f:execute(kubectl logs {1} -n $namespace -f)+abort" \
      --preview-window right:60%)"

    if [ -n "$selected" ]; then
      local pod="$(echo "$selected" | awk '{print $1}')"
      kubectl logs "$pod" -n "$namespace" --tail=100
    fi
  }

  # Kubectl Exec into Pod (^k^e)
  # Interactive pod shell access
  _ke() {
    is_kubectl_available || return
    local namespace="$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)"
    namespace="''${namespace:-default}"

    local selected
    selected="$(kubectl get pods -n "$namespace" --no-headers -o custom-columns=":metadata.name,:status.phase,:spec.containers[*].name" |
    fzf-kube --ansi \
      --preview "kubectl describe pod {1} -n $namespace" \
      --header 'Select pod to exec into' \
      --preview-window right:60%)"

    if [ -n "$selected" ]; then
      local pod="$(echo "$selected" | awk '{print $1}')"
      local containers="$(echo "$selected" | awk '{print $3}')"

      # If multiple containers, let user select
      if [[ "$containers" == *","* ]]; then
        local container="$(echo "$containers" | tr ',' '\n' | fzf-kube --header 'Select container')"
        kubectl exec -it "$pod" -n "$namespace" -c "$container" -- /bin/sh -c 'bash || ash || sh'
      else
        kubectl exec -it "$pod" -n "$namespace" -- /bin/sh -c 'bash || ash || sh'
      fi
    fi
  }

  # Kubectl Service Selector (^k^s)
  # Browse services with endpoint information
  _ks() {
    is_kubectl_available || return
    local namespace="$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)"
    namespace="''${namespace:-default}"

    kubectl get svc -n "$namespace" --no-headers -o custom-columns=":metadata.name,:spec.type,:spec.clusterIP,:spec.ports[*].port" |
    fzf-kube --ansi --multi \
      --preview "kubectl describe svc {1} -n $namespace && echo && echo '=== Endpoints ===' && kubectl get endpoints {1} -n $namespace" \
      --header "Services in namespace: $namespace" \
      --preview-window right:60% |
    awk '{print $1}'
  }

  # Kubectl Deployment Selector (^k^d)
  # Browse deployments with replica status
  _kd() {
    is_kubectl_available || return
    local namespace="$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)"
    namespace="''${namespace:-default}"

    kubectl get deployments -n "$namespace" --no-headers -o custom-columns=":metadata.name,:spec.replicas,:status.availableReplicas,:status.updatedReplicas" |
    fzf-kube --ansi --multi \
      --preview "kubectl describe deployment {1} -n $namespace && echo && echo '=== Pods ===' && kubectl get pods -n $namespace -l app={1}" \
      --header "Deployments in namespace: $namespace" \
      --preview-window right:60% |
    awk '{print $1}'
  }

  # Kubectl Delete Resource (^k^x)
  # Interactive resource deletion with confirmation
  _kx() {
    is_kubectl_available || return
    local namespace="$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)"
    namespace="''${namespace:-default}"

    echo "Select resource type to delete:"
    local resource_type="$(echo -e "pod\ndeployment\nservice\nconfigmap\nsecret\ningress" | fzf-kube --header 'Select resource type')"

    if [ -n "$resource_type" ]; then
      local selected
      selected="$(kubectl get "$resource_type" -n "$namespace" --no-headers -o custom-columns=":metadata.name" |
      fzf-kube --ansi --multi \
        --preview "kubectl describe $resource_type {1} -n $namespace" \
        --header "Select $resource_type to DELETE (TAB for multi-select)" \
        --preview-window right:60%)"

      if [ -n "$selected" ]; then
        echo "$selected" | while read -r resource; do
          echo "Deleting $resource_type: $resource"
          kubectl delete "$resource_type" "$resource" -n "$namespace"
        done
      fi
    fi
  }

  # Kubectl Port Forward (^k^f)
  # Interactive port forwarding setup
  _kf() {
    is_kubectl_available || return
    local namespace="$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)"
    namespace="''${namespace:-default}"

    local selected
    selected="$(kubectl get pods -n "$namespace" --no-headers -o custom-columns=":metadata.name,:spec.containers[*].ports" |
    fzf-kube --ansi \
      --preview "kubectl describe pod {1} -n $namespace" \
      --header 'Select pod for port forwarding' \
      --preview-window right:60%)"

    if [ -n "$selected" ]; then
      local pod="$(echo "$selected" | awk '{print $1}')"
      echo "Enter port (local:remote or just remote):"
      read port
      if [ -n "$port" ]; then
        kubectl port-forward "$pod" -n "$namespace" "$port"
      fi
    fi
  }

  # Function to bind all kubectl helper functions to keyboard shortcuts
  # Creates widgets and binds them to ctrl-k + ctrl-[key] combinations
  bind-kubectl-helper() {
    local c
    for c in $@; do
      # Create widget function that calls the corresponding _k[key] function
      eval "fzf-k$c-widget() { local result=\$(_k$c | join-lines); zle reset-prompt; LBUFFER+=\$result }"
      # Register the widget with ZLE (Zsh Line Editor)
      eval "zle -N fzf-k$c-widget"
      # Bind widget to ctrl-k + ctrl-[key]
      eval "bindkey '^k^$c' fzf-k$c-widget"
    done
  }

  # Bind kubectl helper functions
  # p=pods, n=namespace, c=context, l=logs, e=exec, s=services, d=deployments, x=delete, f=port-forward
  bind-kubectl-helper p n c l e s d x f
  unset -f bind-kubectl-helper
''
