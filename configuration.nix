{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./pksay.nix
  ];

  #######################
  #    configuration    #
  #######################

  system.stateVersion = "23.11";

  nix = {
    settings = {
      sandbox = true;
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
      builders-use-substitutes = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    optimise = {
      automatic = true;
      dates = ["weekly"];
    };
  };

  nixpkgs.config.allowUnfree = true;

  services.gvfs.enable = true;

  #######################
  #   boot & hardware   #
  #######################

  boot = {
    kernelPackages = pkgs.linuxPackages_zen;

    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "max";
        editor = false;
      };
      efi.canTouchEfiVariables = true;
      timeout = 3;
    };

    kernelParams = [
      "amdgpu.gpu_recovery=1"
      "transparent_hugepage=never"
    ];

    kernel.sysctl = {
      "vm.swappiness" = 10;
      "vm.vfs_cache_pressure" = 50;
      "vm.max_map_count" = 262144;

      "kernel.sched_autogroup_enabled" = 0;
      "kernel.sched_child_runs_first" = 1;

      "fs.file-max" = 2097152;
      "fs.inotify.max_user_watches" = 524288;

      "net.core.rmem_max" = 2500000;
      "net.core.wmem_max" = 2500000;
      "net.core.rmem_default" = 1048576;
      "net.core.wmem_default" = 1048576;
      "net.ipv4.tcp_fastopen" = 3;
      "net.ipv4.tcp_congestion_control" = "bbr";

      "kernel.pid_max" = 4194304;

      "kernel.unprivileged_userns_clone" = 1;
    };

    kernelModules = ["binder_linux" "ashmem_linux"];
  };

  #######################
  #  DISPLAY & DESKTOP  #
  #######################

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
    config = {
      common = {
        default = ["gtk"];
        "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
      };
      sway = {
        default = lib.mkForce ["wlr"];
        "org.freedesktop.impl.portal.Screenshot" = ["wlr"];
        "org.freedesktop.impl.portal.Screencast" = ["wlr"];
      };
    };
  };

  hardware = {
    bluetooth.enable = true;
    ledger.enable = true;
    xone.enable = true;

    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  powerManagement = {
    cpuFreqGovernor = "performance";
    enable = true;
  };

  services.xserver = {
    enable = true;

    xkb = {
      variant = "";
    };

    videoDrivers = ["amdgpu"];
    deviceSection = ''
      Option "VariableRefresh" "true"
      Option "DRI" "3"
    '';
  };

  services.libinput = {
    enable = true;
    touchpad = {
      tapping = true;
      naturalScrolling = false;
      scrollMethod = "twofinger";
      accelSpeed = "0.7";
      disableWhileTyping = true;
    };
  };

  services.displayManager.ly = {
    enable = true;
  };

  console = {
    useXkbConfig = true;
    font = "Lat2-Terminus16";
  };

  services.dbus.implementation = "broker";

  programs.sway = {
    enable = true;
    package = pkgs.swayfx;
    wrapperFeatures.gtk = true;
  };

  programs = {
    xwayland.enable = true;
    waybar.enable = false;

    gamemode = {
      enable = true;
      settings = {
        general = {
          renice = 10;
          softrealtime = "auto";
          inhibit_screensaver = 1;
          ioprio = 0;
        };
        gpu = {
          apply_gpu_optimisations = "accept-responsibility";
          gpu_device = 0;
          igpu_power_control = "yes";
          igpu_high_performance = "yes";
        };
        custom = {
          start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
          end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
        };
      };
    };
  };

  environment.variables = {
    NIXOS_OZONE_WL = "1";
    AMD_VULKAN_ICD = "RADV";
    RADV_PERFTEST = "gpl,nosam";
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    GDK_BACKEND = "wayland";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    XDG_SESSION_TYPE = "wayland";
  };
  #######################
  # AUDIO CONFIGURATION #
  #######################

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    extraConfig.pipewire = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.quantum" = 1024;
        "default.clock.min-quantum" = 1024;
        "default.clock.max-quantum" = 1024;
        "core.clock.power-of-two-quantum" = true;

        "core.daemon" = true;
        "core.name" = "pipewire-0";
        "mem.allow-mlock" = true;

        "node.latency" = "256/48000";
        "vm.overcommit" = true;

        "default.clock.allowed-rates" = [44100 48000 88200 96000];

        "core.recovery.time" = 10000;

        "default.fragments" = 2;
        "default.fragment.size-max" = 4096;

        "default.format" = "F32";
        "default.position" = ["FL" "FR"];

        "support.dbus" = true;
        "log.level" = 2;

        "pulse.min.req" = 256;
        "pulse.default.req" = 256;
        "pulse.max.req" = 256;
        "pulse.min.frag" = 256;
        "pulse.default.frag" = 256;
        "pulse.max.frag" = 256;
      };

      "context.modules" = [
        {
          name = "libpipewire-module-rtkit";
          args = {
            "nice.level" = -20;
            "rt.prio" = 99;
            "rt.time.soft" = 2000000;
            "rt.time.hard" = 2000000;
          };
          flags = ["ifexists" "nofail"];
        }
        {
          name = "libpipewire-module-protocol-pulse";
          args = {
            "pulse.min.req" = "256/48000";
            "pulse.default.req" = "256/48000";
            "pulse.max.req" = "256/48000";
            "pulse.min.quantum" = "256/48000";
            "pulse.max.quantum" = "256/48000";
          };
        }
      ];
    };
  };

  security.pam = {
    loginLimits = [
      {
        domain = "@audio";
        item = "memlock";
        type = "-";
        value = "unlimited";
      }
      {
        domain = "@audio";
        item = "rtprio";
        type = "-";
        value = "99";
      }
      {
        domain = "@audio";
        item = "nofile";
        type = "soft";
        value = "99999";
      }
      {
        domain = "@audio";
        item = "nofile";
        type = "hard";
        value = "99999";
      }
      {
        domain = "@audio";
        item = "nice";
        type = "-";
        value = "-20";
      }
      {
        domain = "@realtime";
        item = "nice";
        type = "-";
        value = "-20";
      }
      {
        domain = "@realtime";
        item = "rtprio";
        type = "-";
        value = "99";
      }
      {
        domain = "*";
        item = "memlock";
        type = "soft";
        value = "unlimited";
      }
      {
        domain = "*";
        item = "memlock";
        type = "hard";
        value = "unlimited";
      }
    ];
    services = {
      swaylock.text = "auth include login";
      ly.enableGnomeKeyring = true;
    };
  };

  services.udev.extraRules = "";

  #######################
  #     NETWORKING      #
  #######################

  networking = {
    hostName = "nixosthinkpad";
    networkmanager = {
      enable = true;
      wifi.powersave = false;
    };

    firewall = {
      enable = true;
      allowedTCPPorts = [27036 27037];
      allowedUDPPorts = [27031 27036];
    };
  };
  security.polkit.enable = true;

  services.gnome.gnome-keyring.enable = true;

  services.dbus = {
    enable = true;
    packages = [pkgs.gcr];
  };

  security.pam.services.login.enableGnomeKeyring = true;

  #########################
  # GAMING & APPLICATIONS #
  #########################

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    package = pkgs.steam.override {
      extraProfile = ''
        # Steam game optimizations
        export STEAM_RUNTIME_PREFER_HOST_LIBRARIES=0
        export PROTON_FORCE_LARGE_ADDRESS_AWARE=1
        export PROTON_USE_SECCOMP=1
        export SDL_VIDEODRIVER=wayland
        export STEAM_GAMESCOPE_HDR=1
        export STEAM_USE_DYNAMIC_VRS=1
        # AMD specific
        export AMD_VULKAN_ICD=RADV
        export RADV_PERFTEST=gpl,nosam
      '';
    };
  };

  programs = {
    zsh.enable = true;
    direnv.enable = true;
    git.enable = true;
    adb.enable = true;
    appimage.binfmt.enable = true;

    gamescope = {
      enable = true;
      capSysNice = true;
      args = [
        "--immediate-submit"
        "--adaptive-sync"
        "--expose-wayland"
        "--steam"
      ];
    };
    corectrl.enable = true;
  };

  virtualisation = {
    docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };
    podman.enable = true;
    waydroid.enable = false;
  };

  #######################
  #   SYSTEM SERVICES   #
  #######################

  services = {
    printing = {
      enable = true;
      browsing = true;
      drivers = with pkgs; [gutenprint hplip splix];
    };

    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    fstrim = {
      enable = true;
      interval = "weekly";
    };

    tailscale.enable = true;
    udisks2.enable = true;

    thermald.enable = true;
  };

  #######################
  #   SYSTEM PACKAGES   #
  #######################

  environment.systemPackages = with pkgs; [
    ly
    pavucontrol
    usbutils
    udiskie
    udisks
    btop
    htop
    killall
    tree
    unzip
    p7zip
    unrar
    wlogout
    nemo-with-extensions
    lsof
    swaylock
    swayidle
    swayfx
    dmenu
    xwayland
    git
    cachix
    age
    tldr
    ranger
    fastfetch
    cpufetch
    alacritty
    bsdgames
    fuzzel
    wofi
    wget
    nmap
    inetutils
    magic-wormhole-rs
    networkmanagerapplet
    yt-dlp
    radeontop
    radeon-profile
    libinput
    libinput-gestures
  ];

  ######################
  # USER CONFIGURATION #
  ######################

  users.users.lucie = {
    isNormalUser = true;
    description = "Lucie";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "audio"
      "realtime"
      "video"
      "input"
      "render"
      "gamemode"
      "kvm"
    ];
    shell = pkgs.zsh;
  };
}
