{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Overlay to fix streamrip on Darwin
  streamripOverlay = final: prev: {
    streamrip = prev.streamrip.overrideAttrs (oldAttrs: {
      # Remove hostname-debian dependency on Darwin
      buildInputs = builtins.filter (dep: dep.pname or "" != "hostname-debian") (
        oldAttrs.buildInputs or [ ]
      );
      propagatedBuildInputs = builtins.filter (dep: dep.pname or "" != "hostname-debian") (
        oldAttrs.propagatedBuildInputs or [ ]
      );
    });
  };

  # Apply overlay to pkgs
  pkgs' = pkgs.extend streamripOverlay;
in
{
  # macOS-specific home configuration

  # Additional packages for macOS
  home.packages = with pkgs'; [
    # macOS utilities
    mas # Mac App Store CLI
    dockutil

    flac
    streamrip
    ffmpeg
    sox
    mp3val
    unzip
    lame
    oxipng
    # mkvtoolnix-cli
    propolis

    kubectl
    talosctl
    talhelper
    cilium-cli
    cue
    cuelsp
    age
    sops
    fluxcd
    stern
    kustomize
    helmfile
    kubernetes-helm
    go-task

    claude-code
  ];

  # PATH management - Don't add Homebrew paths to ensure Nix has priority
  # Homebrew paths will be added by the system but after Nix paths

  programs.fish.shellAliases = {
    salmon = "/Users/chrisbannister/tools/smoked-salmon/.venv/bin/salmon";
    reflac = "flac -f8ep --replay-gain -j8 *.flac";
  };

  # XLD Plugin management
  home.file."Library/Application Support/XLD/PlugIns/XLDLogChecker.bundle" =
    let
      xldLogChecker = pkgs.stdenv.mkDerivation {
        name = "xld-log-checker";
        src = pkgs.fetchurl {
          url = "https://sourceforge.net/projects/xld/files/XLDLogChecker-20201230.zip/download";
          sha256 = "1h022q8c9x3q8hvkfkdi0fqhhq21d173n45fxl1w2ki1gb5l83bf";
        };

        buildInputs = [ pkgs.unzip ];

        unpackPhase = ''
          unzip $src
        '';

        installPhase = ''
          mkdir -p $out
          cp -r XLDLogChecker.bundle/* $out/
        '';
      };
    in
    {
      source = xldLogChecker;
      recursive = true;
    };
}
