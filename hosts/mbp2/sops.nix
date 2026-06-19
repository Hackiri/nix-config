{config, ...}: {
  imports = [
    ../../home/profiles/capabilities/sops.nix
  ];

  profiles.sops = {
    enable = true;
    signingKeySecret = "git-signingKey-mbp2";
    extraSecrets = {
      ssh-config-srv696730 = {
        path = "${config.home.homeDirectory}/.ssh/conf.d/srv696730";
        mode = "0600";
      };
    };
  };
}
