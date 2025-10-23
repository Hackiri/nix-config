{
  pkgs,
  username,
  ...
}: {
  imports = [
    ../../home/profiles/platform/darwin.nix # Darwin-specific profile (includes desktop -> development -> minimal chain)
    ../../home/profiles/features/kubernetes.nix # Kubernetes development profile
  ];

  # Platform-specific home directory
  home.homeDirectory = "/Users/${username}";

  # Enable Kubernetes development profile
  profiles.kubernetes = {
    enable = true;
    toolset = "devops"; # Options: "devops" or "complete"
    includeLocalDev = true; # Include kind, tilt, kubeconform
  };

  # Host-specific packages
  home.packages = with pkgs; [
    # Add mbp-specific packages here
  ];
}
