let
  registry = {
    theme = ./theme;

    security = {
      ssh = ./security/ssh.nix;
    };

    shells = {
      bash = ./shells/bash;
      zsh = {
        aliases = ./shells/zsh/aliases.nix;
        main = ./shells/zsh;
      };
      starship = ./shells/starship;
    };

    development = {
      git = ./development/git;
      direnv = ./development/direnv;
    };

    editors = {
      neovim = ./editors/neovim;
      emacs = ./editors/emacs;
      neovide = ./editors/neovide;
    };

    terminals = {
      alacritty = ./terminals/alacritty;
      ghostty = ./terminals/ghostty;
      kitty = ./terminals/kitty;
      sesh = ./terminals/sesh;
      tmux = ./terminals/tmux;
      wezterm = ./terminals/wezterm;
    };

    utilities = {
      btop = ./utilities/btop;
      claude = ./utilities/claude;
      yazi = ./utilities/yazi;
      aerospace = ./utilities/aerospace;
    };
  };

  suites = rec {
    shell = [
      registry.shells.zsh.aliases
      registry.shells.bash
      registry.shells.zsh.main
      registry.shells.starship
    ];

    development = [
      registry.development.git
      registry.development.direnv
    ];

    editors = [
      registry.editors.neovim
      registry.editors.emacs
      registry.editors.neovide
    ];

    terminals = rec {
      core = [
        registry.terminals.kitty
        registry.terminals.sesh
        registry.terminals.tmux
      ];
      all =
        core
        ++ [
          registry.terminals.alacritty
          registry.terminals.ghostty
          registry.terminals.wezterm
        ];
    };

    utilities = rec {
      common = [
        registry.utilities.btop
        registry.utilities.claude
        registry.utilities.yazi
      ];
      darwin =
        common
        ++ [
          registry.utilities.aerospace
        ];
    };

    workstation = rec {
      common =
        [
          registry.theme
          registry.security.ssh
        ]
        ++ shell
        ++ development
        ++ editors
        ++ terminals.core
        ++ utilities.common;

      darwin =
        common
        ++ [
          registry.utilities.aerospace
        ];

      nixos = common;
    };
  };
in
  registry
  // {
    inherit suites;
  }
