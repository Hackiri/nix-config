# Custom Packages

Custom Nix packages exported by this flake.

## Structure

```
pkgs/
├── default.nix                      # Package collection exports
├── collections/
│   └── kubernetes-tools.nix         # Kubernetes and cloud-native tools
└── README.md
```

## Kubernetes Tools (`collections/kubernetes-tools.nix`)

A curated collection of Kubernetes and cloud-native tools organized by category. Used by the `features.kubernetes` profile to provide selectable tool sets.

### Tool Categories

| Category | Tools | Description |
|---|---|---|
| `core` | kubectl, helm, kustomize | Essential Kubernetes tools |
| `contextManagement` | kubectx, kubecolor, kubelogin-oidc | Cluster context switching |
| `observability` | stern, k9s, popeye, kubectl-tree, kubectl-who-can | Monitoring and debugging |
| `security` | kube-bench, kube-hunter, kubesec, falco | Security scanning and auditing |
| `gitops` | argocd, flux, skaffold, tektoncd-cli | GitOps and CI/CD |
| `serviceMesh` | istioctl, linkerd, cilium-cli | Service mesh management |
| `containers` | skopeo, dive, crane | Container image tools |
| `iac` | opentofu, terragrunt, pulumi, ansible | Infrastructure as Code |
| `cloudClis` | awscli2, google-cloud-sdk, azure-cli, doctl | Cloud provider CLIs |
| `distributions` | talosctl, rke2, k0sctl | K8s distribution tools |
| `helmExtensions` | helm-diff, helm-secrets, helm-git, helm-docs | Helm plugins |
| `devUtils` | jq, yq-go, curl, wget, httpie, grpcurl, hey | Development utilities |

### Predefined Sets

Sets compose categories into role-based collections:

```nix
kubernetesTools.sets.minimal          # core + contextManagement
kubernetesTools.sets.admin            # core + context + observability + security + devUtils
kubernetesTools.sets.operations       # core + context + observability + security + networking + distributions
kubernetesTools.sets.devops           # core + context + gitops + iac + containers + cloudClis + networking + distributions
kubernetesTools.sets.security-focused # core + security + observability + devUtils
kubernetesTools.sets.mesh             # core + context + serviceMesh + observability
kubernetesTools.sets.complete         # all categories
```

### Usage

```nix
# In a home-manager or NixOS configuration
let
  customPkgs = import ./pkgs { inherit pkgs; };
in {
  # Use a predefined set
  home.packages = customPkgs.kubernetes-tools.sets.devops;

  # Or pick individual categories
  home.packages = customPkgs.kubernetes-tools.core
    ++ customPkgs.kubernetes-tools.observability;

  # Or use the convenience buildEnv with everything
  home.packages = [ customPkgs.kube-packages ];
}
```

Platform availability is handled automatically — some tools use `lib.optionals` to skip packages that are unavailable or Linux-only.
