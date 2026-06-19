{
  config,
  lib,
  ...
}: {
  config =
    lib.mkIf
    (
      (config.profiles.workspace.enable or true) && (config.profiles.workspace.shells.enable or true)
    )
    {
      programs.bash = {
        enable = true;
      };
    };
}
