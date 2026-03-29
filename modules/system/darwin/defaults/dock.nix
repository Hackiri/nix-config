# Dock, Window Manager, and screenshot settings
_: {
  system.defaults = {
    dock = {
      autohide = false;
      launchanim = false;
      static-only = false;
      show-recents = false;
      show-process-indicators = true;
      orientation = "left";
      tilesize = 36;
      minimize-to-application = true;
      mineffect = "scale";
    };

    # Window Manager — disable Stage Manager (AeroSpace handles tiling)
    WindowManager = {
      GloballyEnabled = false;
      EnableStandardClickToShowDesktop = false;
    };

    # Screenshots — save to ~/Screenshots as PNG, no window shadows
    screencapture = {
      location = "~/Screenshots";
      type = "png";
      disable-shadow = true;
    };

    CustomUserPreferences = {
      "com.apple.dock" = {
        enable-window-tool = false;
      };
    };
  };
}
