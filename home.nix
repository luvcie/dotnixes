{inputs, config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home = {
    username = "lucie";
    homeDirectory = "/home/lucie";

    packages = with pkgs; [
		neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
		emacs
		micro
		clisp
		ani-cli
		webcord-vencord
		discordo
		nheko
		vlc
		bitwarden
		librewolf
		prismlauncher
		minetest
		superTuxKart
		superTux
		extremetuxracer
		wipeout-rewrite
		tetrio-desktop
		vitetris
		deluge
		qemu
		freedroidrpg
		cwiid
		xwiimote
		jdk
		leiningen
		clojure
		gimp
		conda
		python3
		cups
		retroshare
		anbox
		waydroid
		inputs.lobster.packages."x86_64-linux".lobster
		wipeout-rewrite
		bookworm
		coolreader
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
