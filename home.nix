{inputs, config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Magnificent app that corrects your previous console command, integrates with zsh.
  programs.thefuck.enable = true;

  home = {
    username = "lucie";
    homeDirectory = "/home/lucie";

    packages = with pkgs; [
        android-tools
		anbox
		ani-cli
		bat # A cat clone with syntax highlighting and Git integration.
		bitwarden
		bookworm
		cargo # Manage Rust projects and their module dependencies (crates).
		chromium
		clisp
		clojure
		cmatrix
		conda
		coolreader
		cowsay
		cups
		cwiid
		davinci-resolve
		deluge
		dino
		discordo
		emacs
		extremetuxracer
		figlet
		freedroidrpg
		gimp-with-plugins
		hugo # A fast and modern static website engine.
		inputs.lobster.packages."x86_64-linux".lobster #This is broken because of the API limit but hopefully it will be fixed one day.
		inputs.telescope.packages."x86_64-linux".default
		jdk
		leiningen
		libnotify
		librewolf
		micro
		minetest
		mpc-cli # Command line interface for MPD, MPD is a daemon for playing music.
		ncdu # A disk usage analyzer with an interactive interface.
		nchat # Terminal-based chat client with support for Telegram and WhatsApp
		neovim
		nheko
		nicotine-plus # Sovlseek
		obs-studio
		pacvim
		prismlauncher
		python3
		qemu
		retroshare
		sbcl # LISP compiler
		sl
		stardust # Space flight simulator.
		superTux
		superTuxKart
		telegram-desktop
		tetrio-desktop
		tgpt
		vimb
		vimgolf
		vitetris
		vlc
		waydroid
		webcord-vencord
		whatsapp-for-linux
		wipeout-rewrite
		wipeout-rewrite
		wl-clipboard # Command-line copy/paste utilities for Wayland.
		xwiimote
		yt-dlp

    ];

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "23.11"; # Please read the comment before changing.
  };
	nixpkgs.config.allowUnfreePredicate = _: true;
	programs.git.enable = true;
	programs.starship.enable = true;
	programs.fzf.enable = true;
	
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      enableVteIntegration = true;
      shellAliases = {
        run-with-xwayland = "env -u WAYLAND_DISPLAY";
      };

      # Install plugins
      plugins = [

        # Vi keybindings
        {
          name = "zsh-vi-mode";
          file = "./share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
          src = pkgs.zsh-vi-mode;
        }

        # Autosuggestions
        {
          name = "zsh-autosuggestions";
          file = "./share/zsh-autosuggestions/zsh-autosuggestions.zsh";
          src = pkgs.zsh-autosuggestions;
        }
      ];
    };
    # Configure kitty terminal
    programs.kitty = {

      # Enable kitty
      enable = true;

      # Configure font
      font = {
        name = "FiraCode Nerd Font";
        size = 12;
      };
    };
}
