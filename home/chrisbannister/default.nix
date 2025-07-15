{
  config,
  lib,
  pkgs,
  username,
  hostname,
  ...
}:
{
  imports = [
    ../_modules
    ./hosts/${hostname}.nix
  ];

  # Basic home configuration
  home = {
    username = username;
    homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
    stateVersion = "24.11";
  };

  # Enable modules
  myModules = {
    shell.fish.enable = true;
    programs.tmux.enable = true;
    programs.atuin.enable = true;
    programs.alacritty.enable = true;
  };

  # User-specific git configuration
  programs.git = {
    userName = "Chris Bannister";
    userEmail = "chris@chrisbannister.com"; # Update with your email
  };
}
