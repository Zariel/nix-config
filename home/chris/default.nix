{ pkgs, ... }: {
  imports = [ ./fish.nix ./tmux.nix ./helix.nix ./git.nix ];

  home = {
    username = "chris";
    homeDirectory = "/home/chris";
    stateVersion = "25.05";
  };
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # Language servers
    nil
    gopls
    texlab
    ltex-ls
    ruff
    pyright

    # Formatters
    nixfmt-rfc-style

    htop
    btop
    claude-code
    atuin
    gpu-viewer
    wineWowPackages.waylandFull
    nh
    vlc
  ];

  programs = {
    fzf.enable = true;
    zoxide.enable = true;
    eza.enable = true;
    lutris.enable = true;
  };

  programs.ssh = {
    enable = true;
    matchBlocks."*" = { identityAgent = "/home/chris/.1password/agent.sock"; };
  };

}
