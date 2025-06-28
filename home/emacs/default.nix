{
  config,
  pkgs,
  lib,
  ...
}: let
  emacs-enabled = config.programs.emacs.enable;
in {
  imports = [];

  programs.emacs = {
    enable = true;
    package = lib.mkForce pkgs.emacs30;
  };

  home = lib.mkIf emacs-enabled {
    activation = {
      setupDoomEmacs = lib.hm.dag.entryAfter ["writeBoundary"] ''
                # Define explicit paths to required binaries
                EMACS_BIN="${pkgs.emacs30}/bin/emacs"
                GIT_BIN="${pkgs.git}/bin/git"
                RIPGREP_BIN="${pkgs.ripgrep}/bin/rg"
                FD_BIN="${pkgs.fd}/bin/fd"

                # Create a temporary PATH with all required tools
                export PATH="${pkgs.emacs30}/bin:${pkgs.git}/bin:${pkgs.ripgrep}/bin:${pkgs.fd}/bin:$PATH"

                # Check Emacs version
                EMACS_VERSION=$("$EMACS_BIN" --version | head -n 1 | cut -d' ' -f3)
                echo "Found Emacs version: $EMACS_VERSION"
                # Use simple string comparison instead of bc
                if [[ "$EMACS_VERSION" < "28.0" ]]; then
                  echo "Warning: Doom Emacs works best with Emacs 28.0 or newer"
                fi

                # Ensure Doom Emacs is installed in $HOME/.config/emacs (newer XDG standard)
                if [ ! -d "$HOME/.config/emacs" ] || [ ! -f "$HOME/.config/emacs/bin/doom" ]; then
                  echo "Installing Doom Emacs..."
                  if [ -d "$HOME/.config/emacs" ]; then
                    mv "$HOME/.config/emacs" "$HOME/.config/emacs.bak-$(date +%Y%m%d%H%M%S)"
                  fi
                  "$GIT_BIN" clone --depth 1 https://github.com/doomemacs/doomemacs "$HOME/.config/emacs"
                fi

                # Set up environment variables for Doom Emacs
                export EMACSDIR="$HOME/.config/emacs"
                export DOOMDIR="$HOME/.config/doom"

                # Ensure Doom config directory exists
                mkdir -p "$DOOMDIR"

                # Use our custom Doom config files directly
                echo "Copying custom Doom Emacs configuration from nix-config..."

                # Copy init.el
                cp -f "${config.home.homeDirectory}/nix-config/home/emacs/doom.d/init.el" "$DOOMDIR/init.el" && \
                echo "Copied init.el from nix-config" || echo "Warning: Could not copy init.el from nix-config"

                # Copy config.el
                cp -f "${config.home.homeDirectory}/nix-config/home/emacs/doom.d/config.el" "$DOOMDIR/config.el" && \
                echo "Copied config.el from nix-config" || echo "Warning: Could not copy config.el from nix-config"

                # Copy packages.el
                cp -f "${config.home.homeDirectory}/nix-config/home/emacs/doom.d/packages.el" "$DOOMDIR/packages.el" && \
                echo "Copied packages.el from nix-config" || echo "Warning: Could not copy packages.el from nix-config"

                # Run Doom install if not already done
                if [ ! -d "$HOME/.local/share/doom" ]; then
                  echo "Running Doom Emacs install with explicit paths..."
                  # Create a script that sets all the necessary environment variables
                  cat > "$HOME/.config/doom/doom-install.sh" << EOF
        #!/bin/sh
        export PATH="${pkgs.emacs30}/bin:${pkgs.git}/bin:${pkgs.ripgrep}/bin:${pkgs.fd}/bin:$PATH"
        export EMACS="$EMACS_BIN"
        "$HOME/.config/emacs/bin/doom" install --force
        EOF
                  chmod +x "$HOME/.config/doom/doom-install.sh"

                  # Run the script
                  "$HOME/.config/doom/doom-install.sh"
                fi
      '';

      syncDoomEmacs = lib.hm.dag.entryAfter ["setupDoomEmacs"] ''
                if [ -f "$EMACSDIR/bin/doom" ]; then
                  echo "Syncing Doom Emacs configuration..."
                  # Define explicit paths to required binaries
                  EMACS_BIN="${pkgs.emacs30}/bin/emacs"
                  GIT_BIN="${pkgs.git}/bin/git"
                  RIPGREP_BIN="${pkgs.ripgrep}/bin/rg"
                  FD_BIN="${pkgs.fd}/bin/fd"

                  # Create a temporary PATH with all required tools
                  export PATH="${pkgs.emacs30}/bin:${pkgs.git}/bin:${pkgs.ripgrep}/bin:${pkgs.fd}/bin:$PATH"

                  # Create a script that sets all the necessary environment variables
                  cat > "$HOME/.config/doom/doom-sync.sh" << EOF
        #!/bin/sh
        export PATH="${pkgs.emacs30}/bin:${pkgs.git}/bin:${pkgs.ripgrep}/bin:${pkgs.fd}/bin:$PATH"
        export EMACS="$EMACS_BIN"

        # Sync packages and configuration (using the new command format)
        "$HOME/.config/emacs/bin/doom" profile sync --all

        # For GUI Emacs on macOS, generate env file
        "$HOME/.config/emacs/bin/doom" env
        EOF
                  chmod +x "$HOME/.config/doom/doom-sync.sh"

                  # Run the script
                  "$HOME/.config/doom/doom-sync.sh"
                fi
      '';

      # Optionally install Nerd Fonts for icon support
      # installNerdFonts = lib.hm.dag.entryAfter ["syncDoomEmacs"] ''
      #   ${pkgs.nerdfonts}/bin/nerd-fonts-install
      # '';

      # PATH is now managed in ZSH configuration
      # No need to modify .zshrc directly

      copyEmacsMacOSApp = lib.hm.dag.entryAfter ["writeBoundary"] ''
        baseDir="$HOME/Applications/Home Manager Apps"
        mkdir -p "$baseDir"

        # Check if we have write permissions to the directory
        if [ -w "$baseDir" ]; then
          # Try to set permissions, but don't fail if it doesn't work
          chmod u+w "$baseDir" 2>/dev/null || true
        else
          echo "Warning: No write permission for $baseDir. Skipping chmod."
        fi

        for app in ${pkgs.emacs30}/Applications/*; do
          target="$baseDir/$(basename "$app")"

          # Check if target exists and is writable
          if [ -e "$target" ] && [ -w "$target" ]; then
            $DRY_RUN_CMD rm -rf "$target" || echo "Warning: Could not remove $target"
          elif [ -e "$target" ]; then
            echo "Warning: Cannot remove $target (permission denied). Skipping..."
            continue
          fi

          # Copy the application only if source exists
          if [ -e "$app" ]; then
            $DRY_RUN_CMD cp -rL "$app" "$target" || echo "Warning: Could not copy $app to $target"

            # Only try to set permissions if the copy succeeded and we have write access
            if [ -e "$target" ] && [ -w "$target" ]; then
              $DRY_RUN_CMD chmod -R u+w "$target" 2>/dev/null || echo "Warning: Could not set permissions on $target"
            fi
          fi
        done
      '';
    };

    sessionVariables = {
      EMACSDIR = "${config.home.homeDirectory}/.config/emacs";
      DOOMDIR = "${config.home.homeDirectory}/.config/doom";
    };

    sessionPath = [
      "${config.home.homeDirectory}/.config/emacs/bin"
    ];

    packages = with pkgs; [
      # Core dependencies
      git
      (ripgrep.override {withPCRE2 = true;})
      fd

      # Development tools
      shellcheck
      nixfmt-classic

      # Language servers and formatters
      nodePackages.prettier
      nodePackages.typescript-language-server

      # Font support
      fontconfig
      emacs-all-the-icons-fonts
      jetbrains-mono
      nerd-fonts.jetbrains-mono

      # Additional dependencies
      gnutls
      imagemagick
      zstd
      sqlite
      editorconfig-core-c

      # Additional dependencies recommended for Doom Emacs
      coreutils # For GNU ls (gls)
      pandoc # For markdown processing
      shellcheck # For shell script linting
      aspell # For spell checking
      aspellDicts.en # English dictionary
      graphviz # For org-roam graph visualization

      # Build tools
      cmake
      gnumake
      gcc
      libtool
    ];
  };
}
