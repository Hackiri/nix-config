{
  pkgs,
  username,
  ...
}: {
  imports = [
    ../../home/profiles/platforms/darwin.nix # Darwin-specific profile (includes development -> foundation chain)
    ../../home/packages/development # Development package bundles selected by direct import
    ../../home/programs # Program modules managed from home/programs/default.nix
    ../../home/profiles/capabilities/kubernetes.nix # Kubernetes development capability
    ./sops.nix # SOPS encrypted secrets; comment this import out to disable
    ../../home/profiles/capabilities/redis.nix # Local Redis user service
    ../../home/profiles/capabilities/agent-dev.nix # Optional AI agent development workflow
  ];

  # Platform-specific home directory
  home.homeDirectory = "/Users/${username}";

  profiles = {
    # Enable Kubernetes development profile
    kubernetes = {
      enable = true;
      includeLocalDev = true; # Include kind, tilt, kubeconform
      toolSet = "complete"; # Full kubernetes tooling for primary workstation
    };

    # Local Redis service for development
    redis.enable = false;

    # AI agent development workflow
    agentDev = {
      enable = true;
      hermes.enable = true;
    };
  };

  # Host-specific packages
  home.packages = with pkgs; [
    # Add mbp2-specific packages here
  ];
}
