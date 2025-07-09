{ config, lib, pkgs, ... }:
let
  cfg = config.myModules.programs.atuin;
in
{
  options.myModules.programs.atuin = {
    enable = lib.mkEnableOption "atuin shell history";
    
    syncAddress = lib.mkOption {
      type = lib.types.str;
      default = "https://sh.cbannister.xyz";
      description = "Atuin sync server address";
    };
  };
  
  config = lib.mkIf cfg.enable {
    programs.atuin = {
      enable = true;
      
      settings = {
        # Date format
        dialect = "uk";
        timezone = "local";
        
        # Sync settings
        auto_sync = true;
        sync_address = cfg.syncAddress;
        
        # UI settings
        enter_accept = true;
        
        # Filtering
        cwd_filter = [
          "^\\.stuff"
        ];
        
        # Stats and sync config
        stats = {};
        
        keys = {};
        
        sync = {
          records = true;
        };
        
        preview = {};
        
        daemon = {};
      };
    };
    
    # Enable atuin integration for fish
    programs.fish.interactiveShellInit = lib.mkAfter ''
      # Atuin integration - check multiple possible locations
      if command -q atuin
        atuin init fish | source
      else if test -x /opt/homebrew/bin/atuin
        /opt/homebrew/bin/atuin init fish | source
      end
    '';
  };
}