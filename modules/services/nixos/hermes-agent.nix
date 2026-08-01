# Hermes Agent gateway, running in container mode.
#
# Upstream is a Tier 2 platform: commits to its main branch may break this flake
# at any time. See "docs/hermes-agent Nix & NixOS Setup.md".
{
  config,
  inputs,
  lib,
  pkgs,
  username,
  ...
}: let
  cfg = config.features.hermes-agent;

  # Created empty by tmpfiles below, so the unit can start on a fresh host.
  placeholderEnvFile = "/var/lib/hermes/env";
  usingPlaceholderSecrets = cfg.environmentFile == placeholderEnvFile;

  # The sudo rule and container.backend must name the same runtime; deriving the
  # binary path from the backend keeps the two from drifting apart.
  backendBin = "/run/current-system/sw/bin/${cfg.backend}";
in {
  imports = [
    inputs.hermes-agent.nixosModules.default
  ];

  options.features.hermes-agent = {
    enable = lib.mkEnableOption "Hermes Agent gateway service";

    backend = lib.mkOption {
      type = lib.types.enum ["podman" "docker"];
      default = "podman";
      description = "Container runtime backing the managed hermes container.";
    };

    # str, not path: a path would copy the secret into the world-readable store.
    environmentFile = lib.mkOption {
      type = lib.types.str;
      default = placeholderEnvFile;
      example = lib.literalExpression ''config.sops.secrets."hermes-env".path'';
      description = ''
        Env file holding at least one provider key (e.g. OPENROUTER_API_KEY).
        The gateway starts but cannot authenticate while this file is empty, so
        point it at a sops-nix or agenix secret on a real deployment. mkNixOS
        already imports sops-nix, so `config.sops.secrets.<name>.path` works
        without further wiring.
      '';
    };

    model = lib.mkOption {
      type = lib.types.str;
      default = "anthropic/claude-sonnet-5";
      example = "anthropic/claude-opus-5";
      description = ''
        Model id in whatever form the configured provider expects. Hermes talks
        to OpenRouter unless settings.model.base_url says otherwise, so this
        defaults to an OpenRouter slug.
      '';
    };

    hostUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [username];
      description = ''
        Interactive users who get a ~/.hermes symlink into the service state
        directory. Listed users are added to the hermes group, and are granted
        passwordless sudo for the container backend so the CLI can reach the
        rootful container.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.backend == "podman" -> config.virtualisation.podman.enable;
        message = "features.hermes-agent.backend is \"podman\" but virtualisation.podman.enable is false; import modules/services/nixos/podman.nix.";
      }
      {
        assertion = cfg.backend == "docker" -> config.virtualisation.docker.enable;
        message = "features.hermes-agent.backend is \"docker\" but virtualisation.docker.enable is false.";
      }
    ];

    warnings = lib.optional usingPlaceholderSecrets ''
      features.hermes-agent is using the placeholder secrets file ${placeholderEnvFile},
      which is created empty. Populate it or set features.hermes-agent.environmentFile
      to a managed secret, otherwise hermes cannot authenticate with any provider.
    '';

    services.hermes-agent = {
      enable = true;
      package = pkgs.hermes-agent;
      addToSystemPackages = true;
      environmentFiles = [cfg.environmentFile];

      settings = {
        model.default = cfg.model;
        toolsets = ["all"];
        terminal = {
          backend = "local";
          timeout = 180;
        };
      };

      container = {
        enable = true;
        inherit (cfg) backend hostUsers;
      };
    };

    # Container mode sets virtualisation.docker.enable with mkDefault. Under the
    # podman backend that collides with podman.nix's dockerCompat/dockerSocket.
    virtualisation.docker.enable = lib.mkIf (cfg.backend == "podman") false;

    # 0600 rather than 0640: hostUsers land in the hermes group, and group-read
    # would hand them the provider keys.
    systemd.tmpfiles.rules = lib.mkIf usingPlaceholderSecrets [
      "f ${placeholderEnvFile} 0600 hermes hermes -"
    ];

    security.sudo.extraRules = [
      {
        users = cfg.hostUsers;
        commands = [
          {
            command = backendBin;
            options = ["NOPASSWD"];
          }
        ];
      }
    ];
  };
}
