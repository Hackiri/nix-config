{
  config,
  pkgs,
  inputs,
  username,
  ...
}: {
  imports = [
    ../../home/profiles/darwin.nix # Darwin-specific profile (includes desktop -> development -> minimal chain)
    ../../home/profiles/kube-dev.nix # Kubernetes development profile
  ];

  # Platform-specific home directory
  home.homeDirectory = "/Users/${username}";

  # Enable Kubernetes development profile
  profiles.kube-dev = {
    enable = true;
    toolset = "devops"; # Options: "devops" or "complete"
    includeLocalDev = true; # Include kind, tilt, kubeconform
  };

  # Host-specific packages
  home.packages = with pkgs; [
    # Add mbp-specific packages here
  ];
}
