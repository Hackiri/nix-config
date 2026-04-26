{
  config,
  lib,
  ...
}: {
  config =
    lib.mkIf
    (
      (config.profiles.development.enable or true)
      && (config.profiles.development.terminals.enable or true)
    )
    {
      programs.sesh = {
        enable = true;
        enableTmuxIntegration = true;
        tmuxKey = "T";
        icons = true;
        settings = {
          default_session = {
            startup_command = "nvim";
            preview_command = "eza --all --git --icons --color=always {}";
          };
          sort_order = [
            "config"
            "tmux"
            "zoxide"
          ];
          blacklist = ["0"];
          session = [
            {
              name = "nix-config";
              path = "~/nix-config";
            }
          ];
          wildcard = [
            {
              pattern = "~/Projects/*";
              startup_command = "nvim";
            }
          ];
        };
      };
    };
}
