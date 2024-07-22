{
  inputs,
  config,
  pkgs,
  ...
}: {
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home = {
    username = "lucie";
    homeDirectory = "/home/lucie";

    packages = with pkgs; [
      # Flake inputs
      inputs.lobster.packages."x86_64-linux".lobster #This is broken because of the API limit but hopefully it will be fixed one day.

      # Packages
      tuxguitar
      lilypond
      openvas-scanner
      audiness
      vcv-rack
      flamegraph
      linuxKernel.packages.linux_xanmod_latest.perf
      proton-caller
      lolcat
      alejandra
      android-tools
      anbox
      ani-cli
      any-nix-shell
      appimage-run
      audacity
      bat # A cat clone with syntax highlighting and Git integration.
      bitwarden
      blahaj
      cargo # Manage Rust projects and their module dependencies (crates).
      cbonsai
      clisp
      clojure
      cmatrix
      cowsay
      cups
      chromium
      cwiid
      deluge
      discordo
      emacs
      extremetuxracer
      figlet
      freedroidrpg
      friture
      flameshot
      hugo # A fast and modern static website engine.
      jdk
      foliate
      leiningen
      libnotify
      librewolf
      lukesmithxyz-bible-kjv
      micro
      minetest
      mov-cli
      ncdu # A disk usage analyzer with an interactive interface.
      nchat # Terminal-based chat client with support for Telegram and WhatsApp
      neovim
      nheko
      nicotine-plus # Sovlseek
      obs-studio
      pacvim
      prismlauncher
      porsmo # Pomodoro written in Rust.
      qemu
      retroshare
      sbcl # LISP compiler
      scanmem
      sl
      stardust # Space flight simulator.
      signal-desktop
      superTux
      superTuxKart
      speedtest-go
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
      kdePackages.kdeconnect-kde
      hollywood
      waydroid
      waylyrics
      webcord-vencord
      wipeout-rewrite
      wl-clipboard # Command-line copy/paste utilities for Wayland.
      qbittorrent
      xwiimote
      yt-dlp
      terraform
      libgcc
      yazi
      virtualenv
      python312Packages.pip
      python3
      ledger-live-desktop
      zathura
      wineWowPackages.waylandFull
      cli-visualizer
      # # # Newly added:
      blanket # play background sounds
      bleachbit # program to clean computer
      dissent # GTK4 Discord client in Go
      iperf # tool to measure IP bandwidth using UDP or TCP
      mtr-gui # network diagnostics tool
      remmina # remote desktop client
      shellcheck # shell script analysis tool
      shortwave # find and listen to internet radio stations
      tcpdump # network sniffer
      trashy # simple, fast, and featureful alternative to rm and trash-cli
      tuba # browse the Fediverse
      rPackages.VedicDateTime
      iotop
      theharvester
      krabby
      macchina
      asciicam
      fswebcam
      libwebcam
      webcamoid
      gst_all_1.gstreamer
      v4l2-relayd
      gpt4all
      # # # Pentesting
      # 802-11
      aircrack-ng # wireless WEP/WPA cracking utilities
      bully # Implementation of the WPS brute force attack, written in C
      cowpatty # Brute-force WPA dictionary attack
      hashcat # World's fastest and most advanced password recovery utility
      iw # tool for configuring Linux wireless devices
      macchanger # utility for manipulating the MAC address of network interfaces
      pixiewps # Offline WPS bruteforce tool
      reaverwps-t6x # brute force attack tool against Wifi Protected Setup PIN number
      wifite2 # Python script to automate wireless auditing using aircrack-ng tools
      wordlists # collection of wordlists useful for security testing
      ghidra
      libgcc
      burpsuite
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

  # Magnificent app that corrects your previous console command, integrates with zsh.
  programs.thefuck.enable = true;

  # Enable zoxide
  programs.zoxide.enable = true;

  # Sway
    wayland.windowManager.sway = {
    enable = true;
    config = rec {
      modifier = "Mod4";
      # Use kitty as default terminal
      terminal = "kitty"; 
      startup = [
        # Launch application on start
        {command = "supertuxkart";}
      ];
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
      tomoki1207.pdf
      continue.continue
      eg2.vscode-npm-script

      # Languages
      bbenoist.nix
      haskell.haskell
      ms-vscode.cpptools
      ms-dotnettools.csharp
      yoavbls.pretty-ts-errors
      yzhang.markdown-all-in-one
    ];
  };

  # Add config file for VS Code
  xdg.configFile."~/Development/Code/settings.json" = {
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
