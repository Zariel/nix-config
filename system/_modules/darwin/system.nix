{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Only apply on Darwin systems
  config = lib.mkIf pkgs.stdenv.isDarwin {
    # macOS system defaults
    system.defaults = {
      # Dock settings
      dock = {
        autohide = true;
        show-recents = false;
        tilesize = 48;
        minimize-to-application = true;
        show-process-indicators = true;
        orientation = "bottom";
        mru-spaces = false;
      };

      # Finder settings
      finder = {
        AppleShowAllExtensions = true;
        FXEnableExtensionChangeWarning = false;
        _FXShowPosixPathInTitle = true;
        FXPreferredViewStyle = "clmv"; # Column view
        ShowPathbar = true;
        ShowStatusBar = true;
      };

      # Global macOS settings
      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        AppleInterfaceStyleSwitchesAutomatically = false;
        ApplePressAndHoldEnabled = false;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
      };

      # Control center
      controlcenter = {
        BatteryShowPercentage = true;
        Sound = true;
      };

      # Login window
      loginwindow = {
        GuestEnabled = false;
      };

      # Spaces
      spaces = {
        spans-displays = false;
      };

      # Trackpad
      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = true;
      };
    };

    # Enable Touch ID for sudo
    security.pam.services.sudo_local.touchIdAuth = true;

    # Shell configuration
    environment.shells = with pkgs; [
      fish
      bash
      zsh
    ];

    # System packages
    environment.systemPackages = with pkgs; [
      terminal-notifier
    ];
  };
}
