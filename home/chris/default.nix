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
  ];

  programs = {
    fzf.enable = true;
    zoxide.enable = true;
    eza.enable = true;
  };

  programs.ssh = {
    enable = true;
    matchBlocks."*" = { identityAgent = "/home/chris/.1password/agent.sock"; };
  };

  programs.nh = {
    enable = true;
    flake = "/home/chris/nix-config";
    clean = {
      enable = true;
      extraArgs = "--keep 5 --keep-since 3d";
    };
  };

}
