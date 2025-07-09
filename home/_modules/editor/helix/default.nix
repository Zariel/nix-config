{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myModules.editor.helix;
in
{
  options.myModules.editor.helix = {
    enable = lib.mkEnableOption "Helix editor";

    theme = lib.mkOption {
      type = lib.types.str;
      default = "penumbra+";
      description = "Helix color theme";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.helix = {
      enable = true;

      settings = {
        theme = cfg.theme;

        editor = {
          end-of-line-diagnostics = "hint";

          inline-diagnostics = {
            cursor-line = "error";
          };

          soft-wrap = {
            enable = true;
          };

          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };

          file-picker = {
            hidden = false;
          };

          lsp = {
            display-messages = true;
            display-inlay-hints = true;
          };
        };

        keys.normal = {
          "C-d" = [
            "move_prev_word_start"
            "move_next_word_end"
            "search_selection"
            "extend_search_next"
          ];
        };
      };

      languages = {
        language-server = {
          gopls.config = {
            "formatting.gofumpt" = true;
          };

          ltex-ls.config.ltex = {
            language = "en-GB";
          };

          nil = {
            command = "nil";
          };
        };

        language = [
          {
            name = "latex";
            language-servers = [
              "texlab"
              "ltex-ls"
            ];
          }
          {
            name = "go";
            auto-format = true;
          }
          {
            name = "python";
            formatter = {
              command = "ruff";
              args = [
                "format"
                "--line-length"
                "88"
                "-"
              ];
            };
            auto-format = true;
          }
          {
            name = "nix";
            auto-format = true;
            formatter = {
              command = "nixfmt";
              args = [ ];
            };
            language-servers = [ "nil" ];
          }
        ];
      };
    };

    # Install language servers
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
    ];
  };
}
