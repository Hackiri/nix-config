{
  inputs,
  username,
  ...
}: {
  imports = [
    inputs.hermes-agent.nixosModules.default
  ];

  services.hermes-agent = {
    enable = true;
    addToSystemPackages = true;
    environmentFiles = [
      "/var/lib/hermes/env"
    ];
    settings = {
      model.default = "anthropic/claude-sonnet-4";
      toolsets = ["all"];
      terminal = {
        backend = "local";
        timeout = 180;
      };
    };

    container = {
      enable = true;
      backend = "podman";
      hostUsers = [username];
    };
  };

  virtualisation.docker.enable = false;

  systemd.tmpfiles.rules = [
    "f /var/lib/hermes/env 0640 hermes hermes -"
  ];

  security.sudo.extraRules = [
    {
      users = [username];
      commands = [
        {
          command = "/run/current-system/sw/bin/podman";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];
}
