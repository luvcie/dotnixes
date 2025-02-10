{
  inputs,
  config,
  pkgs,
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
    ./modules/eww.nix
    inputs.nixvim.homeManagerModules.nixvim
  ];

  programs.home-manager.enable = true;

  home.sessionVariables = {
    XDG_CURRENT_DESKTOP = "sway";
    XDG_SESSION_DESKTOP = "sway";
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

  # Allow unfree packages
  nixpkgs.config.allowUnfreePredicate = _: true;

  ######################
  # PACKAGE MANAGEMENT #
  ######################

  home.packages = with pkgs; [
    # Sway packages
    swayfx
    swaylock
    swayidle
    wofi
    scenefx
    eww
    jq
    wireplumber
    slurp
    grim
    satty
    wl-clipboard
    brightnessctl
    pamixer
    gawk
    sov
    #otherstuff
    wev
    evtest
    foot
    xclip
    # Development Tools
    k9s
    kubectl
    argocd
    git
    hugo
    micro
    vscode
    alejandra
    any-nix-shell
    nix-prefetch-scripts
    google-chrome
    chromedriver
    stack
    haskellPackages.hakyll
    perl
    distrobox
    barrier
    lazydocker
    helix
    distcc

    # Internet & Communication
    firefox
    librewolf
    chromium
    vesktop
    signal-desktop
    telegram-desktop
    webcord-vencord
    bitwarden
    filezilla
    zapzap
    element-desktop
    jwhois

    # Media & Entertainment
    vlc
    obs-studio
    kooha
    gimp-with-plugins
    waylyrics
    textsnatcher

    # Entertainment
    prismlauncher
    vitetris
    ani-cli
    mov-cli
    fortune

    # File Management & Utilities
    p7zip
    yazi
    zathura
    qdirstat
    ncdu
    bat
    wl-clipboard
    appimage-run
    kate

    # System Monitoring & Management
    btop
    macchina
    bunnyfetch
    usbtop
    usbview

    # Network Tools
    tailscale
    wireshark
    speedtest-go
    iperf
    mtr-gui

    # Media Download & Management
    jackett
    qbittorrent
    nicotine-plus

    # CLI
    atuin
    cool-retro-term
    asciiquarium-transparent
    pokemonsay
    figlet
    cowsay
    cmatrix
    cbonsai
    sl
    lolcat
    hollywood
    cli-visualizer
    tmux
    element

    # Productivity & Finance
    gnucash
    termdown
    blanket
    calcurse

    # KDE Connect Integration
    kdePackages.kdeconnect-kde

    # Hardware Support
    ledger-live-desktop

    # Games
    bottles
    heroic
    mangohud
    goverlay

    # Camera & Video
    webcamoid
    flameshot

    # System Cleaning
    bleachbit

    # Custom Packages
    inputs.lobster.packages."x86_64-linux".lobster
    rose-pine-cursor
    rose-pine-gtk-theme
    bibata-cursors
  ];

  ########################
  #  SWAY CONFIGURATION   #
  ########################

home.pointerCursor = {
  package = pkgs.bibata-cursors;
  name = "Bibata-Modern-Classic";
  size = 24;
  gtk.enable = true;
  x11.enable = false;
};


  ########################
  #  THEME CONFIGURATION #
  ########################

  gtk = {
    enable = true;
    font = {
      name = "Sans";
      size = 11;
    };
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };



  ######################
  # ADDITIONAL CONFIGS #
  ######################

  programs.git = {
    enable = true;
    userName = "lucie";
    userEmail = "your.email@example.com";

    extraConfig = {
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

  programs.mangohud = {
    enable = true;
    settings = {
      fps_limit = 144;
      cpu_stats = true;
      cpu_temp = true;
      cpu_power = true;
      gpu_stats = true;
      gpu_temp = true;
      gpu_power = true;
      ram = true;
      fps = true;
      frametime = true;
      battery = true;
      horizontal = true;
      background_alpha = "0.5";
      font_size = 24;
    };
  };

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
        "text/html" = ["librewolf.desktop"];
        "x-scheme-handler/http" = ["librewolf.desktop"];
        "x-scheme-handler/https" = ["librewolf.desktop"];
        "application/pdf" = ["org.pwmt.zathura.desktop"];
        "image/*" = ["imv.desktop"];
        "video/*" = ["vlc.desktop"];
      };
    };
  };

}
