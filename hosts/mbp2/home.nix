{
  pkgs,
  username,
  ...
}: {
  imports = [
    ../../home/profiles/platforms/darwin.nix # Darwin-specific profile (includes development -> foundation chain)
    ../../home/programs # Program modules managed from home/programs/default.nix
    ../../home/profiles/capabilities/kubernetes.nix # Kubernetes development capability
    #./sops.nix # SOPS encrypted secrets; comment this import out to disable
    ../../home/profiles/capabilities/agent-dev.nix # Optional AI agent development workflow
  ];

  # Full kubernetes tooling for primary workstation.
  profiles.kubernetes.toolSet = "complete";

  home = {
    # Platform-specific home directory
    homeDirectory = "/Users/${username}";
    stateVersion = "25.05";

    # Host-specific packages
    packages = with pkgs; [
      # Add mbp2-specific packages here
    ];
  };
}
