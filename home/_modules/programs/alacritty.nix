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
  };
}