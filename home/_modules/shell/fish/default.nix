{ config, lib, pkgs, ... }:
let
  cfg = config.myModules.shell.fish;
in
{
  options.myModules.shell.fish = {
    enable = lib.mkEnableOption "Fish shell";
  };
  
  config = lib.mkIf cfg.enable {
    programs.fish = {
      enable = true;
      
      interactiveShellInit = ''
        set fish_greeting # Disable greeting
        
        # Better defaults
        set -gx EDITOR hx
        set -gx VISUAL hx
        set -gx GIT_EDITOR hx
        set -gx PAGER less
        
        # Homebrew settings
        set -gx HOMEBREW_NO_ENV_HINTS 1
        
        # Go settings
        set -gx GOBIN $HOME/bin
        
        # Add paths
        fish_add_path $HOME/bin
        fish_add_path $HOME/.local/bin
        
        # Kubernetes krew (if it exists)
        set -q KREW_ROOT; and fish_add_path $KREW_ROOT/.krew/bin; or fish_add_path $HOME/.krew/bin
        
        # Enable vi mode
        fish_vi_key_bindings
        
        # Custom colors (Penumbra-inspired theme)
        set --universal fish_color_autosuggestion 4D5566
        set --universal fish_color_cancel \x2d\x2dreverse
        set --universal fish_color_command 39BAE6
        set --universal fish_color_comment 626A73
        set --universal fish_color_cwd 59C2FF
        set --universal fish_color_cwd_root red
        set --universal fish_color_end F29668
        set --universal fish_color_error FF3333
        set --universal fish_color_escape 95E6CB
        set --universal fish_color_history_current \x2d\x2dbold
        set --universal fish_color_host normal
        set --universal fish_color_match F07178
        set --universal fish_color_normal B3B1AD
        set --universal fish_color_operator E6B450
        set --universal fish_color_param B3B1AD
        set --universal fish_color_quote C2D94C
        set --universal fish_color_redirection FFEE99
        set --universal fish_color_search_match \x2d\x2dbackground\x3dE6B450
        set --universal fish_color_selection \x2d\x2dbackground\x3dE6B450
        set --universal fish_color_status red
        set --universal fish_color_user brgreen
        set --universal fish_color_valid_path \x2d\x2dunderline
        
        # Pager colors
        set --universal fish_pager_color_completion normal
        set --universal fish_pager_color_description B3A06D
        set --universal fish_pager_color_prefix normal\x1e\x2d\x2dbold\x1e\x2d\x2dunderline
        set --universal fish_pager_color_progress brwhite\x1e\x2d\x2dbackground\x3dcyan
        set --universal fish_pager_color_selected_background \x2d\x2dbackground\x3dE6B450
        
        # Override ls function with eza
        function ls --wraps eza --description 'Use eza instead of ls'
          command eza $argv
        end
        
        # FZF + Atuin integration
        function fzf-history-widget -d "Show command history"
          test -n "$FZF_TMUX_HEIGHT"; or set FZF_TMUX_HEIGHT 40%
          begin
            set -l FISH_MAJOR (echo $version | cut -f1 -d.)
            set -l FISH_MINOR (echo $version | cut -f2 -d.)
            
            if [ "$FISH_MAJOR" -gt 2 -o \( "$FISH_MAJOR" -eq 2 -a "$FISH_MINOR" -ge 4 \) ]
              if type -P perl >/dev/null 2>&1
                set -lx FZF_DEFAULT_OPTS "--height $FZF_TMUX_HEIGHT --bind=ctrl-z:ignore -n2..,.. --scheme=history --bind=ctrl-r:toggle-sort --wrap-sign '\t↳ ' --highlight-line +m"
                atuin history list --print0 --cmd-only --reverse | command perl -0 -pe 's/^/$.\t/g; s/\n/\n\t/gm' | fzf --tac --read0 --print0 -q '(commandline)' | command perl -pe 's/^\d*\t//' | read -lz result
                and commandline -- $result
              else
                set -lx FZF_DEFAULT_OPTS "--height $FZF_TMUX_HEIGHT --bind=ctrl-z:ignore --scheme=history --bind=ctrl-r:toggle-sort --wrap-sign '\t↳ ' --highlight-line +m"
                atuin history list --print0 --cmd-only | fzf --read0 --print0 -q '(commandline)' | read -lz result
                and commandline -- $result
              end
            else
              builtin history | fzf -q '(commandline)' | read -l result
              and commandline -- $result
            end
          end
          commandline -f repaint
        end
        
        # Bind Ctrl+R to fzf-history-widget
        bind \cr fzf-history-widget
        if bind -M insert >/dev/null 2>&1
          bind -M insert \cr fzf-history-widget
        end
      '';
      
      shellAliases = {
        # Navigation
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
        
        # Replacements
        ll = "eza -l";
        la = "eza -la";
        tree = "eza --tree";
        cat = "bat";
        
        # Legacy vim alias
        vim = "hx";  # Use helix instead of nvim
        
        # Kubernetes
        k = "kubectl";
        
        # Git shortcuts
        g = "git";
        gs = "git status";
        ga = "git add";
        gc = "git commit";
        gp = "git push";
        gl = "git log --oneline --graph";
        
        # Nix shortcuts
        nr = "nixos-rebuild";
        nrs = "nixos-rebuild switch";
        nfu = "nix flake update";
        nfc = "nix flake check";
        ndev = "nix develop";
      };
      
      plugins = [
        {
          name = "z";
          src = pkgs.fishPlugins.z.src;
        }
        {
          name = "done";
          src = pkgs.fishPlugins.done.src;
        }
      ];
      
      functions = {
        fish_prompt = {
          body = ''
            set -l __last_command_exit_status $status

            if not set -q -g __fish_arrow_functions_defined
                set -g __fish_arrow_functions_defined
                function _git_branch_name
                    set -l branch (git symbolic-ref --quiet HEAD 2>/dev/null)
                    if set -q branch[1]
                        echo (string replace -r '^refs/heads/' \'\' $branch)
                    else
                        echo (git rev-parse --short HEAD 2>/dev/null)
                    end
                end

                function _is_git_dirty
                    not command git diff-index --cached --quiet HEAD -- &>/dev/null
                    or not command git diff --no-ext-diff --quiet --exit-code &>/dev/null
                end

                function _is_git_repo
                    type -q git
                    or return 1
                    git rev-parse --git-dir >/dev/null 2>&1
                end

                function _hg_branch_name
                    echo (hg branch 2>/dev/null)
                end

                function _is_hg_dirty
                    set -l stat (hg status -mard 2>/dev/null)
                    test -n "$stat"
                end

                function _is_hg_repo
                    fish_print_hg_root >/dev/null
                end

                function _repo_branch_name
                    _$argv[1]_branch_name
                end

                function _is_repo_dirty
                    _is_$argv[1]_dirty
                end

                function _repo_type
                    if _is_hg_repo
                        echo hg
                        return 0
                    else if _is_git_repo
                        echo git
                        return 0
                    end
                    return 1
                end
            end

            set -l cyan (set_color -o cyan)
            set -l yellow (set_color -o yellow)
            set -l red (set_color -o red)
            set -l green (set_color -o green)
            set -l blue (set_color -o blue)
            set -l normal (set_color normal)

            set -l arrow_color "$green"
            if test $__last_command_exit_status != 0
                set arrow_color "$red"
            end

            set -l arrow "$arrow_color➜ "
            if fish_is_root_user
                set arrow "$arrow_color# "
            end

            set -l cwd $cyan(basename (prompt_pwd))

            set -l repo_info
            if set -l repo_type (_repo_type)
                set -l repo_branch $red(_repo_branch_name $repo_type)
                set repo_info "$blue $repo_type:($repo_branch$blue)"

                if _is_repo_dirty $repo_type
                    set -l dirty "$yellow ✗"
                    set repo_info "$repo_info$dirty"
                end
            end

            echo -n -s $arrow \' \' $cwd $repo_info $normal \' \'
          '';
        };
      };
    };
    
  };
}