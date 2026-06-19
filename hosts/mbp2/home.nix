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
    #./sops.nix # SOPS encrypted secrets; comment this import out to disable
    ../../home/profiles/capabilities/agent-dev.nix # Optional AI agent development workflow
  ];

  # Platform-specific home directory
  home.homeDirectory = "/Users/${username}";

  # Full kubernetes tooling for primary workstation.
  profiles.kubernetes.toolSet = "complete";

  # Host-specific packages
  home.packages = with pkgs; [
    # Add mbp2-specific packages here
  ];
}
