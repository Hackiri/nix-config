{
  config,
  lib,
  ...
}: {
  config = lib.mkIf (config.profiles.development.shells.enable or true) {
    programs.bash = {
      enable = true;
    };
  };
}
