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
        set -gx GIT_EDITOR hx
        set -gx PAGER less
        
        # Homebrew settings
        set -gx HOMEBREW_NO_ENV_HINTS 1
        
        # Go settings
        set -gx GOBIN $HOME/bin
        
        # Add paths
        fish_add_path $HOME/bin
        fish_add_path $HOME/.local/bin
        
        # Kubernetes krew (if it exists)
        set -q KREW_ROOT; and fish_add_path $KREW_ROOT/.krew/bin; or fish_add_path $HOME/.krew/bin
        
        # Enable vi mode
        fish_vi_key_bindings
        
        # Custom colors (Penumbra-inspired theme)
        set --universal fish_color_autosuggestion 4D5566
        set --universal fish_color_cancel \x2d\x2dreverse
        set --universal fish_color_command 39BAE6
        set --universal fish_color_comment 626A73
        set --universal fish_color_cwd 59C2FF
        set --universal fish_color_cwd_root red
        set --universal fish_color_end F29668
        set --universal fish_color_error FF3333
        set --universal fish_color_escape 95E6CB
        set --universal fish_color_history_current \x2d\x2dbold
        set --universal fish_color_host normal
        set --universal fish_color_match F07178
        set --universal fish_color_normal B3B1AD
        set --universal fish_color_operator E6B450
        set --universal fish_color_param B3B1AD
        set --universal fish_color_quote C2D94C
        set --universal fish_color_redirection FFEE99
        set --universal fish_color_search_match \x2d\x2dbackground\x3dE6B450
        set --universal fish_color_selection \x2d\x2dbackground\x3dE6B450
        set --universal fish_color_status red
        set --universal fish_color_user brgreen
        set --universal fish_color_valid_path \x2d\x2dunderline
        
        # Pager colors
        set --universal fish_pager_color_completion normal
        set --universal fish_pager_color_description B3A06D
        set --universal fish_pager_color_prefix normal\x1e\x2d\x2dbold\x1e\x2d\x2dunderline
        set --universal fish_pager_color_progress brwhite\x1e\x2d\x2dbackground\x3dcyan
        set --universal fish_pager_color_selected_background \x2d\x2dbackground\x3dE6B450
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
        
        # Legacy vim alias
        vim = "hx";  # Use helix instead of nvim
        
        # Kubernetes
        k = "kubectl";
        
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