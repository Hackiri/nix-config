# NixOS security configuration
_: {
  security = {
    sudo = {
      wheelNeedsPassword = false;
      execWheelOnly = true; # Only allow wheel group to use sudo
    };
  };
}
