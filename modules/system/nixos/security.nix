# NixOS security configuration
_: {
  security = {
    sudo = {
      # Require password for sudo — passwordless sudo with SSH enabled means
      # any compromised SSH session gets instant root access
      wheelNeedsPassword = true;
      execWheelOnly = true; # Only allow wheel group to use sudo
    };
  };
}
