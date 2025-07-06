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

        # Create required snippet directories if they don't exist
        if [ ! -d "$DOOMDIR/snippets" ]; then
          echo "Creating snippets directory..."
          mkdir -p "$DOOMDIR/snippets"
        fi

        if [ ! -d "$DOOMDIR/etc/snippets" ]; then
          echo "Creating etc/snippets directory..."
          mkdir -p "$DOOMDIR/etc/snippets"
        fi

        # Use our custom Doom config files directly
        echo "Copying custom Doom Emacs configuration from nix-config..."

        # Run doom sync to update packages and configuration
        echo "Running doom sync to update packages..."
        "$EMACSDIR/bin/doom" sync

        # Copy init.el
        cp -f "${config.home.homeDirectory}/nix-config/home/emacs/doom.d/init.el" "$DOOMDIR/init.el" && \
        echo "Copied init.el from nix-config" || echo "Warning: Could not copy init.el from nix-config"

        # Copy config.el
        cp -f "${config.home.homeDirectory}/nix-config/home/emacs/doom.d/config.el" "$DOOMDIR/config.el" && \
        echo "Copied config.el from nix-config" || echo "Warning: Could not copy config.el from nix-config"

        # Copy packages.el
        cp -f "${config.home.homeDirectory}/nix-config/home/emacs/doom.d/packages.el" "$DOOMDIR/packages.el" && \
        echo "Copied packages.el from nix-config" || echo "Warning: Could not copy packages.el from nix-config"

        # Create custom.el if it doesn't exist (optional)
        if [ ! -f "$DOOMDIR/custom.el" ]; then
          touch "$DOOMDIR/custom.el" && \
          echo "Created empty custom.el" || echo "Warning: Could not create custom.el"
        fi

        # Set proper permissions
        chmod -R u+w "$DOOMDIR" || echo "Warning: Could not set permissions on $DOOMDIR"

        # Ensure the Doom binary is executable
        chmod +x "$EMACSDIR/bin/doom" || echo "Warning: Could not make doom binary executable"

        # Run Doom sync to ensure all packages are installed
        echo "Running doom sync to ensure all packages are installed..."
        "$EMACSDIR/bin/doom" sync
      '';

      # Setup desktop files for Emacs
      setupEmacsDesktopFiles = lib.hm.dag.entryAfter ["writeBoundary"] ''
                # Create desktop files for Emacs and Doom Emacs
                mkdir -p "$HOME/.local/share/applications"

                # Regular Emacs desktop file
                cat > "$HOME/.local/share/applications/emacs.desktop" << EOF
        [Desktop Entry]
        Name=Emacs
        GenericName=Text Editor
        Comment=Edit text
        MimeType=text/english;text/plain;text/x-makefile;text/x-c++hdr;text/x-c++src;text/x-chdr;text/x-csrc;text/x-java;text/x-moc;text/x-pascal;text/x-tcl;text/x-tex;application/x-shellscript;text/x-c;text/x-c++;
        Exec=${pkgs.emacs30}/bin/emacs %F
        Icon=${pkgs.emacs30}/share/icons/hicolor/scalable/apps/emacs.svg
        Type=Application
        Terminal=false
        Categories=Development;TextEditor;
        StartupWMClass=Emacs
        Keywords=Text;Editor;
        EOF
                echo "Created emacs.desktop file"

                # Doom Emacs desktop file
                cat > "$HOME/.local/share/applications/doom-emacs.desktop" << EOF
        [Desktop Entry]
        Name=Doom Emacs
        GenericName=Text Editor
        Comment=Emacs with Doom configuration
        MimeType=text/english;text/plain;text/x-makefile;text/x-c++hdr;text/x-c++src;text/x-chdr;text/x-csrc;text/x-java;text/x-moc;text/x-pascal;text/x-tcl;text/x-tex;application/x-shellscript;text/x-c;text/x-c++;
        Exec=${pkgs.emacs30}/bin/emacs %F
        Icon=${pkgs.emacs30}/share/icons/hicolor/scalable/apps/emacs.svg
        Type=Application
        Terminal=false
        Categories=Development;TextEditor;
        StartupWMClass=Emacs
        Keywords=Text;Editor;Doom;
        EOF
                echo "Created doom-emacs.desktop file"
      '';

      # Copy applications to Applications folder for macOS
      setupMacOSApplications = lib.hm.dag.entryAfter ["writeBoundary"] ''
        # Only run on macOS
        if [ "$(uname)" = "Darwin" ]; then
          echo "Setting up macOS Applications..."

          # Define applications to copy
          apps=(
            "${pkgs.emacs30}/Applications/Emacs.app"
          )

          # Define target directory
          target_dir="$HOME/Applications/Nix Apps"
          mkdir -p "$target_dir"

          # Set up dry run command (empty for actual execution)
          DRY_RUN_CMD=""

          # Copy each application
          for app in "''${apps[@]}"; do
            # Extract app name
            app_name=$(basename "$app")
            target="$target_dir/$app_name"

            echo "Processing $app_name..."

            # Remove existing application if it exists and we have permission
            if [ -L "$target" ]; then
              $DRY_RUN_CMD rm -f "$target" || echo "Warning: Could not remove symlink $target"
            elif [ -d "$target" ] && [ -w "$target" ]; then
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
        fi
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
      # Note: Core dependencies like git, ripgrep, fd are now in common-pkg.nix
      # Emacs needs ripgrep with PCRE2 support, so we override the common one
      (ripgrep.override {withPCRE2 = true;})

      # Additional Emacs packages
      emacs-all-the-icons-fonts

      # Development tools
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
      # Note: imagemagick is now in common-pkg.nix
      zstd
      sqlite
      editorconfig-core-c

      # Additional dependencies recommended for Doom Emacs
      coreutils # For GNU ls (gls)
      pandoc # For markdown processing
      # Note: shellcheck is now in common-pkg.nix
      aspell # For spell checking
      aspellDicts.en # English dictionary
      graphviz # For org-roam graph visualization

      # Note: Build tools (cmake, gnumake, gcc, libtool) are now in common-pkg.nix
    ];
  };
}
