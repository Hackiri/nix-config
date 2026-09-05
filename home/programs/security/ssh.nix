# SSH client hardening configuration
# Follows security best practices for SSH connections
_: {
  programs.ssh = {
    enable = true;

    # Disable default config to manually control all settings
    enableDefaultConfig = false;

    # Security settings applied to all hosts
    includes = [
      "~/.ssh/conf.d/*"
    ];

    settings."*" = {
      # Security: Hash hostnames in known_hosts to prevent information disclosure
      HashKnownHosts = true;

      # Don't allow agent forwarding by default (enable per-host if needed)
      ForwardAgent = false;

      # Send keepalive to detect broken connections
      ServerAliveInterval = 60;
      ServerAliveCountMax = 3;

      # Prefer public key authentication
      PreferredAuthentications = "publickey,keyboard-interactive,password";

      # Verify host key on first connection
      StrictHostKeyChecking = "ask";

      # Connection timeout
      ConnectTimeout = "30";
    };
  };
}
