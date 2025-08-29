{ pkgs, ... }: {
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      # Function to ensure our FZF binding overrides atuin
      function __post_atuin_setup --on-event fish_postexec
        # Re-bind our FZF widget to ensure it takes precedence over atuin
        if functions -q fzf-history-widget
          bind \cr fzf-history-widget 2>/dev/null
          if bind -M insert >/dev/null 2>&1
            bind -M insert \cr fzf-history-widget 2>/dev/null
          end
        end
      end

      set fish_greeting # Disable greeting

      # Better defaults
      set -Ux GIT_EDITOR hx

      # Homebrew settings
      set -Ux HOMEBREW_NO_ENV_HINTS 1

      # Go settings
      set -Ux GOBIN $HOME/bin

      # Add paths
      fish_add_path $HOME/bin
      fish_add_path $HOME/.local/bin

      # Kubernetes krew (if it exists)
      set -q KREW_ROOT; and fish_add_path $KREW_ROOT/.krew/bin; or fish_add_path $HOME/.krew/bin

      # Use default (emacs-style) key bindings, not vi mode
      fish_default_key_bindings

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

      # Define __fzfcmd function (needed for our custom history widget)
      function __fzfcmd
        test -n "$FZF_TMUX"; or set FZF_TMUX 0
        test -n "$FZF_TMUX_HEIGHT"; or set FZF_TMUX_HEIGHT 40%
        if [ -n "$FZF_TMUX_OPTS" ]
          echo "fzf-tmux $FZF_TMUX_OPTS -- "
        else if [ $FZF_TMUX -eq 1 ]
          echo "fzf-tmux -d$FZF_TMUX_HEIGHT -- "
        else
          echo "fzf"
        end
      end

      # Define __fzf_defaults function (needed for FZF configuration)
      function __fzf_defaults
        test -n "$FZF_DEFAULT_OPTS"; or set FZF_DEFAULT_OPTS ""
        test -n "$FZF_DEFAULT_OPTS_FILE"; or set FZF_DEFAULT_OPTS_FILE ~/.fzf
        set -l file_opts ""
        if test -f "$FZF_DEFAULT_OPTS_FILE"
          set file_opts (cat "$FZF_DEFAULT_OPTS_FILE")
        end
        echo "$FZF_DEFAULT_OPTS $file_opts $argv[1] $argv[2]"
      end

      # FZF + Atuin integration - Enhanced version from original dotfiles
      function fzf-history-widget -d "Show command history"
        test -n "$FZF_TMUX_HEIGHT"; or set FZF_TMUX_HEIGHT 40%
        
        # Use Perl version for better multi-line support and line numbering
        set -lx FZF_DEFAULT_OPTS (__fzf_defaults "" "-n2..,.. --scheme=history --bind=ctrl-r:toggle-sort --wrap-sign '"\t"↳ ' --highlight-line $FZF_CTRL_R_OPTS +m")
        set -lx FZF_DEFAULT_OPTS_FILE 
        atuin history list --print0 --cmd-only --reverse | command perl -0 -pe 's/^/$.\t/g; s/\n/\n\t/gm' | eval (__fzfcmd) --tac --read0 --print0 -q '(commandline)' | command perl -pe 's/^\d*\t//' | read -lz result
        and commandline -- $result
        
        commandline -f repaint
      end

      # Configure Atuin to not bind Ctrl+R (we'll bind it ourselves)
      set -Ux ATUIN_NOBIND true

      # Prevent FZF from setting up default key bindings
      set -Ux FZF_DISABLE_KEYBINDINGS 1

      # Function to bind our FZF widget after atuin initialization
      function __bind_fzf_history
        bind \cr fzf-history-widget
        if bind -M insert >/dev/null 2>&1
          bind -M insert \cr fzf-history-widget
        end
      end

      # Bind initially (unbind any existing first)
      bind -e \cr 2>/dev/null
      __bind_fzf_history

      # Ensure our FZF binding overrides atuin (run after all other inits)
      if functions -q fzf-history-widget
        bind \cr fzf-history-widget
        if bind -M insert >/dev/null 2>&1
          bind -M insert \cr fzf-history-widget
        end
      end
    '';

    loginShellInit = ''
      # Re-bind FZF history widget on login
      if functions -q fzf-history-widget
        bind \cr fzf-history-widget
        if bind -M insert >/dev/null 2>&1
          bind -M insert \cr fzf-history-widget
        end
      end
    '';

    shellAliases = {
      # Original aliases from dotfiles
      vim = "nvim";
      k = "kubectl";
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
                      echo (string replace -r '^refs/heads/' "" $branch)
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

          set -l host_info
          if set -q SSH_CONNECTION
              set host_info (prompt_login)" "
          end

          set -l arrow_color "$green"
          if test $__last_command_exit_status != 0
              set arrow_color "$red"
          end

          set -l arrow "$arrow_color➜ "
          if fish_is_root_user
              set arrow "$arrow_color# "
          end

          echo -n -s $host_info $arrow $cwd $repo_info $normal " "
        '';
      };
    };
  };
}
