# SSH client hardening configuration
# Follows security best practices for SSH connections
_: {
  programs.ssh = {
    enable = true;

    # Disable default config to manually control all settings
    enableDefaultConfig = false;

    # Security settings applied to all hosts
    matchBlocks."*" = {
      # Security: Hash hostnames in known_hosts to prevent information disclosure
      hashKnownHosts = true;

      # Don't allow agent forwarding by default (enable per-host if needed)
      forwardAgent = false;

      # Don't allow X11 forwarding by default
      forwardX11 = false;

      # Send keepalive to detect broken connections
      serverAliveInterval = 60;
      serverAliveCountMax = 3;

      extraOptions = {
        # Prefer modern, secure key exchange algorithms
        KexAlgorithms = "curve25519-sha256@libssh.org,curve25519-sha256,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,diffie-hellman-group-exchange-sha256";

        # Use strong ciphers only
        Ciphers = "chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr";

        # Use strong MACs
        MACs = "hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com";

        # Prefer public key authentication
        PreferredAuthentications = "publickey,keyboard-interactive,password";

        # Verify host key on first connection
        StrictHostKeyChecking = "ask";

        # Connection timeout
        ConnectTimeout = "30";
      };
    };
  };
}
