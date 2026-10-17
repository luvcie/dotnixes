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
    # ../../modules/wezterm.nix
    # ../../modules/vscode.nix
    ../../modules/zed
    ../../modules/zsh.nix
    ../../modules/nixvim.nix
    ../../modules/sway.nix
    ../../modules/niri.nix
    ../../modules/niriconf.nix
    ../../modules/theme.nix
   # ../../modules/caelestia.nix
    ../../modules/retroism.nix
    ../../modules/wayvnc.nix
    ../../modules/emacs.nix
    ../../modules/helix.nix
    ../../modules/tts.nix
  ];

  programs.home-manager.enable = true;

  home.sessionVariables = {
    _JAVA_AWT_WM_NONREPARENTING = "1";
    # GTK_IM_MODULE/QT_IM_MODULE unset on purpose: wayland apps use the
    # native input method protocol, XMODIFIERS covers X11/XWayland
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
    GLFW_IM_MODULE = "ibus"; # Fcitx5 supports the ibus protocol for GLFW
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

      antigravity-cli
      easyocr
      python3Packages.rapidocr
      flyctl
      ollama
      dosbox-staging
      
      ffuf
      simplex-chat-desktop
      
      ###################
      # LOCAL & FLAKE   #
      ###################
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex
      # (callPackage ../../pkgs/claude-desktop.nix {})  # removed: no Claude subscription
      # TEMP 2026-10-14: llm-agents dsh-0.2.0-rc.2 npm-deps fails to fetch
      # @img/sharp-libvips-linuxmusl-arm64 from registry.npmjs.org
      # (HTTP/2 framing-layer stream error, retry fails identically).
      # Re-enable once registry recovers or llm-agents bumps past rc.2.
      # inputs.llm-agents.packages.${pkgs.system}.dsh
      # inputs.llm-agents.packages.${pkgs.system}.pi
      (callPackage ../../pkgs/endcord.nix {})
      inputs.claude-code.packages.${pkgs.system}.default
      inputs.starmie-cli.packages.${pkgs.system}.default
      inputs.lobster.packages."x86_64-linux".lobster
      inputs.glpaper-es3.packages.${pkgs.system}.default # ES3 fork, replaces stock glpaper; binary still `glpaper`
      (inputs.gitlogue.packages.${pkgs.system}.default.overrideAttrs (old: {
        cargoDeps = old.cargoDeps.overrideAttrs (oldc: {
          vendorStaging = oldc.vendorStaging.overrideAttrs (_: {
            outputHash = "sha256-upeILLWszjVa2HhMP05b5C1HrLE5EknV2OXXxizVz/c=";
          });
        });
      }))

      ###################
      # WEB BROWSERS    #
      ###################
      #librewolf
      chromium
      firefox
      brave
      # palemoon-bin removed upstream (relies on to-be-removed GTK2 for NPAPI)
      # palemoon-bin
      # Native Zen (replaces Flatpak app.zen_browser.zen once DnD is verified)
      inputs.zen-browser.packages.${pkgs.system}.default

      #######################
      # TERMINAL EMULATORS  #
      #######################
      #terminator
      #pterm
      #foot
      #xfce4-terminal
      #cool-retro-term
      ghostty

      ####################
      # DEVELOPMENT TOOLS #
      ####################
      # Version Control
      git
      git-credential-manager
      libsecret
      gh
      lazygit
      jujutsu
      lazyjj

      # IDEs & Editors
      helix
      micro
      cosmic-edit
      csview
      antigravity
      opencode

      # Programming Languages & Runtimes
      lua
      ocaml
      perl
      python314
      python313Packages.pip
      python313Packages.tkinter
      uv
      go
      rustup
      jdk17
      sbcl
      racket
      babashka
      clojure
      love
      guix
      powershell
      ruby
      nodejs_24
      bun
      pnpm
      lazynpm
      #deno
#     clang
      gcc
      readline

      # Build Tools & Compilers
      gnumake
      libtool # needed to compile emacs vterm module
      cmake
      pkgsCross.avr.buildPackages.gcc
      arduino-cli
      # Temporarily commenting out clang 12 as it has been removed
      # (pkgs.buildEnv {
      #   name = "clang-only";
      #   paths = [ llvmPackages_12.clang ];
      #   ignoreCollisions = true;
      # })

      # Language Servers & Linters
      nil # nix language server (emacs/zed lsp)
      glsl_analyzer # glsl LSP; completion/hover for bare .glsl (glslls needs a stage ext + assumes vulkan).
      clojure-lsp
      clj-kondo
      clang-tools
      alejandra
      norminette

      # Debugging & Profiling
      gdb
      valgrind
      scanmem

      # Development Utilities
      #kicad
      #fritzing
      #arduino-ide
      #probe-rs-tools
      #espup
      devenv
      hugo
      any-nix-shell
      omnix
      nix-prefetch-scripts
      nix-search-cli
      distrobox
      distroshelf
      bubblewrap
      fuse-overlayfs
      undollar
      file
      entr
      ceedling
      sqlite
      libGL
      libGLU
      # Godot's bundled dotnet sdk 8 can't compile C# 13, which upstream card
      # code needs now; combine a 9 sdk in for builds while keeping the 8
      # runtime so the net8.0 game still runs
      (godot-mono.overrideAttrs (_: {
        dotnet-sdk = pkgs.dotnetCorePackages.combinePackages [
          pkgs.dotnetCorePackages.sdk_9_0
          pkgs.dotnetCorePackages.sdk_8_0
        ];
      }))
      dotnet-sdk_9

      # Container & Kubernetes Tools
     #k9s
      kubectl
      lazydocker

      ###################
      # WAYLAND/SWAY UI #
      ###################
      noctalia-shell # quickshell desktop shell (bar/launcher/notifications/lockscreen)

      # Core Sway Components
      sov
      swayfx
      swaybg
      swaylock
      swayidle
      wofi
     # scenefx
      autotiling-rs

      # Wayland Utilities
      wl-clipboard
      slurp
      grim
      satty
      wev
      evtest
      wlrctl
      wlopm
      wl-color-picker
      rofi
      wmctrl
      ydotool
      xhost

      # Display & Colour
      sunsetr
      wlsunset
      wl-gammactl

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
      vesktop
      discordchatexporter-cli
      discordchatexporter-desktop
      signal-desktop
      telegram-desktop
      element-desktop
      slack
      stoat-desktop
      concord-tui
      irssi
      dino
      kaidan
      movim

      # Mail
      neomutt
      msmtp
      isync

      ######################
      # MULTIMEDIA & MEDIA #
      ######################
      # Video & Audio
      vlc
      # obs-studio
      waylyrics
      kooha
      qmmp
      sonixd
      spotube
      ffmpeg
      audacity

      # Audio Production & Music Creation
      alsa-utils
      easyeffects
      #hydrogen
      #carla
      #a2jmidid
      #yoshimi
      #zynaddsubfx
      #supercollider-with-plugins
      #fluidsynth
      #soundfont-fluid
      #pipewire.jack
      #qpwgraph

      # Music Trackers & Chiptune
      #schismtracker
      #goattracker-stereo
      #orca-c
      #sunvox
      #famistudio

      # Audio Utilities
      breakpad
      #helm
      # surge  # Temporarily disabled due to CMake build error

      # Image & Graphics
      gimp-with-plugins
      krita
      imv
      nomacs
      upscayl
      imagemagick
      #flameshot
      webcamoid
      kdePackages.kcolorchooser
      kdePackages.kquickimageedit
      bc

      # Media Download
      yt-dlp
      jackett
      qbittorrent
      nicotine-plus
      ani-cli
      mov-cli
      mktorrent

      ###################
      # FILE MANAGEMENT #
      ###################
      yazi
      p7zip
      zip
      qdirstat
      ncdu
      fh
      appimage-run
      hydrus
      handlr

      ####################
      # SYSTEM UTILITIES #
      ####################
      # System Monitoring
      btop
      macchina
      bunnyfetch
      onefetch
      mission-center
      usbtop
      usbview
      memtester
      batmon
      sutils

      # Hardware & System
      seahorse
      blueman
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
      poppler-utils
      calibre

      ###################
      # ANDROID & MOBILE #
      ###################
      scrcpy
      android-tools
      go-mtpfs # was jmtpfs (removed upstream, unmaintained); FUSE Android MTP mount
      qdl
      payload-dumper-go
      jadx
      # android-studio
      # android-studio-tools
      # edl  # broken in new nixpkgs

      ###############
      # CLI TOOLS   #
      ###############
      # Shells & Session Management
      nushell
      tmux
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
      xxd
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
      genact
      lavat
      terminaltexteffects
      tenki
      clock-rs
      tty-clock

      ################
      # NETWORK TOOLS #
      ################
      tailscale
      speedtest-go
      iperf
      mtr-gui
      openvpn
      proton-vpn-cli
      wireguard-tools
      tor
      cloudflared
      nmap
      drill
      autossh
      sshfs
      remmina

      ########################
      # SECURITY & PENTEST   #
      ########################
      gnupg

      # Network Security
      #wireshark
      #whatweb
      #nikto
      #iw
      #aircrack-ng
      #sslscan
      #mdk4
      #arp-scan
      #tcpdump
      #netdiscover
      #airgorah
      #wifite2
      #bettercap
      #airgeddon

      # Web Application Testing
      #sqlmap
      #commix
      #wpscan
      #caido

      # Reverse Engineering
      #ghidra
      #radare2
      #binwalk
      #exiftool

      # Cryptography & Hashing
      #hashcat
      #openssl

      # Steganography
      #steghide
      #stegseek
      #stegsolve
      #zsteg
      # outguess  # broken in new nixpkgs - jpeg library issues

      # Forensics
      #foremost
      #scalpel
      #fcrackzip
      #pdfminer
      #pdf-parser

      # OSINT
      #sn0int
      #sherlock
      #maigret

      # Penetration Testing Frameworks
      #villain
      #exploitdb
      #exegol
      #pentestgpt
      # dsniff  # broken in new nixpkgs - libnids build fails

      #############
      # GAMING    #
      #############
      # Game Launchers
      prismlauncher
      heroic
      pokemmo-installer
      #bottles

      # Games
      tetrio-desktop  # temporarily disabled - tetrio-plus is broken in new nixpkgs
      techmino
      vitetris
      #mgba
      space-cadet-pinball
      #vvvvvv
      abbaye-des-morts
      gnome-mahjongg
      kdePackages.kpat
      kdePackages.kshisen

      # Gaming Support
      wine
      winetricks
      mangohud
      mangojuice
      goverlay
      lsfg-vk
      lsfg-vk-ui # GTK editor for ~/.config/lsfg-vk/conf.toml (host app, not a layer)

      # Level Editing
      slade
      deutex

      ####################
      # PRODUCTIVITY     #
      ####################
      # Note Taking & Organization
      cherrytree
      newsboat
      anki
      obsidian

      # Finance & Time Management
      gnucash
      termdown
      blanket
      calcurse

      # Document Viewing & Editing
      #masterpdfeditor4

      # Password Management (desktop app dropped: bundled EOL electron;
      # using the browser extension instead)

      ##################
      # FILE TRANSFER  #
      ##################
      filezilla
      input-leap
      rsync
      weylus

      ###################
      # MISC UTILITIES  #
      ###################
      browsers
      mouseless
      # dwarfs  # dropped: not cached on 26.11, compiles ~1h from source
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
      # THEMES & FONTS    #
      #####################
      rose-pine-cursor
      cozette
      corefonts

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

      # Background opacity. dynamic_ + remote control let a keybind toggle it at
      # runtime (see keybindings). Default stays 0.985 (near-opaque).
      background_opacity = "0.985";
      dynamic_background_opacity = "yes";
      allow_remote_control = "yes";
    };

    keybindings = {
      "ctrl+shift+plus" = "change_font_size all +1.0";
      "ctrl+shift+minus" = "change_font_size all -1.0";
      # toggle transparent <-> opaque in place (default opaque). tune 0.4.
      # remote_control (not `kitten @`) is the keybind form; needs allow_remote_control.
      "ctrl+alt+o" = "remote_control set-background-opacity --toggle 0.4";
    };

    extraConfig = ''
      # Additional padding for height (vertical padding)
      window_padding_height 10
    '';
  };

  # endcord extension: inline images over the kitty graphics protocol. The
  # loader scans ~/.config/endcord/Extensions/<name>/<name>.py, matching the
  # directory name against the .py exactly.
  home.file.".config/endcord/Extensions/endcord-image-inline".source =
    pkgs.fetchFromGitHub {
      owner = "sparklost";
      repo = "endcord-image-inline";
      tag = "0.1.10";
      hash = "sha256-pmkXTut/UwMfdBWgpt43n5SjZIwpEwLGVt5mADGoijU=";
    };

  # persistent ssh tunnel for vnc, secrets in ~/.config/vnc-tunnel/env
  home.file.".config/vnc-tunnel/start.sh" = {
    executable = true;
    text = ''
      #!${pkgs.bash}/bin/bash
      source /home/lucie/.config/vnc-tunnel/env
      exec ${pkgs.autossh}/bin/autossh -M 0 -N \
        -o ServerAliveInterval=30 \
        -o ServerAliveCountMax=3 \
        -i /home/lucie/.ssh/id_ed25519_vnc \
        -L $LOCAL_PORT:localhost:$REMOTE_PORT \
        $VNC_USER@$VNC_HOST -p $SSH_PORT
    '';
  };

  # dsh wrapper (babashka): adds `dsh list` (lists $DSH_HOME/profiles),
  # delegates everything else to the real dsh from llm-agents.
  home.file.".local/bin/dsh" = {
    source = ../../bin/dsh.clj;
    executable = true;
  };

  systemd.user.services.vnc-tunnel = {
    Unit = {
      Description = "Persistent SSH tunnel for VNC";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };
    Service = {
      ExecStart = "/home/lucie/.config/vnc-tunnel/start.sh";
      Restart = "always";
      RestartSec = "5s";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
