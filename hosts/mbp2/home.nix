{
  config,
  pkgs,
  username,
  ...
}: {
  imports = [
    ../../home/profiles/platforms/darwin.nix # Darwin-specific profile (includes development -> foundation chain)
    ../../home/packages/development # Development package bundles selected by direct import
    ../../home/profiles/capabilities/kubernetes.nix # Kubernetes development capability
    ../../home/profiles/capabilities/sops.nix # SOPS encrypted secrets (requires age key setup)
    ../../home/profiles/capabilities/redis.nix # Local Redis user service
    ../../home/profiles/capabilities/agent-dev.nix # Optional AI agent development workflow
  ];

  # Platform-specific home directory
  home.homeDirectory = "/Users/${username}";

  profiles = {
    # Enable SOPS encrypted secrets management
    sops = {
      enable = true;
      signingKeySecret = "git-signingKey-mbp2";
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

    # Local Redis service for development
    redis.enable = false;

    # AI agent development workflow
    agentDev = {
      enable = true;
      hermes.enable = true;
    };

    # Development profile controls
    # Set any of these to false or change values to tailor the workstation setup.
    development = {
      enable = true;

      editors = {
        enable = true;
        neovim.enable = true;
        emacs.enable = true;
        neovide.enable = true;
      };

      shells.enable = true;
      utilities.enable = true;

      terminals = {
        enable = true;
        default = "kitty";
      };
    };
  };

  # Host-specific packages
  home.packages = with pkgs; [
    # Add mbp2-specific packages here
  ];
}
