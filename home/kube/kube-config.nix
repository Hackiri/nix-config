{
  config,
  lib,
  pkgs,
  ...
}: {
  options.programs.kube = with lib; {
    enable = mkEnableOption "kubernetes tools configuration";
  };

  config = lib.mkIf config.programs.kube.enable {
    home.packages = with pkgs;
    # Import the kubernetes-tools package set
      (import ../pkgs {inherit pkgs;}).kubernetes-tools;

    # Kubernetes-specific shell configuration
    programs.zsh.initContent = lib.mkIf config.programs.zsh.enable ''
      # Kubernetes prompt info (if kube-ps1 is installed)
      if command -v kube-ps1 &> /dev/null; then
        source "$(which kube-ps1)"
        PROMPT='$(kube_ps1)'"$PROMPT"
      fi

      # Kubectl completion
      if command -v kubectl &> /dev/null; then
        source <(kubectl completion zsh)
      fi

      # Helm completion
      if command -v helm &> /dev/null; then
        source <(helm completion zsh)
      fi
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
    '';
  };
}
