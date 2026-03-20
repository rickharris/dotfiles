{ ... }: {
  # Nix is managed by the Determinate Systems installer
  nix.enable = false;

  # Required for nix-darwin
  system.stateVersion = 6;
  system.primaryUser = "rick";
  users.users.rick.home = "/Users/rick";

  # Homebrew — manages GUI apps (casks) that Nix can't install as .app bundles
  homebrew = {
    enable = true;
    onActivation.cleanup = "uninstall"; # switch to "zap" once cask list is verified complete
    casks = [
      "1password"
      "claude"
      "claude-code"
      "firefox"
      "font-maple-mono-nf"
      "ghostty"
      "karabiner-elements"
      "visual-studio-code"
      "zen"
    ];
    masApps = {
      # Uncomment as desired
      # "1Password for Safari" = 1569813296;
      # "AdGuard for Safari" = 1440147259;
      # "Bear" = 1091189122;
      # "Hush" = 1544743900;
      # "Parcel" = 639968404;
    };
  };

  # macOS system settings — replaces the preferences() function from the dot script
  system.defaults = {
    dock = {
      autohide = true;
      show-recents = false;
      persistent-apps = [
        "/System/Applications/Mail.app"
        "/System/Applications/Calendar.app"
        "/System/Cryptexes/App/System/Applications/Safari.app"
        "/Applications/Zen.app"
        "/Applications/Ghostty.app"
      ];
    };

    finder = {
      FXPreferredViewStyle = "clmv";
      NewWindowTarget = "Home";
      AppleShowAllExtensions = true;
    };

    NSGlobalDomain = {
      ApplePressAndHoldEnabled = false;
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
      "com.apple.mouse.tapBehavior" = 1;
    };

    trackpad = {
      Clicking = true;
    };

    CustomUserPreferences = {
      "com.apple.Safari" = {
        IncludeDevelopMenu = true;
        WebKitDeveloperExtrasEnabledPreferenceKey = true;
        "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" = true;
        UniversalSearchEnabled = false;
        SuppressSearchSuggestions = true;
        WebKitTabToLinksPreferenceKey = true;
        "com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks" = true;
        AutoFillPasswords = false;
        AutoFillCreditCardData = false;
        AutoFillMiscellaneousForms = false;
        ShowStatusBar = true;
        ShowOverlayStatusBar = true;
        ShowStatusBarInFullScreen = true;
        SearchProviderIdentifier = "com.duckduckgo";
        SafariGeolocationPermissionPolicy = 2;
      };
      NSGlobalDomain = {
        NSProviderIdentifier = "com.duckduckgo";
      };
    };
  };

  # Enable Touch ID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  # Private config extension point — uncomment to load machine-specific overrides
  # imports = lib.optional (builtins.pathExists ~/.config/nix-local/darwin.nix)
  #   ~/.config/nix-local/darwin.nix;
}
