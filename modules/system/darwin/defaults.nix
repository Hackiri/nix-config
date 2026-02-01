# macOS system defaults and preferences
_: {
  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;

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
      finder.FXPreferredViewStyle = "Nlsv";

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
        # Finder Settings
        #--------------------------------------------------
        "com.apple.finder" = {
          ShowExternalHardDrivesOnDesktop = true;
          ShowHardDrivesOnDesktop = false;
          ShowMountedServersOnDesktop = false;
          ShowRemovableMediaOnDesktop = true;
          _FXSortFoldersFirst = true;
          # When performing a search, search the current folder by default
          FXDefaultSearchScope = "SCcf";
          DisableAllAnimations = true;
          NewWindowTarget = "PfDe";
          NewWindowTargetPath = "file://$\{HOME\}/Desktop/";
          FXEnableExtensionChangeWarning = false;
          ShowStatusBar = true;
          ShowPathbar = true;
          WarnOnEmptyTrash = false;
        };
        "com.apple.desktopservices" = {
          # Avoid creating .DS_Store files on network or USB volumes
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
        "com.apple.dock" = {
          autohide = false;
          launchanim = false;
          static-only = false;
          show-recents = false;
          show-process-indicators = true;
          orientation = "left";
          tilesize = 36;
          minimize-to-application = true;
          mineffect = "scale";
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
      };
    };
  };
}
