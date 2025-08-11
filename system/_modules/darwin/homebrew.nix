{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myModules.darwin.homebrew;
in
{
  options.myModules.darwin.homebrew = {
    enable = lib.mkEnableOption "Homebrew integration";
  };

  config = lib.mkIf (cfg.enable && pkgs.stdenv.isDarwin) {
    homebrew = lib.mkIf (!(builtins.getEnv "CI" == "true")) {
      enable = true;

      onActivation = {
        autoUpdate = true;
        cleanup = "uninstall";
        upgrade = true;
      };

    };
  };
}
