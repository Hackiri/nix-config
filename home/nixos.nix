# Home Manager config for NixOS
{
  config,
  pkgs,
  ...
}: {
  # NixOS-specific packages
  home.packages = with pkgs; [
    # Linux-specific utilities
    xclip # X11 clipboard utility
    xsel # X11 selection utility

    # Linux desktop applications
    # firefox           # Web browser (if not using system-wide)
    # thunderbird       # Email client

    # Linux development tools
    # gdb               # GNU debugger
    # valgrind          # Memory debugging tool
  ];

  # NixOS-specific configurations
  # Enable services that are Linux-specific
  services = {
    # gpg-agent = {
    #   enable = true;
    #   defaultCacheTtl = 1800;
    #   enableSshSupport = true;
    # };
  };

  # Linux-specific environment variables
  home.sessionVariables = {
    # BROWSER = "firefox";
    # TERMINAL = "alacritty";
  };

  # XDG configuration (Linux desktop)
  xdg = {
    enable = true;
    # mimeApps = {
    #   enable = true;
    #   defaultApplications = {
    #     "text/html" = "firefox.desktop";
    #     "x-scheme-handler/http" = "firefox.desktop";
    #     "x-scheme-handler/https" = "firefox.desktop";
    #   };
    # };
  };
}
