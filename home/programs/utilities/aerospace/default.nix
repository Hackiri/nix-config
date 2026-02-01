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

      # Recommended macOS settings for better window management (run once in terminal):
      # defaults write -g NSAutomaticWindowAnimationsEnabled -bool false
      # defaults write -g NSWindowShouldDragOnGesture -bool true
      # defaults write com.apple.spaces spans-displays -bool true && killall SystemUIServer

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

      # Workspace-to-monitor assignments (multi-monitor setup)
      [workspace-to-monitor-force-assignment]
      T = 'main'           # Terminal on main monitor
      E = 'main'           # Editor on main monitor
      P = 'main'           # Productivity on main monitor
      B = 'secondary'      # Browser on secondary
      M = 'secondary'      # Media on secondary
      V = 'secondary'      # Video on secondary

      # Main mode bindings
      [mode.main.binding]
      # Launch applications
      alt-shift-enter = 'exec-and-forget open -na ghostty'
      cmd-shift-enter = 'exec-and-forget open -na alacritty'
      ctrl-alt-b = 'exec-and-forget open -a "Brave Browser"'
      ctrl-alt-t = 'exec-and-forget open -a "Telegram"'
      ctrl-alt-f = 'exec-and-forget open -a Finder'
      ctrl-alt-n = 'exec-and-forget open -a Notion'
      ctrl-alt-o = 'exec-and-forget open -a Obsidian'
      ctrl-alt-v = 'exec-and-forget open -na neovide'

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

      # Enter resize mode (allows hjkl resizing without holding modifiers)
      alt-r = 'mode resize'

      # Workspace management - letter-based for semantic clarity
      alt-b = 'workspace B' # for browser
      alt-e = 'workspace E' #
      alt-m = 'workspace M' #
      alt-n = 'workspace N' # for notes
      alt-p = 'workspace P'
      alt-t = 'workspace T' # for terminal shell
      alt-v = 'workspace V'

      # Move windows to workspaces
      alt-shift-b = 'move-node-to-workspace B'
      alt-shift-e = 'move-node-to-workspace E'
      ctrl-alt-m = 'move-node-to-workspace M'  # alt-shift-m is macos-native-fullscreen
      alt-shift-n = 'move-node-to-workspace N'
      alt-shift-p = 'move-node-to-workspace P'
      alt-shift-t = 'move-node-to-workspace T'
      alt-shift-v = 'move-node-to-workspace V'

      # Workspace navigation - enhanced with back-and-forth
      # Balance window sizes (repurposed from duplicate workspace-back-and-forth)
      alt-enter = 'balance-sizes'
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

      # Resize mode - allows quick resizing without holding modifier keys
      [mode.resize.binding]
      h = 'resize width -50'
      j = 'resize height +50'
      k = 'resize height -50'
      l = 'resize width +50'
      minus = 'resize smart -50'
      equal = 'resize smart +50'
      enter = 'mode main'
      esc = 'mode main'

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

      # Finder (floating, no dedicated workspace)
      [[on-window-detected]]
      if.app-id = 'com.apple.finder'
      check-further-callbacks = true
      run = 'layout floating'

      # Workspace P - Productivity/Tools
      [[on-window-detected]]
      if.app-id = 'com.1password.1password'
      run = 'move-node-to-workspace P'

      [[on-window-detected]]
      if.app-id = 'com.raycast.macos'
      run = 'move-node-to-workspace P'

      # Floating windows (utilities and system apps)
      # check-further-callbacks allows floating windows to still be moved to workspaces
      [[on-window-detected]]
      if.app-name-regex-substring = 'Shottr'
      check-further-callbacks = true
      run = 'layout floating'

      [[on-window-detected]]
      if.app-id = 'com.apple.systempreferences'
      check-further-callbacks = true
      run = 'layout floating'

      [[on-window-detected]]
      if.app-id = 'com.apple.ActivityMonitor'
      check-further-callbacks = true
      run = 'layout floating'

      [[on-window-detected]]
      if.app-id = 'com.apple.archiveutility'
      check-further-callbacks = true
      run = 'layout floating'

      [[on-window-detected]]
      if.app-id = 'com.apple.calculator'
      check-further-callbacks = true
      run = 'layout floating'

      [[on-window-detected]]
      if.app-id = 'com.apple.Preview'
      check-further-callbacks = true
      run = 'layout floating'

      [[on-window-detected]]
      if.app-id = 'com.apple.TextEdit'
      check-further-callbacks = true
      run = 'layout floating'

      [[on-window-detected]]
      if.app-id = 'com.apple.QuickTimePlayerX'
      check-further-callbacks = true
      run = 'layout floating'

      [[on-window-detected]]
      if.app-name-regex-substring = '(?i)settings'
      check-further-callbacks = true
      run = 'layout floating'

      [[on-window-detected]]
      if.app-name-regex-substring = '(?i)preference'
      check-further-callbacks = true
      run = 'layout floating'

      [[on-window-detected]]
      if.window-title-regex-substring = '(?i)dialog|alert|popup'
      check-further-callbacks = true
      run = 'layout floating'
    '';
  };
}
