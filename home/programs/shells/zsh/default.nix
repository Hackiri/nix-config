{
  config,
  lib,
  ...
}: {
  imports = [
    ./options.nix
    ./keybindings.nix
    ./completion.nix
    ./fzf.nix
    ./fzf-git.nix
    ./fzf-kubectl.nix
    ./fzf-cilium.nix
    ./fzf-claude.nix
    ./direnv-hook.nix
  ];

  home = {
    # Ripgrep configuration file
    file.".ripgreprc".text = ''
      --smart-case
      --hidden
      --glob=!.git/*
      --glob=!node_modules/*
      --glob=!.direnv/*
      --glob=!target/*
      --glob=!dist/*
      --glob=!.next/*
      --glob=!__pycache__/*
      --glob=!.venv/*
      --max-columns=200
      --max-columns-preview
    '';

    sessionPath = [
      "${config.home.homeDirectory}/.config/emacs/bin"
      "${config.home.homeDirectory}/.krew/bin"
      "${config.home.homeDirectory}/bin"
      "${config.home.homeDirectory}/.local/bin"
    ];

    sessionVariables = {
      KREW_ROOT = "${config.home.homeDirectory}/.krew";
      EDITOR = "nvim";
      VISUAL = "nvim";
      LANG = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";
      TERM = "xterm-256color";
      # Colored man pages (replaces oh-my-zsh colored-man-pages plugin)
      MANPAGER = "sh -c 'col -bx | bat -l man -p --color=always'";
      MANROFFOPT = "-c";
    };
  };

  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;

      # Native plugins
      syntaxHighlighting.enable = true;
      autosuggestion.enable = true;
      historySubstringSearch.enable = true;

      history = {
        size = lib.mkForce 50000;
        save = lib.mkForce 50000;
        path = "${config.home.homeDirectory}/.zsh_history";
        ignoreDups = true;
        share = true;
        extended = true;
      };

      initContent = ''
        # Raise open file limit (macOS default 256 is too low for nix flake update)
        ulimit -n 10240

        # Performance optimizations
        export ZSH_AUTOSUGGEST_USE_ASYNC=1
        export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
        export ZSH_AUTOSUGGEST_STRATEGY=(history completion)

        # Initialize zoxide (use z/zi commands, don't override cd)
        eval "$(zoxide init zsh)"

        # Set GPG_TTY for Git commit signing
        export GPG_TTY=$(tty)

        # Ripgrep configuration
        export RIPGREP_CONFIG_PATH="${config.home.homeDirectory}/.ripgreprc"

        # Word chars — what counts as part of a word for ctrl+w etc.
        WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'
      '';

      profileExtra = ''
        if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then
          . $HOME/.nix-profile/etc/profile.d/nix.sh
        fi
      '';
    };
  };
}
