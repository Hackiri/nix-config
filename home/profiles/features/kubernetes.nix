# Kubernetes Development Profile
# Purpose: Kubernetes engineer workflow with remote cluster management and local development
# This profile wraps programs.kube and adds local development tools.
#
# Usage:
#   imports = [ ../../home/profiles/features/kubernetes.nix ];
#
# Configuration:
#   profiles.kubernetes = {
#     enable = true;
#     toolset = "complete";  # minimal, admin, operations, devops, security-focused, mesh, or complete
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
      type = types.enum ["minimal" "admin" "operations" "devops" "security-focused" "mesh" "complete"];
      default = "complete";
      description = ''
        Kubernetes toolset to install (see programs.kube.toolset for details):
        - minimal: Core tools only (kubectl, helm, kustomize, kubectx, kubecolor)
        - admin: For cluster administration (core + observability + security)
        - operations: For production cluster management
        - devops: For CI/CD and GitOps workflows
        - security-focused: For cluster security auditing
        - mesh: For service mesh management
        - complete: All available tools
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
