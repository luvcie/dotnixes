{pkgs, ...}: {
  #######
  #SHELL#
  #######
  programs.starship.enable = true;
  programs.fzf.enable = true;
  programs.pay-respects.enable = true;
  programs.zoxide.enable = true;

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      auto_sync = true;
      sync_frequency = "5m";
      search_mode = "fuzzy";
      filter_mode = "global";
      workspaces = false;
      ctrl_n_shortcuts = true;
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    enableVteIntegration = true;

    shellAliases = {
      run-with-xwayland = "env -u WAYLAND_DISPLAY";
      ls = "ls --color=auto";
      ll = "ls -la";
      update = "sudo nixos-rebuild switch --flake .";
      clean = "sudo nix-collect-garbage -d";
      gs = "git status";
      gp = "git push";
      ga = "git add";
      gc = "git commit";
      ".." = "cd ..";
      "..." = "cd ../..";
      sysinfo = "macchina";
      temp = "sensors";
      bunnyfetch = "bunnyfetch 2>/dev/null";
      mini = "~/mini-moulinette/mini-moul.sh";
    };

    plugins = [
      {
        name = "zsh-vi-mode";
        file = "./share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
        src = pkgs.zsh-vi-mode;
      }
      {
        name = "zsh-autosuggestions";
        file = "./share/zsh-autosuggestions/zsh-autosuggestions.zsh";
        src = pkgs.zsh-autosuggestions;
      }
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.8.0";
          sha256 = "1lzrn0n4fxfcgg65v0qhnj7wnybybqzs4adz7xsrkgmcsr0ii8b7";
        };
      }
    ];

    initExtra = ''
      # Fall back to xterm-256color if current TERM's terminfo is missing (e.g. SSH from ghostty)
      if ! infocmp "$TERM" &>/dev/null; then
        export TERM=xterm-256color
      fi

      # Skip wezterm shell integration when not inside wezterm (~2.5s per prompt)
      [[ -z "$WEZTERM_PANE" ]] && export WEZTERM_SHELL_SKIP_ALL=1

      HISTSIZE=10000
      SAVEHIST=10000
      setopt SHARE_HISTORY
      setopt HIST_IGNORE_DUPS
      setopt AUTO_PUSHD
      setopt PUSHD_IGNORE_DUPS
      setopt PUSHD_SILENT
      setopt COMPLETE_ALIASES
      export PATH="$HOME/.npm-global/bin:$PATH"
    '';
  };
}
