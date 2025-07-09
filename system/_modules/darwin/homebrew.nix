{ config, lib, pkgs, ... }:
let
  cfg = config.myModules.darwin.homebrew;
in
{
  options.myModules.darwin.homebrew = {
    enable = lib.mkEnableOption "Homebrew integration";
  };
  
  config = lib.mkIf (cfg.enable && pkgs.stdenv.isDarwin) {
    homebrew = {
      enable = true;
      
      onActivation = {
        autoUpdate = true;
        cleanup = "zap";
        upgrade = true;
      };
      
      # Taps
      taps = [
        "homebrew/cask-fonts"
      ];
      
      # Homebrew packages
      brews = [
        # Add any brew packages here
      ];
      
      # Cask applications
      casks = [
        # Browsers
        "firefox"
        "google-chrome"
        
        # Development
        "visual-studio-code"
        "iterm2"
        
        # Utilities
        "rectangle" # Window management
        "alfred"
        "1password"
        
        # Fonts
        "font-fira-code-nerd-font"
        "font-jetbrains-mono-nerd-font"
      ];
      
      # Mac App Store apps
      masApps = {
        # Add any Mac App Store apps here
        # "App Name" = app_id;
      };
    };
  };
}