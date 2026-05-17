{
  config,
  pkgs,
  username,
  ...
}: {
  imports = [
    ../../home/profiles/platforms/darwin.nix # Darwin-specific profile (includes development -> foundation chain)
    ../../home/profiles/capabilities/kubernetes.nix # Kubernetes development capability
    ../../home/profiles/capabilities/sops.nix # SOPS encrypted secrets (requires age key setup)
    ../../home/profiles/capabilities/redis.nix # Local Redis user service
  ];

  # Platform-specific home directory
  home.homeDirectory = "/Users/${username}";

  profiles = {
    # Enable SOPS encrypted secrets management
    sops = {
      enable = true;
      signingKeySecret = "git-signingKey-mbp";
      extraSecrets = {
        ssh-config-srv696730 = {
          path = "${config.home.homeDirectory}/.ssh/conf.d/srv696730";
          mode = "0600";
        };
      };
    };

    # Enable Kubernetes development profile
    kubernetes = {
      enable = true;
      includeLocalDev = true; # Include kind, tilt, kubeconform
      toolSet = "complete"; # Full kubernetes tooling for primary workstation
    };

    # Enable local Redis service for development
    redis.enable = true;
  };

  # Host-specific packages
  home.packages = with pkgs; [
    # Add mbp-specific packages here
  ];
}
