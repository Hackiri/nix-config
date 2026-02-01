# Desktop profile - GUI applications and desktop environment tools
# Inherits from development.nix which includes minimal.nix foundation.
# Adds desktop applications, media tools, and GUI utilities.
{pkgs, ...}: {
  imports = [
    # Features: Development environment (includes minimal)
    ./development.nix

    # Packages: Desktop utilities
    ../../packages/utilities.nix
  ];

  # Enable and configure neovide GUI editor
  modules.neovide = {
    enable = true;
    settings = {
      # Window settings
      frame = "transparent"; # Transparent decorations on macOS
      titleHidden = true; # Hide window title for clean look
      maximized = false; # Start in normal size
      fork = false; # Don't fork process (better for debugging)

      # Performance settings
      vsync = false; # Disable vsync for better performance (set refresh rate in neovim)
      idle = true; # Enable idle animations
      noMultigrid = false; # Use multigrid for better performance
      srgb = false; # Use display's native color space

      # UI preferences
      tabs = true; # Show tab bar
      theme = "auto"; # Auto-detect light/dark theme from system

      # Font configuration - matching your other editors
      font = {
        normal = ["JetBrainsMono Nerd Font"];
        size = 13.0; # Slightly smaller than default for more screen space
      };
    };
  };

  # Desktop-specific home configuration
  home.packages = with pkgs; [
    # Additional desktop packages can be added here
    # These are for packages that don't fit into the organized categories
    # libreoffice # Office suite
    # gimp        # Image editor
  ];
}
