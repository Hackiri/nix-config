{
  config,
  pkgs,
  lib,
  ...
}: let
  emacs-enabled = config.programs.emacs.enable;
in {
  imports = [];

  # Emacs daemon service for macOS
  services.emacs = {
    enable = emacs-enabled;
    package = pkgs.emacs-git;
    client = {
      enable = true;
      arguments = ["-c"];
    };
    extraOptions = ["--daemon"];
  };

  programs.emacs = {
    enable = true;
    package = lib.mkForce pkgs.emacs-git;
    extraPackages = epkgs: [
      # Nix support
      epkgs.nix-mode
      epkgs.nixpkgs-fmt

      # Editing and linting
      epkgs.flycheck
      epkgs.json-mode
      epkgs.python-mode
      epkgs.auto-complete
      epkgs.web-mode
      epkgs.smart-tabs-mode
      epkgs.whitespace-cleanup-mode
      epkgs.flycheck-pyflakes
      epkgs.pos-tip # required by flycheck pos-tip
      epkgs.flycheck-pos-tip

      # Themes
      epkgs.nord-theme
      epkgs.nordless-theme
      epkgs.vscode-dark-plus-theme

      # UI enhancements
      epkgs.s # required by shrink-path
      epkgs.f # required by shrink-path
      epkgs.shrink-path # required by doom-modeline
      epkgs.doom-modeline
      epkgs.all-the-icons
      epkgs.all-the-icons-dired
      epkgs.nerd-icons

      # Git integration (core packages)
      epkgs.with-editor # required by magit
      epkgs.llama # required by magit
      epkgs.magit

      # Markdown
      epkgs.websocket # required by markdown-preview mode
      epkgs.web-server # required by markdown-preview mode
      epkgs.markdown-mode
      epkgs.markdown-preview-mode

      # AI/Chat
      epkgs.gptel

      # Language support
      epkgs.yaml-mode
      epkgs.multiple-cursors
      epkgs.dts-mode
      epkgs.rust-mode
      epkgs.nickel-mode
      epkgs.hcl-mode # required by terraform-mode
      epkgs.terraform-mode
    ];
  };

  home = lib.mkIf emacs-enabled {
    activation = {
      setupDoomEmacs = lib.hm.dag.entryAfter ["writeBoundary"] ''
        # Define explicit paths to required binaries and tools
        EMACS_BIN="${pkgs.emacs-git}/bin/emacs"
        GIT_BIN="${pkgs.git}/bin/git"
        RIPGREP_BIN="${pkgs.ripgrep}/bin/rg"
        FD_BIN="${pkgs.fd}/bin/fd"
        FIND_BIN="${pkgs.findutils}/bin/find"
        GREP_BIN="${pkgs.gnugrep}/bin/grep"
        SED_BIN="${pkgs.gnused}/bin/sed"
        MKDIR_BIN="${pkgs.coreutils}/bin/mkdir"
        CHMOD_BIN="${pkgs.coreutils}/bin/chmod"
        CP_BIN="${pkgs.coreutils}/bin/cp"
        RM_BIN="${pkgs.coreutils}/bin/rm"
        MV_BIN="${pkgs.coreutils}/bin/mv"
        TOUCH_BIN="${pkgs.coreutils}/bin/touch"
        DATE_BIN="${pkgs.coreutils}/bin/date"
        HEAD_BIN="${pkgs.coreutils}/bin/head"
        CUT_BIN="${pkgs.coreutils}/bin/cut"

        # Create a temporary PATH with all required tools
        export PATH="${pkgs.emacs-git}/bin:${pkgs.git}/bin:${pkgs.ripgrep}/bin:${pkgs.fd}/bin:${pkgs.findutils}/bin:${pkgs.gnugrep}/bin:${pkgs.gnused}/bin:${pkgs.coreutils}/bin:$PATH"

        # Set up environment variables for Doom Emacs
        export EMACSDIR="$HOME/.config/emacs"
        export DOOMDIR="$HOME/.doom.d"
        export DOOMLOCALDIR="$EMACSDIR/.local"

        echo "Setting up Doom Emacs with:"
        echo "EMACSDIR=$EMACSDIR"
        echo "DOOMDIR=$DOOMDIR"
        echo "DOOMLOCALDIR=$DOOMLOCALDIR"

        # Check Emacs version
        EMACS_VERSION=$("$EMACS_BIN" --version | "$HEAD_BIN" -n 1 | "$CUT_BIN" -d' ' -f3)
        echo "Found Emacs version: $EMACS_VERSION"
        if [[ "$EMACS_VERSION" < "28.0" ]]; then
          echo "Warning: Doom Emacs works best with Emacs 28.0 or newer"
        fi

        # Ensure Doom Emacs is installed in $HOME/.config/emacs (newer XDG standard)
        if [ ! -d "$EMACSDIR" ] || [ ! -f "$EMACSDIR/bin/doom" ]; then
          echo "Installing Doom Emacs..."
          if [ -d "$EMACSDIR" ]; then
            "$MV_BIN" "$EMACSDIR" "$EMACSDIR.bak-$("$DATE_BIN" +%Y%m%d%H%M%S)"
          fi
          "$GIT_BIN" clone --depth 1 https://github.com/doomemacs/doomemacs "$EMACSDIR"

          if [ ! -f "$EMACSDIR/bin/doom" ]; then
            echo "Error: Doom Emacs installation failed - doom binary not found"
            exit 1
          fi
        else
          echo "Doom Emacs already installed at $EMACSDIR"
        fi

        # Ensure Doom config directory exists at ~/.doom.d (Doom's default location)
        "$MKDIR_BIN" -p "$DOOMDIR"

        # Create required snippet directories if they don't exist
        "$MKDIR_BIN" -p "$DOOMDIR/snippets"
        "$MKDIR_BIN" -p "$DOOMDIR/etc/snippets"

        # Use our custom Doom config files directly
        echo "Copying custom Doom Emacs configuration from nix-config to ~/.doom.d..."

        # Copy configuration files
        CONFIG_SOURCE="${config.home.homeDirectory}/nix-config/home/programs/editors/emacs/doom.d"

        # Copy init.el
        if [ -f "$CONFIG_SOURCE/init.el" ]; then
          "$CP_BIN" -f "$CONFIG_SOURCE/init.el" "$DOOMDIR/init.el" && \
          echo "Copied init.el from nix-config"
        else
          echo "Warning: init.el not found in nix-config"
        fi

        # Copy config.el
        if [ -f "$CONFIG_SOURCE/config.el" ]; then
          "$CP_BIN" -f "$CONFIG_SOURCE/config.el" "$DOOMDIR/config.el" && \
          echo "Copied config.el from nix-config"
        else
          echo "Warning: config.el not found in nix-config"
        fi

        # Copy packages.el
        if [ -f "$CONFIG_SOURCE/packages.el" ]; then
          "$CP_BIN" -f "$CONFIG_SOURCE/packages.el" "$DOOMDIR/packages.el" && \
          echo "Copied packages.el from nix-config"
        else
          echo "Warning: packages.el not found in nix-config"
        fi

        # Create custom.el if it doesn't exist (optional)
        if [ ! -f "$DOOMDIR/custom.el" ]; then
          "$TOUCH_BIN" "$DOOMDIR/custom.el" && \
          echo "Created empty custom.el"
        fi

        # Set proper permissions
        "$CHMOD_BIN" -R u+w "$DOOMDIR" || echo "Warning: Could not set permissions on $DOOMDIR"
        "$CHMOD_BIN" +x "$EMACSDIR/bin/doom" || echo "Warning: Could not make doom binary executable"

        # Run Doom sync to ensure all packages are installed
        echo "Running doom sync to ensure all packages are installed..."

        # Make sure we have the right environment for doom sync
        export EMACSLOADPATH=""

        # Run doom sync with proper error handling
        if "$EMACSDIR/bin/doom" sync -e; then
          echo "Doom sync completed successfully!"
        else
          SYNC_EXIT_CODE=$?
          echo "Warning: Doom sync failed with exit code $SYNC_EXIT_CODE"
          echo "This might be due to missing dependencies or network issues."
          echo "You can try running '$EMACSDIR/bin/doom doctor' to diagnose the problem."
        fi
      '';

      # Setup application shortcuts based on platform
      setupAppShortcuts = lib.hm.dag.entryAfter ["writeBoundary"] ''
                # Check if we're on Linux or macOS
                if [ "$(uname)" = "Linux" ]; then
                  echo "Setting up Linux desktop files for Emacs..."
                  # Create desktop files for Emacs and Doom Emacs (Linux only)
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
                elif [ "$(uname)" = "Darwin" ]; then
                  echo "On macOS: Desktop files not needed - using macOS Applications instead"
                  # macOS application handling is done in the setupMacOSApplications section
                else
                  echo "Unknown OS: $(uname) - skipping desktop file creation"
                fi
      '';

      # Setup macOS Applications and Doom Emacs integration
      setupMacOSApplications = lib.hm.dag.entryAfter ["writeBoundary"] ''
                # Only run on macOS
                if [ "$(uname)" = "Darwin" ]; then
                  echo "Setting up macOS Applications..."

                  # Define applications to copy/symlink
                  apps=(
                    "${pkgs.emacs30}/Applications/Emacs.app"
                  )

                  # Define target directory
                  target_dir="$HOME/Applications/Nix Apps"
                  mkdir -p "$target_dir"

                  # Copy each application
                  for app in "''${apps[@]}"; do
                    # Extract app name
                    app_name=$(basename "$app")
                    target="$target_dir/$app_name"

                    echo "Processing $app_name..."

                    # Remove existing application if it exists and we have permission
                    if [ -L "$target" ]; then
                      rm -f "$target" || echo "Warning: Could not remove symlink $target"
                    elif [ -d "$target" ] && [ -w "$target" ]; then
                      rm -rf "$target" || echo "Warning: Could not remove $target"
                    elif [ -e "$target" ]; then
                      echo "Warning: Cannot remove $target (permission denied). Skipping..."
                      continue
                    fi

                    # Create symlink instead of copying (more efficient for nix-darwin)
                    if [ -e "$app" ]; then
                      ln -sf "$app" "$target" && echo "Created symlink for $app_name" || \
                      echo "Warning: Could not create symlink for $app_name, falling back to copy"

                      # Fall back to copy if symlink fails
                      if [ ! -e "$target" ]; then
                        cp -rL "$app" "$target" || echo "Warning: Could not copy $app to $target"
                      fi
                    else
                      echo "Warning: Source application $app does not exist"
                    fi
                  done

                  # Create a Doom Emacs launcher script
                  doom_launcher="$target_dir/Doom Emacs.command"
                  cat > "$doom_launcher" << EOF
        #!/bin/zsh
        export EMACSDIR="$HOME/.config/emacs"
        export DOOMDIR="$HOME/.doom.d"
        export PATH="$EMACSDIR/bin:$PATH"
        exec "${pkgs.emacs30}/bin/emacs"
        EOF
                  chmod +x "$doom_launcher"
                  echo "Created Doom Emacs launcher script at '$doom_launcher'"

                  # Create a Doom Sync launcher script
                  doom_sync_launcher="$target_dir/Doom Sync.command"
                  cat > "$doom_sync_launcher" << EOF
        #!/bin/zsh
        export EMACSDIR="$HOME/.config/emacs"
        export DOOMDIR="$HOME/.doom.d"
        export PATH="$EMACSDIR/bin:$PATH"
        "$EMACSDIR/bin/doom" sync
        echo "Press any key to close this window"
        read -k 1
        EOF
                  chmod +x "$doom_sync_launcher"
                  echo "Created Doom Sync launcher script at '$doom_sync_launcher'"
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
      # Core dependencies for Doom Emacs
      git
      (ripgrep.override {withPCRE2 = true;})
      fd
      findutils
      gnugrep
      gnused
      coreutils

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
      zstd
      sqlite
      editorconfig-core-c
      imagemagick

      # Additional dependencies recommended for Doom Emacs
      coreutils # For GNU ls (gls)
      pandoc # For markdown processing
      shellcheck # For shell script checking
      aspell # For spell checking
      aspellDicts.en # English dictionary
      graphviz # For org-roam graph visualization

      # Build tools needed by Doom for compiling some packages
      cmake
      gnumake
      gcc
      libtool

      # Additional useful tools for Doom
      unzip
      zip
      gzip
    ];
  };
}
