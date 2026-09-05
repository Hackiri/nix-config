{
  config,
  pkgs,
  lib,
  ...
}: let
  # Reviewed 2026-09-03. Keep Doom outside flake inputs while still making its
  # source revision and content hash part of the evaluated configuration.
  doomEmacsSource = pkgs.fetchFromGitHub {
    owner = "doomemacs";
    repo = "doomemacs";
    rev = "bd38d60b0179dea62cae63ea2cccf376ef65f11f";
    # Doom v3 keeps its modules in the sources/doom+ submodule; without this the
    # checkout has no modules and every module in doom.d/init.el is missing.
    fetchSubmodules = true;
    hash = "sha256-Clu4VvP7RK5kRsDTVNQCEMj9OcNQqlFyXdAZw5reGbw=";
  };
in {
  config = {
    # Emacs daemon service for macOS
    services.emacs = {
      enable = true;
      package = pkgs.emacs;
      client = {
        enable = true;
        arguments = ["-c"];
      };
      extraOptions = ["--daemon"];
    };

    programs.emacs = {
      enable = true;
      package = lib.mkForce pkgs.emacs;
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
      # Keep the framework itself immutable. DOOMLOCALDIR below redirects all
      # generated state outside this store-backed directory.
      file.".config/emacs" = {
        source = doomEmacsSource;
      };

      activation =
        {
          # Copy Doom config files from nix-config to ~/.config/doom.
          copyDoomConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
            export DOOMDIR="$HOME/.config/doom"

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

          # Keep the copied user configuration writable.
          setDoomPermissions = lib.hm.dag.entryAfter ["copyDoomConfig"] ''
            export DOOMDIR="$HOME/.config/doom"
            chmod -R u+w "$DOOMDIR" || echo "Warning: Could not set permissions on $DOOMDIR"
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
            Exec=${pkgs.emacs}/bin/emacs %F
            Icon=${pkgs.emacs}/share/icons/hicolor/scalable/apps/emacs.svg
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
            Exec=${pkgs.emacs}/bin/emacs %F
            Icon=${pkgs.emacs}/share/icons/hicolor/scalable/apps/emacs.svg
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
            cat > "$doom_launcher" << 'EOF'
            #!/bin/zsh
            export EMACSDIR="$HOME/.config/emacs"
            export DOOMDIR="$HOME/.config/doom"
            export DOOMLOCALDIR="$HOME/.local/share/doom"
            export PATH="$EMACSDIR/bin:$PATH"
            exec "${pkgs.emacs}/bin/emacs"
            EOF
            chmod +x "$doom_launcher"
            echo "Created Doom Emacs launcher script at '$doom_launcher'"

            doom_sync_launcher="$target_dir/Doom Sync.command"
            cat > "$doom_sync_launcher" << 'EOF'
            #!/bin/zsh
            export EMACSDIR="$HOME/.config/emacs"
            export DOOMDIR="$HOME/.config/doom"
            export DOOMLOCALDIR="$HOME/.local/share/doom"
            export PATH="$EMACSDIR/bin:${pkgs.emacs}/bin:${pkgs.git}/bin:${pkgs.ripgrep}/bin:${pkgs.fd}/bin:$PATH"
            doom sync
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
        DOOMLOCALDIR = "${config.home.homeDirectory}/.local/share/doom";
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
        prettier
        typescript-language-server

        # Python development tools (emacs-specific)
        python314Packages.black
        python314Packages.pyflakes
        python314Packages.isort
        pipenv
        python314Packages.pytest

        # Web development tools (emacs-specific)
        stylelint
        js-beautify
      ];
    };
  };
}
