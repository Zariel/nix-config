{ config, lib, pkgs, ... }:
let
  cfg = config.programs.git;
in
{
  programs.git = {
    enable = lib.mkDefault true;
    
    delta = {
      enable = true;
      options = {
        navigate = true;
        light = false;
        side-by-side = true;
      };
    };
    
    # Global ignore patterns
    ignores = [
      "**/.claude/settings.local.json"
      ".DS_Store"
      "*.swp"
      "*.swo"
      "*~"
      ".env.local"
      ".vscode/"
      ".idea/"
    ];
    
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      
      merge = {
        conflictstyle = "diff3";
        tool = "vimdiff";
      };
      
      diff = {
        colorMoved = "default";
      };
      
      rerere = {
        enabled = true;
      };
    };
  };
}