{
  config,
  lib,
  pkgs,
  ...
}:
{
  # macOS-specific home configuration

  # Additional packages for macOS
  home.packages = with pkgs; [
    # macOS utilities
    mas # Mac App Store CLI
    dockutil

    flac
    streamrip
    ffmpeg
    # mkvtoolnix-cli
  ];

  # PATH management - local tools first, then Homebrew after Nix paths
  home.sessionPath = lib.mkAfter [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
  ];

  programs.fish.shellAliases = {
    salmon = "/Users/chrisbannister/tools/smoked-salmon/.venv/bin/salmon";
    reflac = "flac -f8ep --replay-gain -j8 *.flac";
  };
}
