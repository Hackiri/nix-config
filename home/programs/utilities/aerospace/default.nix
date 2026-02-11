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

      # Accordion padding (px visible behind stacked windows, 0 = invisible)
      accordion-padding = 30

      # Default root container settings
      default-root-container-layout = 'tiles'
      default-root-container-orientation = 'auto'

      # Mouse follows focus (lazy = only moves if cursor is outside target)
      on-focused-monitor-changed = ['move-mouse monitor-lazy-center']
      on-focus-changed = ['move-mouse window-lazy-center']

      # Automatically unhide macOS hidden apps
      automatically-unhide-macos-hidden-apps = true

      # Key mapping preset
      [key-mapping]
      preset = 'qwerty'

      # Gaps settings
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

      # Optional: uncomment to enable JankyBorders for focused-window highlighting
      # after-startup-command = [
      #   'exec-and-forget borders active_color=0xffe1e3e4 inactive_color=0xff494d64 width=3.0'
      # ]

      # Workspace-to-monitor assignments (multi-monitor setup)
      [workspace-to-monitor-force-assignment]
      T = 'main'           # Terminal
      E = 'main'           # Editor
      D = 'main'           # Dev tools (Docker, Postman, DB)
      N = 'main'           # Notes & AI
      P = 'main'           # Productivity
      B = 'secondary'      # Browser
      M = 'secondary'      # Media/messaging
      V = 'secondary'      # Video

      # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      # Main mode
      # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      [mode.main.binding]

      # Quick terminal launch (most common action, stays in main mode)
      alt-shift-enter = 'exec-and-forget open -na ghostty'

      # Window management
      alt-q = 'close'
      alt-shift-q = 'close-all-windows-but-current'
      alt-slash = 'layout tiles horizontal vertical'
      alt-comma = 'layout accordion horizontal vertical'
      alt-period = 'layout floating tiling'
      # Note: 'split' is incompatible with normalization-flatten-containers
      # Use join-with in service mode (alt-shift-; then hjkl) for tree manipulation

      # Focus movement (alt+hjkl)
      alt-h = 'focus left'
      alt-j = 'focus down'
      alt-k = 'focus up'
      alt-l = 'focus right'

      # Toggle focus between last two windows
      alt-f = 'focus-back-and-forth'

      # Toggle between last two workspaces
      alt-tab = 'workspace-back-and-forth'

      # Focus monitors
      alt-left = 'focus-monitor left'
      alt-right = 'focus-monitor right'
      alt-up = 'focus-monitor up'
      alt-down = 'focus-monitor down'

      # Window movement (alt-shift+hjkl)
      alt-shift-h = 'move left'
      alt-shift-j = 'move down'
      alt-shift-k = 'move up'
      alt-shift-l = 'move right'

      # Move window to monitors
      alt-shift-left = 'move-node-to-monitor left'
      alt-shift-right = 'move-node-to-monitor right'
      alt-shift-up = 'move-node-to-monitor up'
      alt-shift-down = 'move-node-to-monitor down'

      # Resize windows (quick resize without entering resize mode)
      ctrl-alt-h = 'resize width -50'
      ctrl-alt-j = 'resize height +50'
      ctrl-alt-k = 'resize height -50'
      ctrl-alt-l = 'resize width +50'
      alt-shift-minus = 'resize smart -50'
      alt-shift-equal = 'resize smart +50'

      # Fullscreen
      alt-shift-f = 'fullscreen'
      alt-shift-m = 'macos-native-fullscreen'

      # Workspace switching (letter = semantic name)
      alt-b = 'workspace B'
      alt-d = 'workspace D'
      alt-e = 'workspace E'
      alt-m = 'workspace M'
      alt-n = 'workspace N'
      alt-p = 'workspace P'
      alt-t = 'workspace T'
      alt-v = 'workspace V'

      # Workspace cycling
      alt-leftSquareBracket = 'workspace prev --wrap-around'
      alt-rightSquareBracket = 'workspace next --wrap-around'

      # Move window to workspace
      alt-shift-b = 'move-node-to-workspace B'
      alt-shift-d = 'move-node-to-workspace D'
      alt-shift-e = 'move-node-to-workspace E'
      ctrl-alt-m = 'move-node-to-workspace M'  # alt-shift-m taken by native fullscreen
      alt-shift-n = 'move-node-to-workspace N'
      alt-shift-p = 'move-node-to-workspace P'
      alt-shift-t = 'move-node-to-workspace T'
      alt-shift-v = 'move-node-to-workspace V'

      # Balance and workspace management
      alt-enter = 'balance-sizes'
      alt-shift-tab = 'move-workspace-to-monitor --wrap-around next'

      # Enter modes
      alt-r = 'mode resize'
      alt-shift-semicolon = 'mode service'
      alt-shift-space = 'mode launch'

      # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      # Launch mode (alt-shift-space) - app launching with single keypress
      # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      [mode.launch.binding]
      # Terminals
      g = ['exec-and-forget open -na ghostty', 'mode main']
      a = ['exec-and-forget open -na alacritty', 'mode main']
      # Editors
      v = ['exec-and-forget open -na neovide', 'mode main']
      e = ['exec-and-forget open -a Emacs', 'mode main']
      c = ['exec-and-forget open -a "Visual Studio Code"', 'mode main']
      # Browser
      b = ['exec-and-forget open -a "Brave Browser"', 'mode main']
      # Communication
      t = ['exec-and-forget open -a Telegram', 'mode main']
      s = ['exec-and-forget open -a Slack', 'mode main']
      d = ['exec-and-forget open -a Discord', 'mode main']
      z = ['exec-and-forget open -a zoom.us', 'mode main']
      # Notes & productivity
      n = ['exec-and-forget open -a Notion', 'mode main']
      o = ['exec-and-forget open -a Obsidian', 'mode main']
      # Utilities
      f = ['exec-and-forget open -a Finder', 'mode main']
      p = ['exec-and-forget open -a Postman', 'mode main']
      # Exit
      esc = 'mode main'
      enter = 'mode main'

      # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      # Service mode (alt-shift-;) - config, layout, and tree manipulation
      # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      [mode.service.binding]
      # Reload config
      esc = ['reload-config', 'mode main']
      # Reset workspace layout tree
      r = ['flatten-workspace-tree', 'mode main']
      # Toggle floating/tiling
      f = ['layout floating tiling', 'mode main']
      # Close all windows but current
      backspace = ['close-all-windows-but-current', 'mode main']
      # Toggle AeroSpace on/off
      e = ['enable toggle', 'mode main']
      # Minimize window (macos-native-* must be last in command list)
      m = ['mode main', 'macos-native-minimize']
      # Join with adjacent windows (tree manipulation)
      h = ['join-with left', 'mode main']
      j = ['join-with down', 'mode main']
      k = ['join-with up', 'mode main']
      l = ['join-with right', 'mode main']

      # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      # Resize mode (alt-r) - resize windows without holding modifiers
      # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      [mode.resize.binding]
      h = 'resize width -50'
      j = 'resize height +50'
      k = 'resize height -50'
      l = 'resize width +50'
      minus = 'resize smart -50'
      equal = 'resize smart +50'
      b = ['balance-sizes', 'mode main']
      enter = 'mode main'
      esc = 'mode main'

      # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      # Window detection rules
      # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

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

      [[on-window-detected]]
      if.app-id = 'com.apple.Safari'
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

      [[on-window-detected]]
      if.app-id = 'co.zeit.hyper'
      run = 'move-node-to-workspace T'

      [[on-window-detected]]
      if.app-id = 'com.googlecode.iterm2'
      run = 'move-node-to-workspace T'

      # Workspace E - Editors
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

      [[on-window-detected]]
      if.app-name-regex-substring = '(?i)^jetbrains'
      run = 'move-node-to-workspace E'

      [[on-window-detected]]
      if.app-id = 'com.sublimetext.4'
      run = 'move-node-to-workspace E'

      [[on-window-detected]]
      if.app-id = 'dev.zed.Zed'
      run = 'move-node-to-workspace E'

      [[on-window-detected]]
      if.app-id = 'com.figma.Desktop'
      run = 'move-node-to-workspace E'

      # Workspace D - Dev tools (Docker, API clients, DB tools, Git GUIs)
      [[on-window-detected]]
      if.app-id = 'com.docker.docker'
      run = 'move-node-to-workspace D'

      [[on-window-detected]]
      if.app-id = 'com.postmanlabs.mac'
      run = 'move-node-to-workspace D'

      [[on-window-detected]]
      if.app-name-regex-substring = '(?i)insomnia'
      run = 'move-node-to-workspace D'

      [[on-window-detected]]
      if.app-id = 'com.tinyapp.TablePlus'
      run = 'move-node-to-workspace D'

      [[on-window-detected]]
      if.app-name-regex-substring = '(?i)dbeaver'
      run = 'move-node-to-workspace D'

      [[on-window-detected]]
      if.app-id = 'com.DanPristupov.Fork'
      run = 'move-node-to-workspace D'

      [[on-window-detected]]
      if.app-name-regex-substring = '(?i)tower'
      check-further-callbacks = true
      run = 'move-node-to-workspace D'

      [[on-window-detected]]
      if.app-name-regex-substring = '(?i)gitkraken'
      run = 'move-node-to-workspace D'

      [[on-window-detected]]
      if.app-name-regex-substring = '(?i)charles'
      run = 'move-node-to-workspace D'

      [[on-window-detected]]
      if.app-name-regex-substring = '(?i)proxyman'
      run = 'move-node-to-workspace D'

      # Workspace N - Notes & AI
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

      [[on-window-detected]]
      if.app-name-regex-substring = '(?i)chatgpt'
      run = 'move-node-to-workspace N'

      [[on-window-detected]]
      if.app-name-regex-substring = '(?i)claude'
      check-further-callbacks = true
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

      [[on-window-detected]]
      if.app-id = 'com.apple.FaceTime'
      run = 'move-node-to-workspace M'

      [[on-window-detected]]
      if.app-name-regex-substring = '(?i)microsoft teams'
      run = 'move-node-to-workspace M'

      # Workspace V - Video/Recording
      [[on-window-detected]]
      if.app-id = 'com.obsproject.obs-studio'
      run = 'move-node-to-workspace V'

      [[on-window-detected]]
      if.app-id = 'com.loom.desktop'
      run = 'move-node-to-workspace V'

      # Workspace P - Productivity/Tools
      [[on-window-detected]]
      if.app-id = 'com.1password.1password'
      run = 'move-node-to-workspace P'

      [[on-window-detected]]
      if.app-id = 'com.raycast.macos'
      run = 'move-node-to-workspace P'

      [[on-window-detected]]
      if.app-id = 'com.apple.iCal'
      run = 'move-node-to-workspace P'

      [[on-window-detected]]
      if.app-id = 'com.apple.mail'
      run = 'move-node-to-workspace P'

      [[on-window-detected]]
      if.app-name-regex-substring = '(?i)linear'
      check-further-callbacks = true
      run = 'move-node-to-workspace P'

      [[on-window-detected]]
      if.app-name-regex-substring = '(?i)jira'
      run = 'move-node-to-workspace P'

      # Floating windows (utilities and system apps)
      [[on-window-detected]]
      if.app-id = 'com.apple.finder'
      check-further-callbacks = true
      run = 'layout floating'

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
      if.app-id = 'com.apple.Passwords'
      check-further-callbacks = true
      run = 'layout floating'

      [[on-window-detected]]
      if.app-id = 'com.apple.ScreenSharing'
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
      if.window-title-regex-substring = '(?i)dialog|alert|popup|wizard'
      check-further-callbacks = true
      run = 'layout floating'
    '';
  };
}
