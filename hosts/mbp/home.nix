{
  pkgs,
  username,
  ...
}: {
  imports = [
    ../../home/profiles/platform/darwin.nix # Darwin-specific profile (includes desktop -> development -> minimal chain)
    ../../home/profiles/features/kubernetes.nix # Kubernetes development profile
    ../../home/profiles/features/sops.nix # SOPS encrypted secrets (requires age key setup)
  ];

  # Platform-specific home directory
  home.homeDirectory = "/Users/${username}";

  # Enable SOPS encrypted secrets management
  profiles.sops.enable = true;

  # Enable Kubernetes development profile
  profiles.kubernetes = {
    enable = true;
    includeLocalDev = true; # Include kind, tilt, kubeconform
    toolSet = "complete"; # Full kubernetes tooling for primary workstation
  };

  # Host-specific packages
  home.packages = with pkgs; [
    # Add mbp-specific packages here
  ];
}
