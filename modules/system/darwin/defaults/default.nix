# macOS system defaults — imports all preference sub-modules
_: {
  imports = [
    ./input.nix
    ./finder.nix
    ./dock.nix
    ./privacy.nix
    ./apps.nix
  ];

  # TouchID for sudo authentication (including tmux via pam-reattach)
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };
}
