{ config, lib, pkgs, ... }:
let
  cfg = config.myModules.shell.fish;
in
{
  options.myModules.shell.fish = {
    enable = lib.mkEnableOption "Fish shell";
  };
  
  config = lib.mkIf cfg.enable {
    programs.fish = {
      enable = true;
      
      interactiveShellInit = ''
        set fish_greeting # Disable greeting
        
        # Better defaults
        set -gx EDITOR hx
        set -gx VISUAL hx
        set -gx PAGER less
        
        # Enable vi mode
        fish_vi_key_bindings
      '';
      
      shellAliases = {
        # Navigation
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
        
        # Replacements
        ls = "eza";
        ll = "eza -l";
        la = "eza -la";
        tree = "eza --tree";
        cat = "bat";
        
        # Git shortcuts
        g = "git";
        gs = "git status";
        ga = "git add";
        gc = "git commit";
        gp = "git push";
        gl = "git log --oneline --graph";
        
        # Nix shortcuts
        nr = "nixos-rebuild";
        nrs = "nixos-rebuild switch";
        nfu = "nix flake update";
        nfc = "nix flake check";
        ndev = "nix develop";
      };
      
      plugins = [
        {
          name = "z";
          src = pkgs.fishPlugins.z.src;
        }
        {
          name = "fzf-fish";
          src = pkgs.fishPlugins.fzf-fish.src;
        }
        {
          name = "done";
          src = pkgs.fishPlugins.done.src;
        }
      ];
    };
    
    # Enable starship prompt
    programs.starship = {
      enable = true;
      enableFishIntegration = true;
      
      settings = {
        format = lib.concatStrings [
          "$username"
          "$hostname"
          "$directory"
          "$git_branch"
          "$git_state"
          "$git_status"
          "$cmd_duration"
          "$line_break"
          "$character"
        ];
        
        directory = {
          style = "blue bold";
          truncation_length = 3;
          truncate_to_repo = false;
        };
        
        git_branch = {
          style = "green bold";
          format = "[$branch]($style) ";
        };
        
        git_status = {
          style = "red bold";
          format = "[$all_status$ahead_behind]($style) ";
        };
        
        character = {
          success_symbol = "[❯](purple bold)";
          error_symbol = "[❯](red bold)";
          vimcmd_symbol = "[❮](green bold)";
        };
      };
    };
  };
}