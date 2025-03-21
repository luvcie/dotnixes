{ pkgs, ... }:

{
            #######
            #SHELL#
            #######
  programs.starship.enable = true;
  programs.fzf.enable = true;
  programs.thefuck.enable = true;
  programs.zoxide.enable = true;

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
      mini="~/mini-moulinette/mini-moul.sh";
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
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "0.7.1";
          sha256 = "03r6hpb5fy4yaakqm3lbf4xcvd408r44jgpv4lnzl9asp4sb9qc0";
        };
      }
    ];

    initExtra = ''
      HISTSIZE=10000
      SAVEHIST=10000
      setopt SHARE_HISTORY
      setopt HIST_IGNORE_DUPS
      setopt AUTO_PUSHD
      setopt PUSHD_IGNORE_DUPS
      setopt PUSHD_SILENT
      setopt COMPLETE_ALIASES
      eval "$(direnv hook zsh)"
      eval "$(starship init zsh)"
    '';
  };
}
