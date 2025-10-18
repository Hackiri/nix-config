{
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf pkgs.stdenv.isDarwin {
    # Note: aerospace package is installed via home/darwin.nix

    # Source aerospace config from the home-manager store
    home.file.".aerospace.toml".text = ''
      # Start AeroSpace at login
      start-at-login = true

      # Startup commands - can be used for external integrations
      after-login-command = []
      # Uncomment and modify for external tool integration:
      # after-startup-command = ['exec-and-forget sketchybar']

      # Workspace change notifications - useful for status bar integration
      # exec-on-workspace-change = ['/bin/bash', '-c',
      #   'echo "Workspace changed to $AEROSPACE_FOCUSED_WORKSPACE"'
      # ]

      # Normalization settings
      enable-normalization-flatten-containers = true
      enable-normalization-opposite-orientation-for-nested-containers = true

      # Accordion layout settings
      accordion-padding = 0

      # Default root container settings
      default-root-container-layout = 'tiles'
      default-root-container-orientation = 'auto'

      # Mouse follows focus settings
      on-focused-monitor-changed = ['move-mouse monitor-lazy-center']
      on-focus-changed = ['move-mouse window-lazy-center']

      # Automatically unhide macOS hidden apps
      automatically-unhide-macos-hidden-apps = true

      # Key mapping preset
      [key-mapping]
      preset = 'qwerty'

      # Enhanced gaps settings with better defaults
      [gaps]
      inner.horizontal = 10
      inner.vertical = 10
      outer.left = 5
      outer.right = 5
      outer.bottom = 5
      outer.top = [
        { monitor."built-in" = 10 },
        { monitor.main = 10 },
        { monitor.secondary = 10 },
        10,
      ]

      # Main mode bindings
      [mode.main.binding]
      # Launch applications
      alt-shift-enter = 'exec-and-forget open -na ghostty'
      cmd-shift-enter = 'exec-and-forget open -na alacritty'
      ctrl-shift-b = 'exec-and-forget open -a "Brave Browser"'
      ctrl-shift-t = 'exec-and-forget open -a "Telegram"'
      ctrl-shift-f = 'exec-and-forget open -a Finder'
      ctrl-shift-n = 'exec-and-forget open -a Notion'
      ctrl-shift-o = 'exec-and-forget open -a Obsidian'
      ctrl-shift-v = 'exec-and-forget open -na neovide'

      # Window management
      alt-q = "close"
      alt-shift-q = "close-all-windows-but-current"
      alt-slash = 'layout tiles horizontal vertical'
      alt-comma = 'layout accordion horizontal vertical'
      alt-period = 'layout floating tiling'

      # Focus movement - using alt+hjkl (won't conflict with neovim/neovide)
      alt-h = 'focus left'
      alt-j = 'focus down'
      alt-k = 'focus up'
      alt-l = 'focus right'

      # Focus back-and-forth for quick workspace switching
      alt-tab = 'workspace-back-and-forth'

      # Focus monitors
      alt-left = 'focus-monitor left'
      alt-right = 'focus-monitor right'
      alt-up = 'focus-monitor up'
      alt-down = 'focus-monitor down'

      # Window movement - using alt-shift to pair with focus
      alt-shift-h = 'move left'
      alt-shift-j = 'move down'
      alt-shift-k = 'move up'
      alt-shift-l = 'move right'

      # Move to monitors
      alt-shift-left = 'move-node-to-monitor left'
      alt-shift-right = 'move-node-to-monitor right'
      alt-shift-up = 'move-node-to-monitor up'
      alt-shift-down = 'move-node-to-monitor down'

      # Resize windows (fine-grained and coarse)
      ctrl-alt-h = 'resize width -50'
      ctrl-alt-j = 'resize height +50'
      ctrl-alt-k = 'resize height -50'
      ctrl-alt-l = 'resize width +50'
      alt-shift-minus = 'resize smart -50'
      alt-shift-equal = 'resize smart +50'

      # Fullscreen and maximize
      alt-shift-f = 'fullscreen'
      alt-shift-m = 'macos-native-fullscreen'

      # Workspace management - keeping numeric for compatibility
      alt-1 = 'workspace 1'
      alt-2 = 'workspace 2'
      alt-3 = 'workspace 3'
      alt-4 = 'workspace 4'
      alt-5 = 'workspace 5'
      alt-6 = 'workspace 6'
      alt-7 = 'workspace 7'
      alt-8 = 'workspace 8'
      alt-9 = 'workspace 9'
      alt-b = 'workspace B' # for browser
      alt-e = 'workspace E' #
      alt-f = 'workspace F' # for finder
      alt-m = 'workspace M' #
      alt-n = 'workspace N' # for notes
      alt-p = 'workspace P'
      alt-t = 'workspace T' # for terminal shell
      alt-v = 'workspace V'

      # Named workspaces for common use cases (optional alternative)
      # alt-p = 'workspace P'  # Personal/Projects
      # alt-c = 'workspace C'  # Code/Communication
      # alt-m = 'workspace M'  # Media/Music
      # alt-t = 'workspace T'  # Terminal/Tools
      # alt-w = 'workspace W'  # Web/Work

      # Move windows to workspaces
      alt-shift-1 = 'move-node-to-workspace 1'
      alt-shift-2 = 'move-node-to-workspace 2'
      alt-shift-3 = 'move-node-to-workspace 3'
      alt-shift-4 = 'move-node-to-workspace 4'
      alt-shift-5 = 'move-node-to-workspace 5'
      alt-shift-6 = 'move-node-to-workspace 6'
      alt-shift-7 = 'move-node-to-workspace 7'
      alt-shift-8 = 'move-node-to-workspace 8'
      alt-shift-9 = 'move-node-to-workspace 9'

      # Workspace navigation - enhanced with back-and-forth
      alt-enter = 'workspace-back-and-forth'
      alt-shift-tab = 'move-workspace-to-monitor --wrap-around next'

      # Enter service mode
      alt-shift-semicolon = 'mode service'

      # Service mode bindings
      [mode.service.binding]
      # Reload config and exit service mode
      esc = ['reload-config', 'mode main']

      # Reset layout
      r = ['flatten-workspace-tree', 'mode main']

      # Toggle floating/tiling layout
      f = ['layout floating tiling', 'mode main']

      # Close all windows but current
      backspace = ['close-all-windows-but-current', 'mode main']

      # Join with adjacent windows
      alt-shift-h = ['join-with left', 'mode main']
      alt-shift-j = ['join-with down', 'mode main']
      alt-shift-k = ['join-with up', 'mode main']
      alt-shift-l = ['join-with right', 'mode main']

      # Window detection rules - organized by workspace

      # Workspace B - Browsers
      [[on-window-detected]]
      if.app-id = 'com.brave.Browser'
      run = 'move-node-to-workspace B'

      [[on-window-detected]]
      if.app-id = 'com.google.Chrome'
      run = 'move-node-to-workspace B'

      [[on-window-detected]]
      if.app-id = 'app.zen-browser.zen'
      run = 'move-node-to-workspace B'

      [[on-window-detected]]
      if.app-id = 'org.mozilla.firefox'
      run = 'move-node-to-workspace B'

      [[on-window-detected]]
      if.app-id = 'company.thebrowser.Browser'
      run = 'move-node-to-workspace B'

      # Workspace T - Terminals
      [[on-window-detected]]
      if.app-id = 'com.mitchellh.ghostty'
      run = 'move-node-to-workspace T'

      [[on-window-detected]]
      if.app-id = 'org.alacritty'
      run = 'move-node-to-workspace T'

      [[on-window-detected]]
      if.app-id = 'com.apple.Terminal'
      run = 'move-node-to-workspace T'

      [[on-window-detected]]
      if.app-id = 'net.kovidgoyal.kitty'
      run = 'move-node-to-workspace T'

      # Workspace E - Editors (Code/Text)
      [[on-window-detected]]
      if.app-id = 'com.microsoft.VSCode'
      run = 'move-node-to-workspace E'

      [[on-window-detected]]
      if.app-id = 'com.neovide.neovide'
      run = 'move-node-to-workspace E'

      [[on-window-detected]]
      if.app-id = 'org.gnu.Emacs'
      run = 'move-node-to-workspace E'

      [[on-window-detected]]
      if.app-id = 'com.jetbrains.intellij'
      run = 'move-node-to-workspace E'

      # Workspace N - Notes
      [[on-window-detected]]
      if.app-id = 'notion.id'
      run = 'move-node-to-workspace N'

      [[on-window-detected]]
      if.app-id = 'md.obsidian'
      run = 'move-node-to-workspace N'

      [[on-window-detected]]
      if.app-id = 'com.apple.Notes'
      run = 'move-node-to-workspace N'

      [[on-window-detected]]
      if.app-id = 'com.logseq.logseq'
      run = 'move-node-to-workspace N'

      # Workspace M - Media & Communication
      [[on-window-detected]]
      if.app-id = 'com.tdesktop.Telegram'
      run = 'move-node-to-workspace M'

      [[on-window-detected]]
      if.app-id = 'com.hnc.Discord'
      run = 'move-node-to-workspace M'

      [[on-window-detected]]
      if.app-id = 'com.tinyspeck.slackmacgap'
      run = 'move-node-to-workspace M'

      [[on-window-detected]]
      if.app-id = 'com.spotify.client'
      run = 'move-node-to-workspace M'

      [[on-window-detected]]
      if.app-id = 'us.zoom.xos'
      run = 'move-node-to-workspace M'

      # Workspace V - Video/Recording
      [[on-window-detected]]
      if.app-id = 'com.obsproject.obs-studio'
      run = 'move-node-to-workspace V'

      [[on-window-detected]]
      if.app-id = 'com.loom.desktop'
      run = 'move-node-to-workspace V'

      # Workspace F - Finder (floating)
      [[on-window-detected]]
      if.app-id = 'com.apple.finder'
      run = ['layout floating', 'move-node-to-workspace F']

      # Workspace P - Productivity/Tools
      [[on-window-detected]]
      if.app-id = 'com.1password.1password'
      run = 'move-node-to-workspace P'

      [[on-window-detected]]
      if.app-id = 'com.raycast.macos'
      run = 'move-node-to-workspace P'

      # Floating windows (utilities and system apps)
      [[on-window-detected]]
      if.app-name-regex-substring = 'Shottr'
      run = 'layout floating'

      [[on-window-detected]]
      if.app-id = 'com.apple.systempreferences'
      run = 'layout floating'

      [[on-window-detected]]
      if.app-id = 'com.apple.ActivityMonitor'
      run = 'layout floating'

      [[on-window-detected]]
      if.app-id = 'com.apple.archiveutility'
      run = 'layout floating'

      [[on-window-detected]]
      if.app-id = 'com.apple.calculator'
      run = 'layout floating'

      [[on-window-detected]]
      if.app-name-regex-substring = '(?i)settings'
      run = 'layout floating'

      [[on-window-detected]]
      if.app-name-regex-substring = '(?i)preference'
      run = 'layout floating'
    '';
  };
}
