{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.features.emacs;

  # Shared PATH for all activation scripts that need Nix tool access
  activationPath = lib.makeBinPath [
    pkgs.emacs-git
    pkgs.git
    pkgs.ripgrep
    pkgs.fd
    pkgs.findutils
    pkgs.gnugrep
    pkgs.gnused
    pkgs.coreutils
  ];

  # Common environment preamble for Doom-related activation scripts
  doomEnv = ''
    export PATH="${activationPath}:$PATH"
    export EMACSDIR="$HOME/.config/emacs"
    export DOOMDIR="$HOME/.config/doom"
    export DOOMLOCALDIR="$EMACSDIR/.local"
  '';
in {
  options.features.emacs.enable = lib.mkEnableOption "Doom Emacs" // {default = true;};

  config = lib.mkIf ((config.profiles.development.editors.enable or true) && cfg.enable) {
    # Emacs daemon service for macOS
    services.emacs = {
      enable = true;
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
        # Tree-sitter grammars for all languages
        epkgs.treesit-grammars.with-all-grammars

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

    home = {
      activation =
        {
          # Phase 1: Clone Doom Emacs repository if not already installed
          installDoomEmacs = lib.hm.dag.entryAfter ["writeBoundary"] ''
            ${doomEnv}

            # Check Emacs version
            EMACS_VERSION=$("${pkgs.emacs-git}/bin/emacs" --version | head -n 1 | cut -d' ' -f3)
            echo "Found Emacs version: $EMACS_VERSION"
            if [[ "$EMACS_VERSION" < "28.0" ]]; then
              echo "Warning: Doom Emacs works best with Emacs 28.0 or newer"
            fi

            # Ensure Doom Emacs is installed in $HOME/.config/emacs (newer XDG standard)
            if [ ! -d "$EMACSDIR" ] || [ ! -f "$EMACSDIR/bin/doom" ]; then
              echo "Installing Doom Emacs..."
              if [ -d "$EMACSDIR" ]; then
                mv "$EMACSDIR" "$EMACSDIR.bak-$(date +%Y%m%d%H%M%S)"
              fi

              # Check network connectivity before attempting clone
              if git ls-remote --exit-code https://github.com/doomemacs/doomemacs HEAD >/dev/null 2>&1; then
                git clone --depth 1 https://github.com/doomemacs/doomemacs "$EMACSDIR"
              else
                echo "Warning: Cannot reach github.com - skipping Doom Emacs install (no network)"
              fi

              if [ ! -f "$EMACSDIR/bin/doom" ]; then
                echo "Warning: Doom Emacs installation incomplete - doom binary not found"
                echo "You can install manually: git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs"
              fi
            else
              echo "Doom Emacs already installed at $EMACSDIR"
            fi
          '';

          # Phase 2: Copy Doom config files from nix-config to ~/.config/doom
          copyDoomConfig = lib.hm.dag.entryAfter ["installDoomEmacs"] ''
            ${doomEnv}

            # Ensure Doom config directory and snippet dirs exist
            mkdir -p "$DOOMDIR/snippets"
            mkdir -p "$DOOMDIR/etc/snippets"

            echo "Copying custom Doom Emacs configuration from nix-config to ~/.config/doom..."

            CONFIG_SOURCE="${./doom.d}"

            # Copy init.el
            if [ -f "$CONFIG_SOURCE/init.el" ]; then
              cp -f "$CONFIG_SOURCE/init.el" "$DOOMDIR/init.el" && \
              echo "Copied init.el from nix-config"
            else
              echo "Warning: init.el not found in nix-config"
            fi

            # Copy config.el
            if [ -f "$CONFIG_SOURCE/config.el" ]; then
              cp -f "$CONFIG_SOURCE/config.el" "$DOOMDIR/config.el" && \
              echo "Copied config.el from nix-config"
            else
              echo "Warning: config.el not found in nix-config"
            fi

            # Copy packages.el
            if [ -f "$CONFIG_SOURCE/packages.el" ]; then
              cp -f "$CONFIG_SOURCE/packages.el" "$DOOMDIR/packages.el" && \
              echo "Copied packages.el from nix-config"
            else
              echo "Warning: packages.el not found in nix-config"
            fi

            # Create custom.el if it doesn't exist (preserves user customizations)
            if [ ! -f "$DOOMDIR/custom.el" ]; then
              touch "$DOOMDIR/custom.el" && \
              echo "Created empty custom.el"
            fi
          '';

          # Phase 3: Set file permissions on Doom directories
          setDoomPermissions = lib.hm.dag.entryAfter ["copyDoomConfig"] ''
            ${doomEnv}

            chmod -R u+w "$DOOMDIR" || echo "Warning: Could not set permissions on $DOOMDIR"
            chmod +x "$EMACSDIR/bin/doom" || echo "Warning: Could not make doom binary executable"
          '';

          # Phase 4: Run doom sync to install/update packages
          syncDoomPackages = lib.hm.dag.entryAfter ["setDoomPermissions"] ''
            ${doomEnv}

            if [ -f "$EMACSDIR/bin/doom" ]; then
              echo "Running doom sync to ensure all packages are installed..."

              # Clear EMACSLOADPATH so doom uses its own package management
              export EMACSLOADPATH=""

              # Run doom sync with timeout to prevent hanging during activation
              if timeout 300 "$EMACSDIR/bin/doom" sync -e; then
                echo "Doom sync completed successfully!"
              else
                SYNC_EXIT_CODE=$?
                if [ "$SYNC_EXIT_CODE" -eq 124 ]; then
                  echo "Warning: Doom sync timed out after 5 minutes"
                else
                  echo "Warning: Doom sync failed with exit code $SYNC_EXIT_CODE"
                fi
                echo "You can try running '$EMACSDIR/bin/doom sync' manually or '$EMACSDIR/bin/doom doctor' to diagnose."
              fi
            else
              echo "Skipping doom sync - Doom Emacs not installed yet"
            fi
          '';
        }
        // lib.optionalAttrs pkgs.stdenv.isLinux {
          setupLinuxDesktopFiles = lib.hm.dag.entryAfter ["writeBoundary"] ''
            echo "Setting up Linux desktop files for Emacs..."
            mkdir -p "$HOME/.local/share/applications"

            cat > "$HOME/.local/share/applications/emacs.desktop" << EOF
            [Desktop Entry]
            Name=Emacs
            GenericName=Text Editor
            Comment=Edit text
            MimeType=text/english;text/plain;text/x-makefile;text/x-c++hdr;text/x-c++src;text/x-chdr;text/x-csrc;text/x-java;text/x-moc;text/x-pascal;text/x-tcl;text/x-tex;application/x-shellscript;text/x-c;text/x-c++;
            Exec=${pkgs.emacs-git}/bin/emacs %F
            Icon=${pkgs.emacs-git}/share/icons/hicolor/scalable/apps/emacs.svg
            Type=Application
            Terminal=false
            Categories=Development;TextEditor;
            StartupWMClass=Emacs
            Keywords=Text;Editor;
            EOF
            echo "Created emacs.desktop file"

            cat > "$HOME/.local/share/applications/doom-emacs.desktop" << EOF
            [Desktop Entry]
            Name=Doom Emacs
            GenericName=Text Editor
            Comment=Emacs with Doom configuration
            MimeType=text/english;text/plain;text/x-makefile;text/x-c++hdr;text/x-c++src;text/x-chdr;text/x-csrc;text/x-java;text/x-moc;text/x-pascal;text/x-tcl;text/x-tex;application/x-shellscript;text/x-c;text/x-c++;
            Exec=${pkgs.emacs-git}/bin/emacs %F
            Icon=${pkgs.emacs-git}/share/icons/hicolor/scalable/apps/emacs.svg
            Type=Application
            Terminal=false
            Categories=Development;TextEditor;
            StartupWMClass=Emacs
            Keywords=Text;Editor;Doom;
            EOF
            echo "Created doom-emacs.desktop file"
          '';
        }
        // lib.optionalAttrs pkgs.stdenv.isDarwin {
          # Note: Emacs.app alias is handled by system-level mkalias in modules/system/darwin/activation.nix
          setupDoomLaunchers = lib.hm.dag.entryAfter ["writeBoundary"] ''
            echo "Setting up Doom Emacs launchers..."

            target_dir="$HOME/Applications/Nix Apps"
            mkdir -p "$target_dir"

            doom_launcher="$target_dir/Doom Emacs.command"
            cat > "$doom_launcher" << EOF
            #!/bin/zsh
            export EMACSDIR="$HOME/.config/emacs"
            export DOOMDIR="$HOME/.config/doom"
            export PATH="$EMACSDIR/bin:$PATH"
            exec "${pkgs.emacs-git}/bin/emacs"
            EOF
            chmod +x "$doom_launcher"
            echo "Created Doom Emacs launcher script at '$doom_launcher'"

            doom_sync_launcher="$target_dir/Doom Sync.command"
            cat > "$doom_sync_launcher" << EOF
            #!/bin/zsh
            export EMACSDIR="$HOME/.config/emacs"
            export DOOMDIR="$HOME/.config/doom"
            export PATH="$EMACSDIR/bin:$PATH"
            "$EMACSDIR/bin/doom" sync
            echo "Press any key to close this window"
            read -k 1
            EOF
            chmod +x "$doom_sync_launcher"
            echo "Created Doom Sync launcher script at '$doom_sync_launcher'"
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
        # Doom Emacs needs ripgrep with PCRE2 support (profiles provide plain ripgrep)
        (ripgrep.override {withPCRE2 = true;})

        # Emacs icon fonts
        emacs-all-the-icons-fonts

        # Font support
        fontconfig
        nerd-fonts.jetbrains-mono

        # Emacs-specific dependencies
        gnutls
        zstd
        sqlite
        editorconfig-core-c
        imagemagick

        # Doom Emacs tools
        pandoc # Markdown processing
        aspell # Spell checking
        aspellDicts.en # English dictionary
        graphviz # Org-roam graph visualization

        # Language servers and formatters (emacs-specific)
        nixfmt
        nodePackages.prettier
        nodePackages.typescript-language-server

        # Python development tools (emacs-specific)
        python3Packages.black
        python3Packages.pyflakes
        python3Packages.isort
        pipenv
        python3Packages.pytest

        # Web development tools (emacs-specific)
        nodePackages.stylelint
        nodePackages.js-beautify
      ];
    };
  }; # end config = lib.mkIf ((config.profiles.development.editors.enable or true) && cfg.enable)
}
