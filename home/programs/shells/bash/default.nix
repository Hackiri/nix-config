{
  config,
  lib,
  ...
}: {
  config =
    lib.mkIf
    (
      (config.profiles.development.enable or true) && (config.profiles.development.shells.enable or true)
    )
    {
      programs.bash = {
        enable = true;
      };
    };
}
