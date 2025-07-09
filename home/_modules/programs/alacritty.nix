{ config, lib, pkgs, ... }:
let
  cfg = config.myModules.programs.alacritty;
in
{
  options.myModules.programs.alacritty = {
    enable = lib.mkEnableOption "Alacritty terminal emulator";
    
    fontSize = lib.mkOption {
      type = lib.types.int;
      default = 13;
      description = "Font size for Alacritty";
    };
  };
  
  config = lib.mkIf cfg.enable {
    programs.alacritty = {
      enable = true;
      
      settings = {
        window = {
          startup_mode = "Maximized";
          option_as_alt = "OnlyLeft";
        };
        
        font = {
          size = cfg.fontSize;
        };
        
        keyboard = {
          bindings = [
            { key = "ArrowLeft"; mods = "Command"; action = "SelectPreviousTab"; }
            { key = "ArrowRight"; mods = "Command"; action = "SelectNextTab"; }
          ];
        };
        
        general = {
          live_config_reload = true;
        };
        
      };
    };
    
    # Create app bundle for macOS dock integration
    home.activation.aliasApplications = lib.mkIf pkgs.stdenv.isDarwin (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        app_folder="$HOME/Applications/Home Manager Apps"
        if [[ ! -d "$app_folder" ]]; then
          $DRY_RUN_CMD mkdir -p "$app_folder"
        fi
        
        # Remove old Alacritty alias if it exists
        $DRY_RUN_CMD rm -f "$app_folder/Alacritty.app"
        
        # Create new alias to the Nix-installed Alacritty
        if [[ -d "${pkgs.alacritty}/Applications/Alacritty.app" ]]; then
          $DRY_RUN_CMD ln -sf "${pkgs.alacritty}/Applications/Alacritty.app" "$app_folder/"
        fi
      ''
    );
  };
}