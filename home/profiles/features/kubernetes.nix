# Kubernetes Development Profile
# Purpose: Kubernetes engineer workflow with remote cluster management and local development
#
# Usage:
#   imports = [ ../../home/profiles/features/kubernetes.nix ];
#
# Configuration:
#   profiles.kubernetes = {
#     enable = true;
#     includeLocalDev = true;
#   };
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.profiles.kubernetes;
  kubernetesTools = import ../../../pkgs/collections/kubernetes-tools.nix {inherit pkgs;};
in {
  options.profiles.kubernetes = with lib; {
    enable = mkEnableOption "Kubernetes development profile";

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

    toolSet = mkOption {
      type = types.enum ["minimal" "admin" "operations" "devops" "complete"];
      default = "admin";
      description = ''
        Which kubernetes tool set to install. Options:
        - minimal: kubectl, helm, k9s
        - admin: minimal + context/namespace tools, observability
        - operations: admin + gitops, security scanning
        - devops: operations + IaC tools (tofu, ansible)
        - complete: everything including all cloud CLIs
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages =
        kubernetesTools.sets.${cfg.toolSet}
        ++ lib.optionals cfg.includeLocalDev (
          with pkgs; [
            kind # Kubernetes in Docker - lightweight local clusters
            tilt # Local development workflow automation
            kubeconform # Fast Kubernetes manifests validator
          ]
        );

      sessionVariables = {
        KUBE_EDITOR = "nvim";
      };

      # k9s configuration
      file.".config/k9s/config.yml".text = builtins.readFile ./k9s/config.yml;
      file.".config/k9s/skin.yml".text = builtins.readFile ./k9s/skin.yml;
    };

    # Kubernetes-specific shell configuration
    programs.zsh.initContent = lib.mkIf config.programs.zsh.enable ''
      # Kubecolor integration (colorized kubectl output)
      if command -v kubecolor &> /dev/null; then
        alias kubectl="kubecolor"
        # Make completion work with kubecolor
        compdef kubecolor=kubectl
      fi

      # Helm completion (oh-my-zsh doesn't include this)
      if command -v helm &> /dev/null; then
        source <(helm completion zsh)
        compdef h=helm
      fi

      # Additional kubectl completions for custom aliases
      if command -v kubectl &> /dev/null; then
        # Enable kubectl autocompletion for aliases not covered by oh-my-zsh
        compdef kns=kubectl
        compdef kgaa=kubectl
        compdef kgpsn=kubectl
        compdef krestartpo=kubectl
      fi

      # K9s configuration
      export K9S_CONFIG_DIR="$HOME/.config/k9s"

      # Krew PATH is set via home.sessionPath in zsh/default.nix
    '';

    # Add bash completion if bash is enabled
    programs.bash.initExtra = lib.mkIf config.programs.bash.enable ''
      # Kubectl completion
      if command -v kubectl &> /dev/null; then
        source <(kubectl completion bash)
      fi

      # Helm completion
      if command -v helm &> /dev/null; then
        source <(helm completion bash)
      fi

      # Kubecolor integration for bash
      if command -v kubecolor &> /dev/null; then
        alias kubectl="kubecolor"
      fi
    '';
  };
}
