{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf pkgs.stdenv.isLinux {
    xdg = {
      enable = true;

      # Set up XDG directories
      userDirs = {
        enable = true;
        createDirectories = true;
        desktop = "${config.home.homeDirectory}/Desktop";
        documents = "${config.home.homeDirectory}/Documents";
        download = "${config.home.homeDirectory}/Downloads";
        music = "${config.home.homeDirectory}/Music";
        pictures = "${config.home.homeDirectory}/Pictures";
        publicShare = "${config.home.homeDirectory}/Public";
        templates = "${config.home.homeDirectory}/Templates";
        videos = "${config.home.homeDirectory}/Videos";
      };

      # Configure mimeapps
      mimeApps = {
        enable = true;
      };
    };
  };
}
