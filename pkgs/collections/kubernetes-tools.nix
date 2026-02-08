{pkgs}: let
  inherit (pkgs) lib;

  # Organized Kubernetes tool categories for better maintainability
  kubernetesTools = rec {
    # Essential Kubernetes core tools - always needed
    core = with pkgs; [
      kubectl # Kubernetes command-line tool
      kubernetes-helm # Kubernetes package manager (Helm 3)
      kustomize # Kubernetes native configuration management
    ];

    # Context and namespace management tools
    contextManagement = with pkgs; [
      kubectx # Fast context switching between clusters (includes kubens)
      kubecolor # Colorize kubectl output for better readability
      kubelogin-oidc # OIDC authentication plugin for kubectl
    ];

    # Monitoring, logging, and debugging tools
    observability = with pkgs;
      [
        stern # Multi-pod log tailing with color coding
        k9s # Terminal-based Kubernetes dashboard
        popeye # Kubernetes cluster resource sanitizer
      ]
      ++ lib.optionals (lib.hasAttr "kubectl-tree" pkgs) [
        kubectl-tree # Show Kubernetes object relationships in tree format
      ]
      ++ lib.optionals (lib.hasAttr "kubectl-who-can" pkgs) [
        kubectl-who-can # Show who can perform actions on Kubernetes resources
      ];

    # Security and compliance tools
    security = with pkgs;
      [
        kube-bench # CIS Kubernetes benchmark security scanner
      ]
      ++ lib.optionals (lib.hasAttr "kube-hunter" pkgs) [
        kube-hunter # Hunt for security weaknesses in Kubernetes clusters
      ]
      ++ lib.optionals (lib.hasAttr "kubesec" pkgs) [
        kubesec # Security risk analysis for Kubernetes resources
      ]
      ++ lib.optionals (lib.hasAttr "falco" pkgs) [
        falco # Runtime security monitoring
      ];

    # GitOps and CI/CD tools
    gitops = with pkgs; [
      argocd # GitOps continuous delivery CLI
      flux # GitOps toolkit CLI
      skaffold # Local development workflow automation
      tektoncd-cli # Tekton Pipelines CLI
    ];

    # Service mesh tools
    serviceMesh = with pkgs;
      [
        istioctl # Istio service mesh management
      ]
      ++ lib.optionals (lib.hasAttr "linkerd" pkgs) [
        linkerd # Linkerd service mesh CLI
      ]
      ++ lib.optionals (lib.hasAttr "cilium-cli" pkgs) [
        cilium-cli # CLI for Cilium CNI and service mesh
      ];

    # Container registry and image management tools (for remote clusters)
    containers = with pkgs; [
      skopeo # Work with container images and registries
      dive # Tool for exploring docker images layer by layer
      crane # Tool for interacting with remote images and registries
    ];

    # Infrastructure as Code
    iac = with pkgs; [
      opentofu # Infrastructure as code tool (open-source Terraform fork)
      terragrunt # Terraform wrapper for DRY configurations
      pulumi-bin # Modern infrastructure as code
      ansible # Configuration management and orchestration
    ];

    # Cloud provider CLIs
    cloudClis = with pkgs;
      [
        awscli2 # AWS CLI v2
        google-cloud-sdk # Google Cloud SDK
        azure-cli # Azure CLI
      ]
      ++ lib.optionals (lib.hasAttr "doctl" pkgs) [
        doctl # DigitalOcean CLI
      ];

    # Kubernetes distribution-specific tools
    distributions = with pkgs;
      [
        talosctl # CLI for Talos Linux management
      ]
      ++ lib.optionals (lib.hasAttr "rke2" pkgs && pkgs.stdenv.isLinux) [
        rke2 # Rancher Kubernetes Engine 2 (Linux only)
      ]
      ++ lib.optionals (lib.hasAttr "k0sctl" pkgs) [
        k0sctl # k0s cluster management
      ];

    # Helm plugins and extensions
    helmExtensions = with pkgs;
      [
        kubernetes-helmPlugins.helm-diff # Show diff between releases
        kubernetes-helmPlugins.helm-secrets # Manage secrets in Helm charts
        kubernetes-helmPlugins.helm-git # Install charts from git repositories
      ]
      ++ lib.optionals (lib.hasAttr "helm-docs" pkgs) [
        helm-docs # Generate documentation for Helm charts
      ];

    # kubectl plugins and extensions
    kubectlPlugins = with pkgs;
      [
        krew # kubectl plugin manager
      ]
      ++ lib.optionals (lib.hasAttr "kubectl-neat" pkgs) [
        kubectl-neat # Clean up Kubernetes yaml and json output
      ];

    # Networking and CNI management tools
    networking = with pkgs;
      lib.optionals (lib.hasAttr "cilium-cli" pkgs) [
        cilium-cli # CLI for Cilium CNI management
      ];

    # Development and testing utilities
    devUtils = with pkgs; [
      jq # JSON processor
      yq-go # YAML processor
      curl # HTTP client
      wget # HTTP client
      httpie # Human-friendly HTTP client
      grpcurl # gRPC client
      hey # HTTP load testing tool
      gettext
    ];

    # All tools combined for convenience (remote cluster focused)
    all =
      core
      ++ contextManagement
      ++ observability
      ++ security
      ++ gitops
      ++ serviceMesh
      ++ containers
      ++ iac
      ++ cloudClis
      ++ distributions
      ++ helmExtensions
      ++ kubectlPlugins
      ++ networking
      ++ devUtils;

    # Predefined tool sets for remote cluster management
    sets = {
      # Minimal set for basic remote cluster operations
      minimal = core ++ contextManagement;

      # Cluster administration set
      admin = core ++ contextManagement ++ observability ++ security ++ devUtils;

      # Operations set for production cluster management
      operations = core ++ contextManagement ++ observability ++ security ++ networking ++ distributions;

      # DevOps set for CI/CD and GitOps to remote clusters
      # Includes CNI management (Cilium) and modern K8s distributions (Talos)
      devops = core ++ contextManagement ++ gitops ++ iac ++ containers ++ cloudClis ++ networking ++ distributions;

      # Security-focused set for cluster auditing
      security-focused = core ++ security ++ observability ++ devUtils;

      # Service mesh management set
      mesh = core ++ contextManagement ++ serviceMesh ++ observability;

      # Complete remote cluster management toolkit
      complete = all;
    };
  };
in
  # Export the kubernetesTools record with all categories and sets
  kubernetesTools
