{
  inputs,
  config,
  pkgs,
  ...
}: let
  wallpaper = ./assets/wallpapers/wallpaper.png;
in {
  ######################
  # CORE CONFIGURATION #
  ######################

  imports = [
    ./modules/wezterm.nix
    ./modules/vscode.nix
    ./modules/zsh.nix
    ./modules/nixvim.nix
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
  ];

  ########################
  #  SWAY CONFIGURATION   #
  ########################

  wayland.windowManager.sway = {
    enable = true;
    package = pkgs.swayfx;
    systemd.enable = true;
    wrapperFeatures.gtk = true;

    extraConfigEarly = ''
      exec "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway"
    '';

    checkConfig = false;

    extraConfig = ''
      corner_radius 6
      shadows enable
      blur enable
      titlebar_separator disable
      font pango:monospace 10
      gaps outer 0
      gaps inner 6
      titlebar_border_thickness 0
      set $border_width 1
      default_border normal $border_width
      default_floating_border normal $border_width
      title_align center
      client.focused          #000000 #000000    #FFFFFF  #000000    #000000
      client.focused_inactive #000000 #000000    #FFFFFF  #000000    #000000
      client.unfocused        #000000 #000000    #FFFFFF  #000000    #000000
      client.urgent           #000000 #000000    #FFFFFF  #000000    #000000
      client.placeholder      #000000 #000000    #FFFFFF  #000000    #000000
      client.background       #000000
    '';


  extraSessionCommands = ''
    export SWAYSOCK=/run/user/$UID/sway-ipc.$UID.$(pgrep -x sway).sock
    export XCURSOR_THEME=rose-pine-cursor
    export XCURSOR_SIZE=24
  '';

    config = rec {
      modifier = "Mod4";
      terminal = "wezterm";
      menu = "${pkgs.wofi}/bin/wofi --show drun";
      output = {
        "*" = {
          bg = "${wallpaper} fill";
        };
      };

      gaps = {
        inner = 3;
        outer = 3;
      };

      window = {
        border = 3;
        commands = [
          {
            criteria = { app_id = "chromium"; };
            command = "move container to workspace 2";
          }
          {
            criteria = { app_id = "vesktop"; };
            command = "move container to workspace 3";
          }
        ];
      };

      startup = [
        { command = "swaymsg 'workspace 1'"; }
        { command = "nm-applet --indicator"; }
        { command = "~/.config/eww/start-bar.sh"; }
      ];

      keybindings = {
        "${modifier}+Up" = "focus up";
        "${modifier}+Down" = "focus down";
        "${modifier}+Left" = "focus left";
        "${modifier}+Right" = "focus right";

        "${modifier}+Shift+Up" = "move up";
        "${modifier}+Shift+Down" = "move down";
        "${modifier}+Shift+Left" = "move left";
        "${modifier}+Shift+Right" = "move right";

        "${modifier}+Shift+bracketright" = "move workspace to output right";
        "${modifier}+Shift+bracketleft" = "move workspace to output left";
        "${modifier}+period" = "focus output right";
        "${modifier}+comma" = "focus output left";

        "--no-repeat ${modifier}+1" = "workspace number 1; exec \"echo 1 > /tmp/sov\"";
        "--no-repeat ${modifier}+2" = "workspace number 2; exec \"echo 1 > /tmp/sov\"";
        "--no-repeat ${modifier}+3" = "workspace number 3; exec \"echo 1 > /tmp/sov\"";
        "--no-repeat ${modifier}+4" = "workspace number 4; exec \"echo 1 > /tmp/sov\"";
        "--no-repeat ${modifier}+5" = "workspace number 5; exec \"echo 1 > /tmp/sov\"";
        "--no-repeat ${modifier}+6" = "workspace number 6; exec \"echo 1 > /tmp/sov\"";
        "--no-repeat ${modifier}+7" = "workspace number 7; exec \"echo 1 > /tmp/sov\"";
        "--no-repeat ${modifier}+8" = "workspace number 8; exec \"echo 1 > /tmp/sov\"";
        "--no-repeat ${modifier}+9" = "workspace number 9; exec \"echo 1 > /tmp/sov\"";
        "--no-repeat ${modifier}+0" = "workspace number 10; exec \"echo 1 > /tmp/sov\"";

        "--release ${modifier}+1" = "exec \"echo 0 > /tmp/sov\"";
        "--release ${modifier}+2" = "exec \"echo 0 > /tmp/sov\"";
        "--release ${modifier}+3" = "exec \"echo 0 > /tmp/sov\"";
        "--release ${modifier}+4" = "exec \"echo 0 > /tmp/sov\"";
        "--release ${modifier}+5" = "exec \"echo 0 > /tmp/sov\"";
        "--release ${modifier}+6" = "exec \"echo 0 > /tmp/sov\"";
        "--release ${modifier}+7" = "exec \"echo 0 > /tmp/sov\"";
        "--release ${modifier}+8" = "exec \"echo 0 > /tmp/sov\"";
        "--release ${modifier}+9" = "exec \"echo 0 > /tmp/sov\"";
        "--release ${modifier}+0" = "exec \"echo 0 > /tmp/sov\"";

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

        "${modifier}+b" = "splith";
        "${modifier}+v" = "splitv";
        "${modifier}+f" = "fullscreen";
        "${modifier}+Shift+space" = "floating toggle";
        "${modifier}+a" = "focus parent";
        "${modifier}+r" = "mode resize";

        "${modifier}+Shift+c" = "reload";
        "${modifier}+Shift+q" = "kill";
        "${modifier}+d" = "exec ${menu}";
        "${modifier}+l" = "exec ~/.config/sway/lock.sh";
        "${modifier}+Return" = "exec ${terminal}";
        "${modifier}+Shift+Return" = "exec $browser";
        "${modifier}+p" = "exec \"echo 'toggle visibility' > /tmp/wcp\"";

        "${modifier}+Print" = "exec grim - | wl-copy";
        "${modifier}+Shift+Print" = "exec grim -g \"$(slurp)\" ~/Pictures/$(date +'%Y-%m-%d-%H%M%S_grim.png') - | wl-copy";
        "Print" = "exec grim -g \"$(slurp)\" - | satty --filename - --output-filename - --copy-command wl-copy";

        "XF86MonBrightnessDown" = "exec ~/.config/eww/scripts/brightness.sh set 5%-";
        "XF86MonBrightnessUp" = "exec ~/.config/eww/scripts/brightness.sh set +5%";

        "--locked --no-repeat XF86AudioMute" = "exec pamixer -t";
        "--locked --no-repeat XF86AudioRaiseVolume" = "exec ~/.config/eww/scripts/volume.sh --increase 5";
        "--locked --no-repeat XF86AudioLowerVolume" = "exec ~/.config/eww/scripts/volume.sh --decrease 5";

        "${modifier}+XF86AudioPlay" = "exec \"echo 1 > /tmp/vmp\"";
        "${modifier}+XF86AudioNext" = "exec \"echo 2 > /tmp/vmp\"";
        "${modifier}+XF86AudioPrev" = "exec \"echo 3 > /tmp/vmp\"";

        "${modifier}+Shift+e" = "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -B 'Yes, exit sway' 'swaymsg exit'";
      };

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

      bars = [ ];
    };
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

  xdg.configFile = {
    "eww/scripts/get-workspaces.sh" = {
      text = ''
        #!/bin/sh
        swaymsg -t subscribe -m '["window", "workspace"]' | while read -r line; do
          swaymsg -t get_tree | jq -c '
            [
              recurse(.nodes[], .floating_nodes[]) |
              select(.type == "workspace") |
              {
                num: .num,
                focused: .focused,
                windows: [
                  recurse(.nodes[]?, .floating_nodes[]?) |
                  select(.app_id? != null or .window_properties?.class != null) |
                  {
                    app_id: .app_id,
                    class: (.window_properties.class // null)
                  }
                ]
              }
            ]
          '
        done
      '';
      executable = true;
    };

    "eww/eww.scss".text = ''
      * {
        all: unset;
      }

      .bar {
        background-color: rgba(0, 0, 0, 0.2);
        color: #ffffff;
        padding: 0.2rem;
      }

      .workspaces {
        margin-left: 8px;
      }

      .workspace-button {
        min-width: 20px;
        min-height: 20px;
        border-radius: 4px;
        padding: 0 4px;
        background-color: rgba(255, 255, 255, 0.05);
        transition: all 200ms ease;
      }

      .workspace-button.empty {
        background-color: rgba(255, 255, 255, 0.02);
        min-width: 16px;
        min-height: 16px;
        padding: 0 2px;
        opacity: 0.4;
      }

      .workspace-button.focused {
        background-color: rgba(255, 255, 255, 0.1);
        border: 1px solid rgba(255, 255, 255, 0.15);
        opacity: 1;
      }

      .workspace-button:hover {
        background-color: rgba(255, 255, 255, 0.1);
      }

      .window-icon {
        font-family: "FiraCode Nerd Font";
        font-size: 12px;
        color: rgba(255, 255, 255, 0.8);
        margin: 0 2px;
      }

      .status {
        padding: 0 1rem;
      }

      .volume-indicator,
      .brightness-indicator {
        background-color: rgba(0, 0, 0, 0.2);
        border: 1px solid rgba(255, 255, 255, 0.1);
        border-radius: 8px;
        padding: 1rem;
        margin: 1rem;
        color: #ffffff;
      }

      .volume-scale scale trough,
      .brightness-scale scale trough {
        background-color: rgba(255, 255, 255, 0.1);
        border-radius: 24px;
        margin: 0 1rem;
        min-height: 10px;
        min-width: 120px;
      }

      .volume-scale scale trough highlight,
      .brightness-scale scale trough highlight {
        background-color: #ffffff;
        border-radius: 24px;
      }
    '';

    "eww/eww.yuck".text = ''
      ;; Variable declarations
      (deflisten workspaces :initial "[]" "~/.config/eww/scripts/get-workspaces.sh")
      (defpoll volume :interval "1s" "pamixer --get-volume")
      (defpoll brightness :interval "1s" "brightnessctl -m | awk -F, '{print substr($4, 0, length($4)-1)}'")

      ;; Widget definitions
      (defwidget workspaces []
        (box :class "workspaces"
             :orientation "h"
             :space-evenly false
             :halign "start"
             :spacing 4
          (for workspace in workspaces
            (button
              :onclick "swaymsg workspace number {workspace.num}"
              :class {workspace.focused ? "workspace-button focused" :
                      arraylength(workspace.windows) > 0 ? "workspace-button occupied" :
                      "workspace-button empty"}
              (box :class "workspace-content"
                   :space-evenly false
                   :spacing 4
                (for window in {workspace.windows}
                  (label :class "window-icon"
                         :text {
                           window.app_id == "kitty" ? "󰆍" :
                           window.app_id == "firefox" ? "󰈹" :
                           window.app_id == "chromium" ? "" :
                           window.app_id == "vesktop" ? "󰙯" :
                           window.class == "Steam" ? "󰓓" :
                           window.app_id == "org.keepassxc.KeePassXC" ? "󰷡" :
                           window.app_id == "code" ? "󰨞" :
                           window.app_id == "thunar" ? "󰉋" :
                           ""
                         })))))))

      (defwidget metric [label value onchange]
        (box :orientation "h"
             :class "metric"
             :space-evenly false
          (box :class "label" label)
          (scale :min 0
                 :max 101
                 :active {onchange != ""}
                 :value value
                 :onchange onchange)))

      (defwidget time []
        (box :class "time"
             :orientation "h"
             :space-evenly false
             :halign "center"
          {formattime(EWW_TIME, "%H:%M")}))

      (defwidget volume []
        (box :class "volume-indicator"
             :orientation "h"
             :space-evenly false
          (box :class "volume-icon" "󰕾")
          (scale :class "volume-scale"
                 :value volume
                 :orientation "h"
                 :tooltip {volume + "%"}
                 :max 100
                 :min 0)))

      (defwidget brightness []
        (box :class "brightness-indicator"
             :orientation "h"
             :space-evenly false
          (box :class "brightness-icon" "󰃞")
          (scale :class "brightness-scale"
                 :value brightness
                 :orientation "h"
                 :tooltip {brightness + "%"}
                 :max 100
                 :min 0)))

      (defwidget sidestuff []
        (box :class "status"
             :orientation "h"
             :space-evenly false
             :halign "end"
             :spacing 15
          (metric :label "󰻠"
                  :value {EWW_RAM.used_mem_perc}
                  :onchange "")
          (metric :label "󰍛"
                  :value {round((1 - EWW_CPU.avg) * 100)}
                  :onchange "")
          (metric :label "󰋊"
                  :value {EWW_BATTERY["BAT0"].capacity}
                  :onchange "")))

      (defwidget bar []
        (centerbox :orientation "h"
          (workspaces)
          (time)
          (sidestuff)))

      ;; Window definitions
      (defwindow bar
        :monitor 0
        :exclusive true
        :geometry (geometry :x "0%"
                           :y "0%"
                           :width "100%"
                           :height "24px"
                           :anchor "top center")
        (bar))

      (defwindow volume-indicator
        :monitor 0
        :geometry (geometry :x "0%"
                           :y "80%"
                           :width "140px"
                           :height "40px"
                           :anchor "center")
        :stacking "overlay"
        (volume))

      (defwindow brightness-indicator
        :monitor 0
        :geometry (geometry :x "0%"
                           :y "80%"
                           :width "140px"
                           :height "40px"
                           :anchor "center")
        :stacking "overlay"
        (brightness))
    '';

    "eww/scripts/volume.sh" = {
      text = ''
        #!/bin/sh
        volume() {
          pamixer "$@"
          eww open volume-indicator
          sleep 1
          eww close volume-indicator
        }
        volume "$@"
      '';
      executable = true;
    };

    "eww/scripts/brightness.sh" = {
      text = ''
        #!/bin/sh
        brightness() {
          brightnessctl "$@"
          eww open brightness-indicator
          sleep 1
          eww close brightness-indicator
        }
        brightness "$@"
      '';
      executable = true;
    };

    "eww/start-bar.sh" = {
      text = ''
        #!/bin/sh
        pkill eww || true
        sleep 1
        eww daemon
        sleep 2
        eww open bar
      '';
      executable = true;
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

home.pointerCursor = {
  name = "rose-pine-cursor"; # The name of the cursor theme
  package = pkgs.rose-pine-cursor; # Reference to the package in Nixpkgs
  size = 24; # Cursor size (adjust as needed)
  x11 = {
    enable = true;
    defaultCursor = "left_ptr"; # Default cursor shape
  };
};

}
