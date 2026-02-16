# Kubernetes/kubectl Integration with FZF
# Interactive kubectl operations using fuzzy finder
# Commands: kfp (pods), kfn (namespace), kfc (context), kfl (logs),
#           kfe (exec), kfs (services), kfd (deployments), kfx (delete), kff (port-forward)
_: {
  programs.zsh.initContent = ''
    if command -v kubectl &>/dev/null; then
      # Kubernetes/kubectl Integration Helper Functions

      # Check if kubectl is available
      is_kubectl_available() {
        command -v kubectl > /dev/null 2>&1
      }

      # Standard FZF configuration for kubectl operations
      fzf-kube() {
        fzf --height 50% --min-height 20 --border --bind ctrl-/:toggle-preview "$@"
      }

      # Kubectl Pod Selector - kfp
      # Shows pods with details and allows selection
      kfp() {
        is_kubectl_available || return
        local namespace="$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)"
        namespace="''${namespace:-default}"

        kubectl get pods -n "$namespace" --no-headers -o custom-columns=":metadata.name,:status.phase,:spec.containers[*].name" |
        fzf-kube --ansi --multi \
          --preview "kubectl describe pod {1} -n $namespace" \
          --header "Namespace: $namespace (Use kfn to change)" \
          --preview-window right:60% |
        awk '{print $1}'
      }

      # Kubectl Namespace Selector - kfn
      # Browse and switch namespaces with resource preview
      kfn() {
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

      # Kubectl Context Selector - kfc
      # Browse and switch kubernetes contexts
      kfc() {
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

      # Kubectl Logs Viewer - kfl
      # Interactive pod log viewer with follow option
      kfl() {
        is_kubectl_available || return
        local namespace="$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)"
        namespace="''${namespace:-default}"

        local selected
        selected="$(kubectl get pods -n "$namespace" --no-headers -o custom-columns=":metadata.name,:spec.containers[*].name" |
        fzf-kube --ansi \
          --preview "kubectl logs {1} -n $namespace --tail=100 2>/dev/null || echo 'No logs available'" \
          --header 'Select pod to view logs (Enter=tail, Ctrl-F=follow)' \
          --bind "ctrl-f:execute(kubectl logs {1} -n $namespace -f)+abort" \
          --preview-window right:60%)"

        if [ -n "$selected" ]; then
          local pod="$(echo "$selected" | awk '{print $1}')"
          kubectl logs "$pod" -n "$namespace" --tail=100
        fi
      }

      # Kubectl Exec into Pod - kfe
      # Interactive pod shell access
      kfe() {
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

      # Kubectl Service Selector - kfs
      # Browse services with endpoint information
      kfs() {
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

      # Kubectl Deployment Selector - kfd
      # Browse deployments with replica status
      kfd() {
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

      # Kubectl Delete Resource - kfx
      # Interactive resource deletion with confirmation
      kfx() {
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

      # Kubectl Port Forward - kff
      # Interactive port forwarding setup
      kff() {
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
    fi
  '';
}
