# Darwin system configuration
{
  config,
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
    
    # Feature modules
    ../../features/fonts.nix
    
    # Service modules
    ../../services/homebrew.nix
  ];

  # Enable features
  features.fonts.enable = true;
  services.homebrew.enable = true;

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
    postActivation.text = ''
      # Add pam_reattach to enable TouchID for tmux
      sudo mkdir -p /usr/local/lib/pam
      sudo cp ${pkgs.pam-reattach}/lib/pam/pam_reattach.so /usr/local/lib/pam/

      # Add pam_reattach to sudo config if not already present
      if ! grep -q "pam_reattach.so" /etc/pam.d/sudo; then
        sudo sed -i "" '2i\
      auth    optional    pam_reattach.so
      ' /etc/pam.d/sudo
      fi
    '';

    # Add Podman Docker compatibility setup
    podmanDockerCompat.text = ''
            # Set up Podman for Docker compatibility
            echo "Setting up Podman for Docker compatibility..." >&2

            # Create Docker compatibility symlinks
            mkdir -p $HOME/.local/bin
            ln -sf $(which podman) $HOME/.local/bin/docker
            ln -sf $(which podman-compose) $HOME/.local/bin/docker-compose

            # Ensure the bin directory is in PATH
            if ! grep -q "$HOME/.local/bin" $HOME/.zshrc; then
              echo 'export PATH="$HOME/.local/bin:$PATH"' >> $HOME/.zshrc
            fi

            # Set up Docker socket compatibility
            mkdir -p $HOME/.docker

            # Create systemd user directory if it doesn't exist
            mkdir -p $HOME/.config/systemd/user

            # Create the service file for podman socket
            cat > $HOME/.config/systemd/user/podman.socket << EOF
      [Unit]
      Description=Podman API Socket
      Documentation=man:podman-system-service(1)

      [Socket]
      ListenStream=%t/podman/podman.sock
      SocketMode=0660

      [Install]
      WantedBy=sockets.target
      EOF

            # Create the service file
            cat > $HOME/.config/systemd/user/podman.service << EOF
      [Unit]
      Description=Podman API Service
      Requires=podman.socket
      After=podman.socket
      Documentation=man:podman-system-service(1)

      [Service]
      Type=simple
      ExecStart=/usr/local/bin/podman system service --time=0

      [Install]
      WantedBy=default.target
      EOF

            # Add Docker environment variables to zshrc if not already present
            if ! grep -q "DOCKER_HOST" $HOME/.zshrc; then
              echo 'export DOCKER_HOST="unix://$HOME/.local/share/containers/podman/machine/qemu/podman.sock"' >> $HOME/.zshrc
            fi
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
