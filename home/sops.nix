{
  pkgs,
  lib,
  config,
  ...
}: {
  # Install sops and age packages
  home.packages = with pkgs; [
    sops
    age
  ];

  # Create the sops age directory
  home.file.".config/sops/.keep".text = "";

  # Optional: Add sops to shell aliases for convenience
  programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
    sops-edit = "sops";
    sops-encrypt = "sops -e -i";
    sops-decrypt = "sops -d";
  };

  # Optional: Add bash aliases if using bash
  programs.bash.shellAliases = lib.mkIf config.programs.bash.enable {
    sops-edit = "sops";
    sops-encrypt = "sops -e -i";
    sops-decrypt = "sops -d";
  };
}
