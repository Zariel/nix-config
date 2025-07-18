{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myModules.darwin.homebrew;
in
{
  options.myModules.darwin.homebrew = {
    enable = lib.mkEnableOption "Homebrew integration";
  };

  config = lib.mkIf (cfg.enable && pkgs.stdenv.isDarwin) {
    homebrew = lib.mkIf (!(builtins.getEnv "CI" == "true")) {
      enable = true;

      onActivation = {
        autoUpdate = true;
        cleanup = "uninstall";
        upgrade = true;
      };

      # Taps
      taps = [
      ];

      # Homebrew packages
      brews = [
      ];

      # Cask applications
      casks = [
        "1password"
        "firefox"
        "xld"
      ];

      # Mac App Store apps
      masApps = {
        # Add any Mac App Store apps here
        # "App Name" = app_id;
      };
    };
  };
}
