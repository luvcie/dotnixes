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
    ./modules/zsh.nix
    ./modules/nixvim.nix
    ./modules/sway.nix
    ./modules/niri.nix
	./modules/niriconf.nix
    ./modules/theme.nix
	./modules/caelestia.nix
	./modules/retroism.nix
  ];

  programs.home-manager.enable = true;

  home.sessionVariables = lib.mkForce {
    # XDG_CURRENT_DESKTOP will be set by the compositor
    # XDG_SESSION_DESKTOP will be set by the compositor
    GDK_BACKEND = "wayland";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    SDL_VIDEODRIVER = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    CLUTTER_BACKEND = "wayland";
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

  ######################
  # PACKAGE MANAGEMENT #
  ######################

  home.packages = with pkgs; [
    ###################
    # WEB BROWSERS    #
    ###################
    firefox
    librewolf
    chromium
    google-chrome

    #######################
    # TERMINAL EMULATORS  #
    #######################
    terminator
    foot
    cool-retro-term
    ghostty

    ####################
    # DEVELOPMENT TOOLS #
    ####################
    # Version Control
    git
    git-credential-manager
    libsecret

    # IDEs & Editors
    vscode
	evil-helix
    micro
    cosmic-edit
    claude-code

    # Programming Languages & Runtimes
    jdk
    lua
    ocaml
    perl
    python313
    
    # Build Tools & Compilers
    gnumake
    (pkgs.buildEnv {
      name = "clang-only";
      paths = [ clang_12 ];
      ignoreCollisions = true;
    })

    # Development Utilities
    hugo
    alejandra
    any-nix-shell
    nix-prefetch-scripts
	nix-search-cli
    norminette
    distrobox
    bubblewrap
    fuse-overlayfs
    undollar
    gemini-cli
    file
    valgrind

    # Container & Kubernetes Tools
    k9s
    kubectl
    argocd
    lazydocker

    ###################
    # WAYLAND/SWAY UI #
    ###################
    # Core Sway Components
    sov
    swayfx
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
    vesktop
    signal-desktop
    telegram-desktop
    webcord-vencord
    element-desktop

    ######################
    # MULTIMEDIA & MEDIA #
    ######################
    # Video & Audio
    vlc
    obs-studio
    waylyrics
    wf-recorder
    gpu-screen-recorder-gtk
    gpu-screen-recorder
    kooha

    # Audio Production & Music Creation
    alsa-utils
    hydrogen
    carla
    a2jmidid
    yoshimi
    zynaddsubfx
    supercollider-with-plugins
    fluidsynth
    soundfont-fluid
    pipewire.jack
	qpwgraph

    # Music Trackers & Chiptune
    schismtracker
    goattracker-stereo
    orca-c
    sunvox
    famistudio

    # Audio Utilities
    breakpad
    helm
    surge

    # Image & Graphics
    gimp-with-plugins
    upscayl
    flameshot
    webcamoid

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

    # Documentation
    man-pages
    man-pages-posix
    zathura
	typora
	marktext
	zettlr

    ###############
    # CLI TOOLS   #
    ###############
    # Shells & Session Management
    nushell
    tmux
    zellij
    atuin
    screen
	claude-code
	gemini-cli

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
    jwhois

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
    caido

    # Reverse Engineering
    ghidra
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
    outguess

    # Forensics
    foremost
    scalpel
    fcrackzip
    pdfminer
    pdf-parser

    # OSINT
    sn0int
    sherlock
    maigret

    # Penetration Testing Frameworks
    villain
    exploitdb
    exegol
    pentestgpt

    #############
    # GAMING    #
    #############
    # Game Launchers
    prismlauncher
    bottles
    heroic
    goverlay

    # Games
    (tetrio-desktop.override { withTetrioPlus = true; })
    techmino
    vitetris
    mgba
    space-cadet-pinball

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
    masterpdfeditor4

    # Password Management
    bitwarden

    ##################
    # FILE TRANSFER  #
    ##################
    filezilla
    barrier

    ###################
    # MISC UTILITIES  #
    ###################
    browsers
    mouseless
    dwarfs
    cables
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

    ###################
    # CUSTOM PACKAGES #
    ###################
    inputs.lobster.packages."x86_64-linux".lobster

    ###################
    # DRIVER SUPPORT  #
    ###################
    chromedriver
  ]
    ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

  ######################
  # ADDITIONAL CONFIGS #
  ######################

  programs.git = {
    enable = true;
    userName = "luvcie";
    userEmail = "lucpardo@student.42.fr";

    extraConfig = {
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

  home.file."goinfre/.keep".text = "";

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "${config.home.homeDirectory}/Desktop";
      documents = "${config.home.homeDirectory}/Documents";
      download = "${config.home.homeDirectory}/Downloads";
      music = "${config.home.homeDirectory}/Music";
      pictures = "${config.home.homeDirectory}/Pictures";
      videos = "${config.home.homeDirectory}/Videos";
    };
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = ["chromium"];
        "x-scheme-handler/http" = ["chromium"];
        "x-scheme-handler/https" = ["chromium"];
        "application/pdf" = ["org.pwmt.zathura.desktop"];
        "image/*" = ["imv.desktop"];
        "video/*" = ["vlc.desktop"];
      };
    };
  };

  systemd.user.services.goinfre-cleanup = {
    Unit = {
      Description = "Clean goinfre directory on boot";
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'find ${config.home.homeDirectory}/goinfre -mindepth 1 -not -name .keep -delete 2>/dev/null || true'";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
