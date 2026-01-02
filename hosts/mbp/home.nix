{
  pkgs,
  username,
  ...
}: {
  imports = [
    ../../home/profiles/platform/darwin.nix # Darwin-specific profile (includes desktop -> development -> minimal chain)
    ../../home/profiles/features/kubernetes.nix # Kubernetes development profile

    # Sops-encrypted git credentials (requires age key setup)
    # Remove these two imports for basic git without sops dependency
    ../../home/profiles/base/git.nix # Git with sops hooks
    ../../home/profiles/base/secrets.nix # Sops CLI utilities
  ];

  # Platform-specific home directory
  home.homeDirectory = "/Users/${username}";

  # Enable Kubernetes development profile
  profiles.kubernetes = {
    enable = true;
    toolset = "complete"; # Options: "minimal", "admin", "operations", "devops", "security-focused", "mesh", or "complete"
    includeLocalDev = true; # Include kind, tilt, kubeconform
  };

  # Host-specific packages
  home.packages = with pkgs; [
    # Add mbp-specific packages here
  ];
}
