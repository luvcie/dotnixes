{inputs, config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
	programs.home-manager.enable = true;

  # Magnificent app that corrects your previous console command, integrates with zsh.
	programs.thefuck.enable = true;

  # Enable zoxide
	programs.zoxide.enable = true;
	programs.zoxide.enableBashIntegration = true;

  home = {
    username = "lucie";
    homeDirectory = "/home/lucie";

    packages = with pkgs; [
        android-tools
		anbox
		ani-cli
		any-nix-shell
		audacity
		bat # A cat clone with syntax highlighting and Git integration.
		bitwarden
		blahaj
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
		deluge
		discordo
		emacs
		extremetuxracer
		figlet
		freedroidrpg
		gimp-with-plugins
		hugo # A fast and modern static website engine.
		inputs.lobster.packages."x86_64-linux".lobster #This is broken because of the API limit but hopefully it will be fixed one day.
		inputs.telescope.packages."x86_64-linux".default
		inputs.envision.packages."x86_64-linux".default
		jdk
		leiningen
		libnotify
		librewolf
		lukesmithxyz-bible-kjv
		micro
		minetest
		ncdu # A disk usage analyzer with an interactive interface.
		nchat # Terminal-based chat client with support for Telegram and WhatsApp
		neovim
		nheko
		nicotine-plus # Sovlseek
		obs-studio
		pacvim
		prismlauncher
		porsmo # Pomodoro written in Rust.
		python3
		qemu
		retroshare
		sbcl # LISP compiler
		scanmem
		sl
		stardust # Space flight simulator.
		signal-desktop
		superTux
		superTuxKart
		telegram-desktop
		tetrio-desktop
		termdown # Countdown cli program.
		tomato-c # Pomodoro written in pure C.
		tgpt
		vesktop # Discord
		vimb
		vimgolf
		vitetris
		vlc
		waydroid
		waylyrics
		webcord-vencord
		whatsapp-for-linux
		wipeout-rewrite
		wipeout-rewrite
		wl-clipboard # Command-line copy/paste utilities for Wayland.
		xwiimote
		yt-dlp
  	  # Newly added:
	    blanket # play background sounds
		bleachbit # program to clean computer
    	dissent # GTK4 Discord client in Go
    	foliate # book reader
    	iperf # tool to measure IP bandwidth using UDP or TCP
    	mtr-gui # network diagnostics tool
    	remmina # remote desktop client
    	shellcheck # shell script analysis tool
    	shortwave # find and listen to internet radio stations
    	speedtest-go # CLI and Go API to Test Internet Speed using speedtest.net
    	tcpdump # network sniffer
    	trashy # simple, fast, and featureful alternative to rm and trash-cli
    	tuba # browse the Fediverse
    	rPackages.VedicDateTime
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

    # Configure Visual Studio Code
    programs.vscode = {

      # Enable VS Code
      enable = true;

      # Install extensions
      extensions = with pkgs.vscode-extensions; [

        # Utility
        ms-vsliveshare.vsliveshare
        shardulm94.trailing-spaces
        vscodevim.vim
        xaver.clang-format

        # Languages
        bbenoist.nix
        haskell.haskell
        ms-vscode.cpptools
        ms-dotnettools.csharp
        yzhang.markdown-all-in-one
      ];
    };

    # Add config file for VS Code
    xdg.configFile."Code/User/settings.json" = {
      text = ''
        {
          "editor.fontFamily": "'FiraCode Nerd Font', monospace",
          "editor.tabSize": 2,
          "editor.wordWrap": "wordWrapColumn",
          "explorer.confirmDelete": false,
          "git.confirmSync": false,
          "window.menuBarVisibility": "toggle",
          "window.zoomLevel": 1,
          "workbench.startupEditor": "none",
        }
      '';
    };
}
