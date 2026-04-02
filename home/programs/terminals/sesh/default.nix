_: {
  programs.sesh = {
    enable = true;
    enableTmuxIntegration = true;
    tmuxKey = "f";
    icons = true;
    settings = {
      default_session = {
        startup_command = "nvim";
        preview_command = "eza --all --git --icons --color=always {}";
      };
      sort_order = ["config" "tmux" "zoxide"];
      session = [
        {
          name = "nix-config";
          path = "~/nix-config";
        }
      ];
    };
  };
}
