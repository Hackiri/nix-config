# Darwin system configuration
{
  lib,
  pkgs,
  system,
  username,
  ...
}: {
  imports = [
    # Shared system modules
    ../shared/nix.nix
    ../shared/users.nix

    # Darwin-specific modules
    ./defaults.nix

    # Optional feature modules
    ../../optional-features/fonts.nix

    # Service modules
    ../../services/homebrew.nix
  ];

  # Enable features
  features.fonts.enable = true;
  services.homebrew.enable = true;

  # Disable doc output to avoid builtins.toFile warning with options.json
  # Man pages and info pages remain enabled (their defaults)
  documentation.doc.enable = false;

  # System configuration
  system = {
    stateVersion = 6;
  };

  # Platform-specific nixpkgs configuration
  nixpkgs = {
    hostPlatform = lib.mkDefault "${system}";
  };

  # Configure activation scripts
  system.activationScripts = {
    # Security: Enable macOS Application Firewall
    firewall.text = ''
      echo "Configuring macOS Firewall..." >&2
      /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on || echo "Warning: Failed to enable firewall" >&2
      /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on || echo "Warning: Failed to enable stealth mode" >&2
      /usr/libexec/ApplicationFirewall/socketfilterfw --setloggingmode on || echo "Warning: Failed to enable firewall logging" >&2
    '';

    postActivation.text = ''
      # Add pam_reattach to enable TouchID for tmux sessions
      echo "Configuring pam_reattach for TouchID in tmux..." >&2
      sudo mkdir -p /usr/local/lib/pam
      sudo cp ${pkgs.pam-reattach}/lib/pam/pam_reattach.so /usr/local/lib/pam/ || echo "Warning: Failed to copy pam_reattach.so" >&2

      if ! grep -q "pam_reattach.so" /etc/pam.d/sudo; then
        sudo sed -i "" '2i\
      auth    optional    pam_reattach.so
      ' /etc/pam.d/sudo || echo "Warning: Failed to configure pam_reattach in /etc/pam.d/sudo" >&2
      fi
    '';

    # Podman Docker compatibility: symlinks only (no systemd, no PATH manipulation)
    podmanDockerCompat.text = ''
      echo "Setting up Podman Docker compatibility symlinks..." >&2
      mkdir -p $HOME/.local/bin
      ln -sf $(which podman) $HOME/.local/bin/docker 2>/dev/null || true
      ln -sf $(which podman-compose) $HOME/.local/bin/docker-compose 2>/dev/null || true
      mkdir -p $HOME/.docker
    '';
  };

  # Home Manager configuration
  home-manager.users.${username} = _: {
    home.sessionPath = [
      "/run/current-system/sw/bin"
      "$HOME/.nix-profile/bin"
    ];
  };
}
