# Kubernetes Development Profile
# Purpose: Kubernetes engineer workflow with remote cluster management and local development
# This profile can be imported standalone or added to existing profiles for Kubernetes capabilities.
#
# Usage:
#   imports = [ ../../home/profiles/features/kubernetes.nix ];
#
# Configuration:
#   profiles.kubernetes = {
#     enable = true;
#     toolset = "devops";  # or "complete"
#     includeLocalDev = true;
#   };
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.profiles.kubernetes;
in {
  options.profiles.kubernetes = with lib; {
    enable = mkEnableOption "Kubernetes development profile";

    toolset = mkOption {
      type = types.enum ["devops" "complete"];
      default = "devops";
      description = ''
        Kubernetes toolset to install:

        - devops: CI/CD and GitOps workflows (recommended for remote cluster management)
          Includes: kubectl, helm, kustomize, kubectx, kubecolor, argocd, flux,
          skaffold, tekton, terraform, pulumi, ansible, cloud CLIs (AWS/GCP/Azure),
          container tools (skopeo, dive, crane), CNI management (cilium-cli),
          and K8s distributions (talosctl, k0sctl)

        - complete: All available Kubernetes tools
          Includes: devops + observability (k9s, stern, popeye), security (kube-bench,
          kubesec), service mesh (istio, linkerd), helm plugins (helm-diff, helm-secrets),
          kubectl plugins (krew, kubectl-neat), and all extensions
      '';
    };

    includeLocalDev = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Include local Kubernetes development tools:
        - kind: Kubernetes in Docker for local clusters
        - tilt: Local development workflow automation
        - kubeconform: Fast Kubernetes manifests validator
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable Kubernetes tools module
    programs.kube = {
      enable = true;
      inherit (cfg) toolset;
    };

    # Add local development tools if enabled
    home.packages = lib.mkIf cfg.includeLocalDev (
      with pkgs; [
        kind # Kubernetes in Docker - lightweight local clusters
        tilt # Local development workflow automation
        kubeconform # Fast Kubernetes manifests validator
      ]
    );

    # Additional home configuration for Kubernetes workflows
    home.sessionVariables = {
      # Set default editor for kubectl edit
      KUBE_EDITOR = "nvim";
    };
  };
}
