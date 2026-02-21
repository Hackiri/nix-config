# macOS system defaults and preferences
_: {
  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true; # Enable pam-reattach for Touch ID in tmux
  };

  # macOS configuration
  system = {
    # Keyboard
    keyboard.enableKeyMapping = true;

    defaults = {
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        AppleShowScrollBars = "Always";
        NSUseAnimatedFocusRing = false;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        PMPrintingExpandedStateForPrint = true;
        PMPrintingExpandedStateForPrint2 = true;
        NSDocumentSaveNewDocumentsToCloud = false;
        ApplePressAndHoldEnabled = false;
        InitialKeyRepeat = 25;
        KeyRepeat = 2;
        "com.apple.mouse.tapBehavior" = 1;
        NSWindowShouldDragOnGesture = true;
        NSAutomaticSpellingCorrectionEnabled = false;
      };
      # Security: Keep Gatekeeper enabled - shows warning for unverified apps
      LaunchServices.LSQuarantine = true;
      loginwindow.GuestEnabled = false;
      # Finder — use native typed options where available
      finder = {
        FXPreferredViewStyle = "Nlsv";
        ShowExternalHardDrivesOnDesktop = true;
        ShowHardDrivesOnDesktop = false;
        ShowMountedServersOnDesktop = false;
        ShowRemovableMediaOnDesktop = true;
        _FXSortFoldersFirst = true;
        FXDefaultSearchScope = "SCcf";
        NewWindowTarget = "Other";
        NewWindowTargetPath = "file://$\{HOME\}/Desktop/";
        FXEnableExtensionChangeWarning = false;
        ShowStatusBar = true;
        ShowPathbar = true;
      };

      # Trackpad — declare tap-to-click and gestures
      trackpad = {
        Clicking = true; # tap to click
        TrackpadRightClick = true; # two-finger right click
        TrackpadThreeFingerDrag = true;
      };

      # Screenshots — save to ~/Screenshots as PNG, no window shadows
      screencapture = {
        location = "~/Screenshots";
        type = "png";
        disable-shadow = true;
      };

      # Window Manager — disable Stage Manager (AeroSpace handles tiling)
      WindowManager = {
        GloballyEnabled = false;
        EnableStandardClickToShowDesktop = false;
      };

      # Dock — use native typed options
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

      CustomUserPreferences = {
        #--------------------------------------------------
        # Security & Privacy Settings
        #--------------------------------------------------
        # Require password immediately after sleep/screen saver
        "com.apple.screensaver" = {
          askForPassword = 1;
          askForPasswordDelay = 0; # 0 = immediately
        };

        # Disable Siri data collection
        "com.apple.assistant.support" = {
          "Siri Data Sharing Opt-In Status" = 0;
        };

        # Disable crash reporter auto-submission
        "com.apple.CrashReporter" = {
          DialogType = "none";
        };

        # Prevent FileVault from being disabled (requires FileVault to be enabled first)
        "com.apple.MCX" = {
          dontAllowFDEDisable = true;
        };

        #--------------------------------------------------
        # Finder extras (not covered by typed options)
        #--------------------------------------------------
        "com.apple.finder" = {
          DisableAllAnimations = true;
          WarnOnEmptyTrash = false;
        };
        "com.apple.desktopservices" = {
          # Avoid creating .DS_Store files on network or USB volumes
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };

        # Dock extras (not covered by typed options)
        "com.apple.dock" = {
          enable-window-tool = false;
        };

        "com.apple.ActivityMonitor" = {
          OpenMainWindow = true;
          IconType = 5;
          SortColumn = "CPUUsage";
          SortDirection = 0;
        };
        "com.apple.AdLib" = {
          allowApplePersonalizedAdvertising = false;
        };
        "com.apple.TimeMachine".DoNotOfferNewDisksForBackup = true;
        # Prevent Photos from opening automatically when devices are plugged in
        "com.apple.ImageCapture".disableHotPlug = true;
        # Turn on app auto-update
        "com.apple.commerce".AutoUpdate = true;
        "com.googlecode.iterm2".PromptOnQuit = false;
        "com.google.Chrome" = {
          AppleEnableSwipeNavigateWithScrolls = true;
          DisablePrintPreview = true;
        };
        "com.apple.SoftwareUpdate" = {
          AutomaticCheckEnabled = true;
          # Check for software updates daily, not just once per week
          ScheduleFrequency = 1;
          # Download newly available updates in background
          AutomaticDownload = 1;
          # Install System data files & security updates
          CriticalUpdateInstall = 1;
        };
        # Spotlight disabled — Raycast (installed via homebrew.nix) replaces all Spotlight functionality.
        # Re-enable if not using Raycast or an alternative launcher.
        "com.apple.Spotlight" = {
          orderedItems = [
            {
              enabled = false;
              name = "APPLICATIONS";
            }
            {
              enabled = false;
              name = "MENU_SPOTLIGHT_SUGGESTIONS";
            }
            {
              enabled = false;
              name = "MENU_CONVERSION";
            }
            {
              enabled = false;
              name = "MENU_EXPRESSION";
            }
            {
              enabled = false;
              name = "MENU_DEFINITION";
            }
            {
              enabled = false;
              name = "SYSTEM_PREFS";
            }
            {
              enabled = false;
              name = "DOCUMENTS";
            }
            {
              enabled = false;
              name = "DIRECTORIES";
            }
            {
              enabled = false;
              name = "PRESENTATIONS";
            }
            {
              enabled = false;
              name = "SPREADSHEETS";
            }
            {
              enabled = false;
              name = "PDF";
            }
            {
              enabled = false;
              name = "MESSAGES";
            }
            {
              enabled = false;
              name = "CONTACT";
            }
            {
              enabled = false;
              name = "EVENT_TODO";
            }
            {
              enabled = false;
              name = "IMAGES";
            }
            {
              enabled = false;
              name = "BOOKMARKS";
            }
            {
              enabled = false;
              name = "MUSIC";
            }
            {
              enabled = false;
              name = "MOVIES";
            }
            {
              enabled = false;
              name = "FONTS";
            }
            {
              enabled = false;
              name = "MENU_OTHER";
            }
          ];
        };
      };
    };
  };
}
