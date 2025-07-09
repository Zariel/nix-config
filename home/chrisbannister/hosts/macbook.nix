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
  ];

  # macOS-specific shell configuration
  programs.fish.interactiveShellInit = lib.mkAfter ''
    # Add Homebrew to PATH if it exists
    if test -d /opt/homebrew/bin
      set -gx PATH /opt/homebrew/bin $PATH
    end
  '';
}
