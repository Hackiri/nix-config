# Redis user service capability
# Purpose: optional local Redis daemon managed by Home Manager.
#
# Usage:
#   imports = [ ../../home/profiles/capabilities/redis.nix ];
#
# Configuration:
#   profiles.redis.enable = true;
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.profiles.redis;
  homeDir = config.home.homeDirectory;
  inherit (pkgs.stdenv) isDarwin isLinux;
  redisConf = "${homeDir}/.config/redis/redis.conf";
  redisDataDir = "${homeDir}/.local/share/redis";
  redisLog = "${redisDataDir}/redis.log";
  redisPlist = "${homeDir}/Library/LaunchAgents/org.redis.redis-server.plist";
in {
  options.profiles.redis = with lib; {
    enable = mkEnableOption "local Redis user service";

    port = mkOption {
      type = types.port;
      default = 6379;
      description = "TCP port for the local Redis server.";
    };

    bind = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Address Redis binds to.";
    };

    databases = mkOption {
      type = types.ints.positive;
      default = 16;
      description = "Number of Redis logical databases.";
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = [pkgs.redis];

      file.".config/redis/redis.conf".text = ''
        port ${toString cfg.port}
        bind ${cfg.bind}
        timeout 0
        tcp-keepalive 300
        daemonize no
        supervised no
        pidfile ${redisDataDir}/redis.pid
        loglevel notice
        logfile ${redisLog}
        databases ${toString cfg.databases}

        save 900 1
        save 300 10
        save 60 10000
        stop-writes-on-bgsave-error yes
        rdbcompression yes
        rdbchecksum yes
        dbfilename dump.rdb
        dir ${redisDataDir}

        maxmemory-policy allkeys-lru
        appendonly yes
        appendfilename "appendonly.aof"
        appendfsync everysec
        no-appendfsync-on-rewrite no
        auto-aof-rewrite-percentage 100
        auto-aof-rewrite-min-size 64mb
      '';
    };

    systemd.user.services.redis = lib.mkIf isLinux {
      Unit = {
        Description = "Redis in-memory data store";
        After = ["network.target"];
      };
      Service = {
        ExecStart = "${pkgs.redis}/bin/redis-server ${redisConf}";
        Restart = "on-failure";
        StandardOutput = "append:${redisLog}";
        StandardError = "append:${redisLog}";
        WorkingDirectory = redisDataDir;
      };
      Install.WantedBy = ["default.target"];
    };

    launchd.agents."org.redis.redis-server" = lib.mkIf isDarwin {
      enable = true;
      config = {
        Label = "org.redis.redis-server";
        ProgramArguments = [
          "${pkgs.redis}/bin/redis-server"
          redisConf
        ];
        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = redisLog;
        StandardErrorPath = redisLog;
        WorkingDirectory = redisDataDir;
      };
    };

    programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
      redis-cli = "${pkgs.redis}/bin/redis-cli";
      redis-start =
        if isDarwin
        then "launchctl bootstrap gui/$UID ${redisPlist} 2>/dev/null || launchctl kickstart -k gui/$UID/org.redis.redis-server"
        else "systemctl --user start redis";
      redis-stop =
        if isDarwin
        then "launchctl bootout gui/$UID/org.redis.redis-server"
        else "systemctl --user stop redis";
      redis-restart =
        if isDarwin
        then "launchctl kickstart -k gui/$UID/org.redis.redis-server"
        else "systemctl --user restart redis";
    };

    programs.bash.shellAliases = lib.mkIf config.programs.bash.enable {
      redis-cli = "${pkgs.redis}/bin/redis-cli";
      redis-start =
        if isDarwin
        then "launchctl bootstrap gui/$UID ${redisPlist} 2>/dev/null || launchctl kickstart -k gui/$UID/org.redis.redis-server"
        else "systemctl --user start redis";
      redis-stop =
        if isDarwin
        then "launchctl bootout gui/$UID/org.redis.redis-server"
        else "systemctl --user stop redis";
      redis-restart =
        if isDarwin
        then "launchctl kickstart -k gui/$UID/org.redis.redis-server"
        else "systemctl --user restart redis";
    };

    home.activation.createRedisDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p ${lib.escapeShellArg redisDataDir}
      chmod 700 ${lib.escapeShellArg redisDataDir}
    '';
  };
}
