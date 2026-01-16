{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: {
  ######################
  # CORE CONFIGURATION #
  ######################

  imports = [
    ./modules/wezterm.nix
    ./modules/vscode.nix
    ./modules/zed
    ./modules/zsh.nix
    ./modules/nixvim.nix
    ./modules/sway.nix
    ./modules/niri.nix
    ./modules/niriconf.nix
    ./modules/theme.nix
   # ./modules/caelestia.nix
    ./modules/retroism.nix
  ];

  programs.home-manager.enable = true;

  home.sessionVariables = {
    _JAVA_AWT_WM_NONREPARENTING = "1";
  };

  home = {
    username = "lucie";
    homeDirectory = "/home/lucie";
    stateVersion = "23.11";

    sessionPath = [
      "$HOME/.local/bin"
    ];
  };

  nixpkgs.config.allowUnfreePredicate = _: true;

  # Enable retroism theme
  programs.retroism.enable = true;

  # Let Home Manager install and manage fonts.
  fonts.fontconfig.enable = true;

  # Enable caelestia (disable one or the other to switch)
  # programs.caelestia.enable = false;

  ######################
  # PACKAGE MANAGEMENT #
  ######################

  home.packages = with pkgs;
    [
	  # latest additions
	  mangohud
	  mangojuice
	  wlrctl
	  hydrus
	  python314
	  python313Packages.pip
	  rofi
	  wmctrl
	  ydotool
	  gdb
	  libGL
	  libGLU
	  android-studio
	  scanmem
	  android-studio-tools
	  scrcpy
	  xorg.xhost
	  jmtpfs
	  jdk17
	  python313Packages.tkinter
	  corefonts
	  poppler-utils
	  xxd
	  mktorrent
	  audacity
	  qdl
	  android-tools
	  # edl  # broken in new nixpkgs
	  payload-dumper-go
	  gnome-mahjongg
	  spotube
	  nomacs
	  cozette
	  handlr
	  # dsniff  # broken in new nixpkgs - libnids build fails
	  zip
	  jujutsu
	  lazyjj
	  nodejs_24
	  pnpm
#	  deno
	  lazynpm
	  iw
	  aircrack-ng
	  sslscan
	  mdk4
	  arp-scan
	  tcpdump
	  netdiscover
#	  airgorah
#	  wifite2
	  bettercap
#	  airgeddon
	  pipx
      ###################
      # WEB BROWSERS    #
      ###################
      librewolf
      chromium
	  firefox

      #######################
      # TERMINAL EMULATORS  #
      #######################
      terminator
  	  pterm
      foot
	  xfce4-terminal
      cool-retro-term
      ghostty

      ####################
      # DEVELOPMENT TOOLS #
      ####################
      # Version Control
      git
      git-credential-manager
      libsecret
	    gh

      # IDEs & Editors
      vscode
      evil-helix
      micro
      cosmic-edit
	    csview

      # Programming Languages & Runtimes
      lua
      ocaml
      perl
      python314
#     clang
	  gcc
	  readline
      # Build Tools & Compilers
      gnumake
      # Temporarily commenting out clang 12 as it has been removed
      # (pkgs.buildEnv {
      #   name = "clang-only";
      #   paths = [ llvmPackages_12.clang ];
      #   ignoreCollisions = true;
      # })

      # Development Utilities
	  #kicad
	  #fritzing
	  #arduino-ide
	  #probe-rs-tools
	  #espup
	  pkgsCross.avr.buildPackages.gcc
	  arduino-cli
	  cmake
      hugo
      alejandra
      any-nix-shell
	  omnix
      nix-prefetch-scripts
      nix-search-cli
      norminette
      distrobox
	  distroshelf
      bubblewrap
      fuse-overlayfs
      undollar
      file
      valgrind
	  ceedling
	  ruby

      # Container & Kubernetes Tools
     #k9s
      kubectl
      argocd
      lazydocker

      ###################
      # WAYLAND/SWAY UI #
      ###################
      # Core Sway Components
      sov
      swayfx
      swaybg
      swaylock
      swayidle
      wofi
      scenefx
      autotiling-rs

      # Wayland Utilities
      wl-clipboard
      slurp
      grim
      satty
      wev
      evtest

      # System Control
      brightnessctl
      pamixer
      wireplumber

      # NWG Suite
      nwg-bar
      nwg-menu
      nwg-look
      nwg-dock
      nwg-panel
      nwg-hello
      nwg-drawer
      nwg-wrapper
      nwg-clipman
      nwg-displays
      nwg-launchers
      cliphist

      ########################
      # COMMUNICATION & CHAT #
      ########################
      (discord.override {
        withOpenASAR = true;
        withVencord = true;
      })
      signal-desktop
      telegram-desktop
      element-desktop

      ######################
      # MULTIMEDIA & MEDIA #
      ######################
      # Video & Audio
      vlc
      # obs-studio
      waylyrics
      kooha
	  qmmp

      # Audio Production & Music Creation
      alsa-utils
      hydrogen
      carla
      a2jmidid
      yoshimi
      zynaddsubfx
      supercollider-with-plugins
      #fluidsynth
      #soundfont-fluid
      pipewire.jack
      qpwgraph
	  easyeffects

      # Music Trackers & Chiptune
      schismtracker
      goattracker-stereo
      orca-c
      sunvox
      famistudio

      # Audio Utilities
      breakpad
      helm
      # surge  # Temporarily disabled due to CMake build error

      # Image & Graphics
      gimp-with-plugins
	  imv
      upscayl
      #flameshot
      webcamoid
	  kdePackages.kcolorchooser
	  kdePackages.kquickimageedit

      # Media Download
      yt-dlp
      jackett
      qbittorrent
      nicotine-plus
      ani-cli
      mov-cli

      ###################
      # FILE MANAGEMENT #
      ###################
      yazi
      p7zip
      qdirstat
      ncdu
      fh
      appimage-run

      ####################
      # SYSTEM UTILITIES #
      ####################
      # System Monitoring
      btop
      macchina
      bunnyfetch
	  onefetch
      usbtop
      usbview
      memtester
      batmon
      sutils

      # Hardware & System
      seahorse
      blueberry
      pinentry-gnome3
      bleachbit
      ledger-live-desktop
      nvme-cli
      stress-ng
      smartmontools
      rasdaemon

      # Documents
      man-pages
      man-pages-posix
      zathura
      typora
      marktext

      ###############
      # CLI TOOLS   #
      ###############
      # Shells & Session Management
      nushell
      #tmux
      zellij
      atuin
      screen
	  #wrangler

      # Terminal Communication
      picocom
      minicom

      # Terminal Utilities
      jq
      gawk
      bat
      clipboard-jh
      xclip
      textsnatcher
	    lsd
	    powertop

      # Fun CLI Tools
      asciiquarium-transparent
      pokemonsay
      figlet
      cowsay
      cmatrix
      cbonsai
      pipes-rs
      sl
      lolcat
      hollywood
      fortune
      astroterm
      zalgo

      ################
      # NETWORK TOOLS #
      ################
      tailscale
      speedtest-go
      iperf
      mtr-gui
      openvpn
      drill

      ########################
      # SECURITY & PENTEST   #
      ########################
      # Network Security
      wireshark
      whatweb
      nikto
      nmap

      # Web Application Testing
      sqlmap
      commix
      wpscan
      #caido

      # Reverse Engineering
      #ghidra
      radare2
      binwalk
      exiftool

      # Cryptography & Hashing
      hashcat
      gnupg
      openssl

      # Steganography
      steghide
      stegseek
      stegsolve
      zsteg
      # outguess  # broken in new nixpkgs - jpeg library issues

      # Forensics
      foremost
      scalpel
      fcrackzip
      #pdfminer
      #pdf-parser

      # OSINT
      sn0int
      sherlock
      #maigret

      # Penetration Testing Frameworks
      villain
      exploitdb
      #exegol
      #pentestgpt

      #############
      # GAMING    #
      #############
      # Game Launchers
      #prismlauncher
      bottles
      #heroic
      goverlay

      # Games
      # tetrio-desktop  # temporarily disabled - tetrio-plus is broken in new nixpkgs
      techmino
      vitetris
      mgba
      space-cadet-pinball
      vvvvvv
      abbaye-des-morts
	  kdePackages.kpat
	  kdePackages.kshisen

      # Gaming Support
      wine
      winetricks

      ####################
      # PRODUCTIVITY     #
      ####################
      # Note Taking & Organization
      cherrytree
      newsboat
      anki
      #obsidian

      # Finance & Time Management
      gnucash
      termdown
      blanket
      calcurse

      # Document Viewing & Editing
      #masterpdfeditor4

      # Password Management
      bitwarden-desktop

      ##################
      # FILE TRANSFER  #
      ##################
      filezilla
      input-leap

      ###################
      # MISC UTILITIES  #
      ###################
      browsers
      mouseless
      dwarfs
      eaglemode
      libcaca
      hdf5
      h5utils
      asciinema
      wayfarer
      tgpt
      element
      artem

      #####################
      # THEMES & CURSORS  #
      #####################
      rose-pine-cursor
      cozette

      ###################
      # CUSTOM PACKAGES #
      ###################
      inputs.lobster.packages."x86_64-linux".lobster

      ###################
      # DRIVER SUPPORT  #
      ###################
      chromedriver
    ];
#    ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

  ######################
  # ADDITIONAL CONFIGS #
  ######################

  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "luvcie";
        email = "lucpardo@student.42.fr";
      };

      credential.helper = "${pkgs.git-credential-manager}/bin/git-credential-manager";
      credential.credentialStore = "secretservice";

      init.defaultBranch = "main";
      pull.rebase = true;
      core.editor = "nvim";

      diff = {
        colorMoved = "default";
        algorithm = "histogram";
      };

      alias = {
        st = "status -sb";
        co = "checkout";
        br = "branch";
        ci = "commit";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
        visual = "!gitk";
      };
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    stdlib = ''
      layout_python() {
        local python=''${1:-python3}
        unset PYTHONHOME
        export VIRTUAL_ENV=.venv
        if [[ ! -d $VIRTUAL_ENV ]]; then
          $python -m venv $VIRTUAL_ENV
        fi
        export PYTHONPATH=$VIRTUAL_ENV
        PATH_add "$VIRTUAL_ENV/bin"
      }
    '';
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "TwoDark";
      style = "numbers,changes,header";
      pager = "less -FR";
    };
  };

  programs.htop = {
    enable = true;
    settings = {
      highlight_base_name = 1;
      show_program_path = 0;
      tree_view = 1;
      color_scheme = 6;
      cpu_count_from_one = 0;
    };
  };

  programs.swaylock = {
    enable = true;
    settings = {
      image = "/home/lucie/dotnixes/assets/wallpapers/lockscreen/peak_into_the_system.png";
      scaling = "fill";
      font-size = 24;
      indicator-idle-visible = false;
      indicator-radius = 100;
      indicator-thickness = 7;
      line-color = "000000";
      inside-color = "00000088";
      ring-color = "ffffff";
      separator-color = "00000000";
      text-color = "ffffff";
      key-hl-color = "88c0d0";
      bs-hl-color = "bf616a";
      inside-clear-color = "81a1c1";
      inside-ver-color = "5e81ac";
      inside-wrong-color = "bf616a";
      ring-clear-color = "88c0d0";
      ring-ver-color = "5e81ac";
      ring-wrong-color = "bf616a";
      show-failed-attempts = true;
    };
  };

  # Configure kitty terminal
  programs.kitty = {
    enable = true;

    font = {
      name = "FiraCode Nerd Font";
      size = 11;
    };

    # themeFile = "Belafonte_Day";

    settings = {
      # Use GTK theme
      linux_display_server = "wayland";
      wayland_titlebar_color = "system";

      # Shell integration
      shell_integration = "no-cursor";

      # Cursor
      cursor_shape = "block";

      # Padding
      window_padding_width = 7;

      # Scrollback
      scrollback_lines = 3000;

      # Background opacity
      background_opacity = "0.985";

      # Custom color scheme - Indigo Twilight
      cursor = "#3e7c99";
      selection_background = "#7e8bad";
      selection_foreground = "#d0def9";
      background = "#bac4e6";
      foreground = "#1a2135";

      # Color palette (ANSI colors) 
      color0 = "#1a2135";  # Black (normal) - dark navy
      color8 = "#4a5670";  # Black (bright) - medium navy-grey
      color1 = "#d65d5d";  # Red (normal) - muted earthy red
      color9 = "#e83939";  # Red (bright) - vibrant red
      color2 = "#5a9f7f";  # Green (normal) - sage green
      color10 = "#7dc9a0"; # Green (bright) - mint green
      color3 = "#d4a574";  # Yellow (normal) - warm amber
      color11 = "#f5c98a"; # Yellow (bright) - light gold
      color4 = "#3e7c99";  # Blue (normal) - deep teal blue
      color12 = "#6b9fd9"; # Blue (bright) - bright azure
      color5 = "#9d7fc9";  # Magenta (normal) - muted purple
      color13 = "#c19ee0"; # Magenta (bright) - light lavender
      color6 = "#5aa5a5";  # Cyan (normal) - deep teal
      color14 = "#7dcfd9"; # Cyan (bright) - bright aqua
      color7 = "#d0def9";  # White (normal) - soft blue-tinted white
      color15 = "#e8ecf8"; # White (bright) - almost pure white
    };

    keybindings = {
      "ctrl+shift+plus" = "change_font_size all +1.0";
      "ctrl+shift+minus" = "change_font_size all -1.0";
    };

    extraConfig = ''
      # Additional padding for height (vertical padding)
      window_padding_height 10
    '';
  };

  # Run flatpak update after every home-manager rebuild
  home.activation.flatpakUpdate = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if command -v flatpak &> /dev/null; then
      echo "Running flatpak update..."
      ${pkgs.flatpak}/bin/flatpak update -y || true
    fi
  '';
}
