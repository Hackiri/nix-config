# SSH client hardening configuration
# Follows security best practices for SSH connections
_: {
  programs.ssh = {
    enable = true;

    # Security: Hash hostnames in known_hosts to prevent information disclosure
    hashKnownHosts = true;

    # Security: Strong cryptographic settings
    extraConfig = ''
      # Prefer modern, secure key exchange algorithms
      KexAlgorithms curve25519-sha256@libssh.org,curve25519-sha256,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,diffie-hellman-group-exchange-sha256

      # Use strong ciphers only
      Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr

      # Use strong MACs
      MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com

      # Prefer public key authentication
      PreferredAuthentications publickey,keyboard-interactive,password

      # Verify host key on first connection
      StrictHostKeyChecking ask

      # Don't allow agent forwarding by default (enable per-host if needed)
      ForwardAgent no

      # Don't allow X11 forwarding by default
      ForwardX11 no

      # Connection timeout
      ConnectTimeout 30

      # Send keepalive to detect broken connections
      ServerAliveInterval 60
      ServerAliveCountMax 3

      # Disable roaming (CVE-2016-0777, CVE-2016-0778)
      UseRoaming no
    '';
  };
}
