{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.git;
in
{
  programs.git = {
    enable = lib.mkDefault true;

    userName = "Chris Bannister";
    userEmail = "chris@chrisbannister.com";

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

      column = {
        ui = "auto";
      };

      branch = {
        sort = "-committerdate";
      };

      tag = {
        sort = "version:refname";
      };

      diff = {
        algorithm = "histogram";
        colorMoved = "plain";
        mnemonicPrefix = true;
        renames = true;
      };

      push = {
        default = "simple";
        autoSetupRemote = true;
        followTags = true;
      };

      fetch = {
        prune = true;
        pruneTags = true;
        all = true;
      };

      status = {
        relativePaths = true;
      };

      help = {
        autocorrect = "prompt";
      };

      commit = {
        verbose = true;
      };

      rerere = {
        enabled = true;
        autoupdate = true;
      };

      core = {
        excludesfile = "~/.gitignore";
      };

      rebase = {
        autoSquash = true;
        autoStash = true;
        updateRefs = true;
      };

      merge = {
        conflictstyle = "diff3";
        tool = "vimdiff";
      };
    };
  };
}
