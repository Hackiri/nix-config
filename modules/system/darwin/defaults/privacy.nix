# Privacy, security defaults, and Spotlight settings
_: {
  system.defaults = {
    # Security: Keep Gatekeeper enabled — shows warning for unverified apps
    LaunchServices.LSQuarantine = true;
    loginwindow.GuestEnabled = false;

    CustomUserPreferences = {
      # Require password immediately after sleep/screen saver
      "com.apple.screensaver" = {
        askForPassword = 1;
        askForPasswordDelay = 0;
      };

      # Disable Siri data collection
      "com.apple.assistant.support" = {
        "Siri Data Sharing Opt-In Status" = 0;
      };

      # Disable crash reporter auto-submission
      "com.apple.CrashReporter" = {
        DialogType = "none";
      };

      # Prevent FileVault from being disabled
      "com.apple.MCX" = {
        dontAllowFDEDisable = true;
      };

      # Disable personalized advertising
      "com.apple.AdLib" = {
        allowApplePersonalizedAdvertising = false;
      };

      # Spotlight disabled — Raycast replaces all Spotlight functionality.
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
}
