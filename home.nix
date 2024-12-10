{
  inputs,
  config,
  pkgs,
  ...
}: {
  ######################
  # CORE CONFIGURATION #
  ######################

  programs.home-manager.enable = true;
  neovim.enable = true;

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
    sway
    swaylock  # Screen locker
    swayidle  # Idle management daemon
    wofi      # Application launcher

    # Tools for wm
    wireplumber
    slurp
    grim
    wl-clipboard

    # Development Tools
    k9s
    kubectl
    argocd
    git
    hugo
    micro
    vscode
    alejandra  # Nix formatter
    any-nix-shell
    nix-prefetch-scripts

    # Internet & Communication
    firefox
    librewolf
    chromium
    vesktop  # Enhanced Discord client
    signal-desktop
    telegram-desktop
    webcord-vencord
    bitwarden

    # Media & Entertainment
    vlc
    obs-studio
    kooha  # Screen recorder
    gimp-with-plugins

    # Entertainment
    prismlauncher  # Minecraft launcher
    vitetris
    ani-cli
    mov-cli

    # File Management & Utilities
    p7zip
    yazi  # Terminal file manager
    zathura  # PDF viewer
    qdirstat  # Disk usage analyzer
    ncdu
    bat  # Better cat
    wl-clipboard
    appimage-run

    # System Monitoring & Management
    btop
    macchina  # System information
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

    # Terminal Enhancements
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

    # Productivity & Finance
    gnucash
    termdown
    blanket  # Background sounds
    waylyrics

    # KDE Connect Integration
    kdePackages.kdeconnect-kde

    # Hardware Support
    ledger-live-desktop
    xboxdrv

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
  ];
  #######################
  # SHELL CONFIGURATION #
  #######################

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
      # Additional useful aliases
      ls = "ls --color=auto";
      ll = "ls -la";
      update = "sudo nixos-rebuild switch --flake .";
      clean = "sudo nix-collect-garbage -d";  # Clean old generations
      # Git shortcuts
      gs = "git status";
      gp = "git push";
      ga = "git add";
      gc = "git commit";
      # Directory navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      # System
      sysinfo = "macchina";  # Show system info
      temp = "sensors";  # Show temperatures
    };

    # ZSH Plugins
    plugins = [
      # Vi mode
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
      # Nix shell support
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
      # Additional useful plugins
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
      # Better history
      HISTSIZE=10000
      SAVEHIST=10000
      setopt SHARE_HISTORY
      setopt HIST_IGNORE_DUPS

      # Directory stack
      setopt AUTO_PUSHD
      setopt PUSHD_IGNORE_DUPS
      setopt PUSHD_SILENT

      # Better completion
      setopt COMPLETE_ALIASES

      # Load direnv
      eval "$(direnv hook zsh)"

      # Initialize starship prompt
      eval "$(starship init zsh)"
    '';
  };

  #####################
  # TERMINAL EMULATOR #
  #####################

  programs.kitty = {
    enable = true;
    font = {
      name = "FiraCode Nerd Font";
      size = 12;
    };

    # Additional settings
    settings = {
      # Performance
      sync_to_monitor = true;
      repaint_delay = 10;
      input_delay = 3;

      # Appearance
      background_opacity = "0.95";
      window_padding_width = 4;

      # Cursor
      cursor_shape = "beam";
      cursor_blink_interval = 0.5;

      # Bell
      enable_audio_bell = false;
      visual_bell_duration = "0.1";

      # Shell integration
      shell_integration = "enabled";

      # Scrollback
      scrollback_lines = 10000;

      # URLs
      url_style = "curly";
    };

    # Key mappings
    keybindings = {
      "ctrl+shift+c" = "copy_to_clipboard";
      "ctrl+shift+v" = "paste_from_clipboard";
      "ctrl+shift+t" = "new_tab";
      "ctrl+shift+q" = "close_tab";
    };
  };
  #####################
  # DEVELOPMENT TOOLS #
  #####################

  programs.vscode = {
    enable = true;

    # Extensions
    extensions = with pkgs.vscode-extensions; [
      # Development
      ms-vsliveshare.vsliveshare
      vscodevim.vim
      xaver.clang-format
      continue.continue
      eg2.vscode-npm-script

      # Languages
      bbenoist.nix
      haskell.haskell
      ms-vscode.cpptools
      ms-dotnettools.csharp
      yoavbls.pretty-ts-errors
      yzhang.markdown-all-in-one

      # Utilities
      shardulm94.trailing-spaces
      tomoki1207.pdf

      # Additional useful extensions
      eamodio.gitlens  # Git integration
      usernamehw.errorlens  # Better error display
      streetsidesoftware.code-spell-checker  # Spell checking
      esbenp.prettier-vscode  # Code formatting
    ];

    # User settings
    userSettings = {
      "editor.fontFamily" = "'FiraCode Nerd Font', monospace";
      "editor.fontLigatures" = true;
      "editor.tabSize" = 2;
      "editor.wordWrap" = "wordWrapColumn";
      "editor.bracketPairColorization.enabled" = true;
      "editor.guides.bracketPairs" = "active";
      "editor.minimap.enabled" = false;
      "editor.renderWhitespace" = "boundary";

      # Git settings
      "git.confirmSync" = false;
      "git.autofetch" = true;

      # Window settings
      "window.menuBarVisibility" = "toggle";
      "window.zoomLevel" = 1;
      "workbench.startupEditor" = "none";

      # File settings
      "explorer.confirmDelete" = false;
      "files.trimTrailingWhitespace" = true;
      "files.insertFinalNewline" = true;

      # Terminal settings
      "terminal.integrated.fontFamily" = "'FiraCode Nerd Font'";
      "terminal.integrated.defaultProfile.linux" = "zsh";

      # Language specific settings
      "[nix]" = {
        "editor.tabSize" = 2;
        "editor.formatOnSave" = true;
      };
      "[markdown]" = {
        "editor.wordWrap" = "on";
        "editor.quickSuggestions" = {
          "comments" = "on";
          "strings" = "on";
          "other" = "on";
        };
      };
    };
  };

  ########################
  #  SWAY CONFIGURATION   #
  ########################

  wayland.windowManager.sway = {
    enable = true;
    config = rec {
      modifier = "Mod4";
      terminal = "kitty";

      # Startup applications
      startup = [
        { command = "swaymsg 'workspace 1'"; }
        { command = "nm-applet --indicator"; }
      ];

      # Window rules
      window.commands = [
        {
          criteria = { app_id = "firefox"; };
          command = "move container to workspace 2";
        }
        {
          criteria = { app_id = "discord"; };
          command = "move container to workspace 3";
        }
      ];

      # Key bindings
      keybindings = {
        "${modifier}+Return" = "exec ${terminal}";
        "${modifier}+q" = "kill";
        "${modifier}+d" = "exec wofi --show drun";
        "${modifier}+Shift+c" = "reload";
        "${modifier}+Shift+e" = "exit";
        "${modifier}+Shift+Control+e" = "exec wlogout"; # Logging out menu

        # Screenshots with clipboard
        "Print" = "exec grim -g \"$(slurp)\" - | wl-copy"; # Area screenshot to clipboard
        "${modifier}+Print" = "exec grim - | wl-copy"; # Full screenshot to clipboard
        "${modifier}+Shift+Print" = "exec grim -g \"$(slurp)\" ~/Pictures/$(date +'%Y-%m-%d-%H%M%S_grim.png') - | wl-copy";
        # Area screenshot saved and copied

        # Media controls
        "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
        "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
        "XF86AudioPlay" = "exec playerctl play-pause";
        "XF86AudioNext" = "exec playerctl next";
        "XF86AudioPrev" = "exec playerctl previous";

        # Workspace switching
        "${modifier}+1" = "workspace number 1";
        "${modifier}+2" = "workspace number 2";
        "${modifier}+3" = "workspace number 3";
        "${modifier}+4" = "workspace number 4";
        "${modifier}+5" = "workspace number 5";
        "${modifier}+6" = "workspace number 6";
        "${modifier}+7" = "workspace number 7";
        "${modifier}+8" = "workspace number 8";
        "${modifier}+9" = "workspace number 9";
        "${modifier}+0" = "workspace number 10";

        # Moving windows to workspaces
        "${modifier}+Shift+1" = "move container to workspace number 1";
        "${modifier}+Shift+2" = "move container to workspace number 2";
        "${modifier}+Shift+3" = "move container to workspace number 3";
        "${modifier}+Shift+4" = "move container to workspace number 4";
        "${modifier}+Shift+5" = "move container to workspace number 5";
        "${modifier}+Shift+6" = "move container to workspace number 6";
        "${modifier}+Shift+7" = "move container to workspace number 7";
        "${modifier}+Shift+8" = "move container to workspace number 8";
        "${modifier}+Shift+9" = "move container to workspace number 9";
        "${modifier}+Shift+0" = "move container to workspace number 10";

        # Virtual desktop navigation
        "${modifier}+Control+Left" = "workspace prev";
        "${modifier}+Control+Right" = "workspace next";

        # Resizing windows
        "${modifier}+r" = "mode resize";

        # Splitting windows
        "${modifier}+b" = "splith";
        "${modifier}+v" = "splitv";

        # Fullscreen
        "${modifier}+f" = "fullscreen toggle";

        # Floating windows
        "${modifier}+Shift+space" = "floating toggle";

        # Focusing windows
        "${modifier}+Left" = "focus left";
        "${modifier}+Down" = "focus down";
        "${modifier}+Up" = "focus up";
        "${modifier}+Right" = "focus right";

        # Moving windows
        "${modifier}+Shift+Left" = "move left";
        "${modifier}+Shift+Down" = "move down";
        "${modifier}+Shift+Up" = "move up";
        "${modifier}+Shift+Right" = "move right";
      };

      # Input configuration
      input = {
        "type:touchpad" = {
          tap = "enabled";
          natural_scroll = "disabled";
          middle_emulation = "enabled";
          pointer_accel = "0.8";
        };
        "type:keyboard" = {
          xkb_layout = "us";
          repeat_delay = "300";
          repeat_rate = "50";
        };
      };

      # Resize mode
      modes = {
        resize = {
          "Left" = "resize shrink width 10 px";
          "Down" = "resize grow height 10 px";
          "Up" = "resize shrink height 10 px";
          "Right" = "resize grow width 10 px";
          "Return" = "mode default";
          "Escape" = "mode default";
        };
      };

    bars = [{
      position = "top";
      statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-default.toml";
      fonts = {
        names = [ "FiraCode Nerd Font" ];
        size = 10.0;
      };
      colors = {
        statusline = "#ffffff";
        background = "#323232";
        inactiveWorkspace = {
          background = "#323232";
          border = "#323232";
          text = "#5c5c5c";
        };
      };
     }];
    };
  };

# Theme configuration
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

# Bar
  programs.i3status-rust = {
  enable = true;
  bars = {
    default = {
      blocks = [
        {
          block = "net";
          format = " $icon {$signal_strength $frequency|Wired} via $device ";
        }
        {
          block = "sound";
          format = " $icon {$volume|muted} ";
        }
        {
          block = "battery";
          format = " $icon $percentage {$time |}";
        }
        {
          block = "time";
          format = " $timestamp.datetime(f:'%a %d/%m %R') ";
          interval = 60;
        }
      ];
      theme = "gruvbox-dark";
      icons = "awesome6";
    };
  };
};


  ######################
  # ADDITIONAL CONFIGS #
  ######################

  # Git configuration
  programs.git = {
    enable = true;
    userName = "lucie";
    userEmail = "your.email@example.com";

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      core.editor = "nvim";

      # Better diffs
      diff = {
        colorMoved = "default";
        algorithm = "histogram";
      };

      # Useful aliases
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

  # Direnv configuration
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    stdlib = ''
      # Layout for Python
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

  # Better CLI tools configuration
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

  # Mango
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

  # XDG configuration
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

  # Cursor theme
  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    x11 = {
      enable = true;
      defaultCursor = "left_ptr";
    };
  };
}
