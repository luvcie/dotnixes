{ config, pkgs, inputs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./pksay.nix
  ];

  #######################
  #    CONFIGURATION    #
  #######################

  system.stateVersion = "23.11";

  # Core system settings
  nix = {
    settings = {
      sandbox = true;
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
      # Optimize build performance
      cores = 4;
      max-jobs = 4;
      # Allow closing other processes when building
      builders-use-substitutes = true;
    };
    # Automatic garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    # Optimize storage
    optimise = {
      automatic = true;
      dates = ["weekly"];
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
#######################
  #   BOOT & HARDWARE   #
  #######################

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    # Bootloader configuration
    loader = {
      systemd-boot = {
        enable = true;
        # Optimize boot performance
        consoleMode = "max";
        editor = false;  # Disable boot editor for security
      };
      efi.canTouchEfiVariables = true;
      timeout = 3;
    };

    # Kernel parameters optimized for AMD APU
    kernelParams = [
      # CPU optimizations
      "threadirqs"
      "mitigations=off"
      "idle=nomwait"
      "processor.max_cstate=1"
      "amd_pstate=active"
      "clearcpuid=rdrand"

      # AMD GPU optimizations
      "amdgpu.ppfeaturemask=0xffffffff"
      "amdgpu.dcfeaturemask=0x8"
      "amdgpu.freesync_video=1"
      "amdgpu.gpu_recovery=1"
      "radeon.si_support=0"
      "amdgpu.si_support=1"

      # System performance
      "preempt=voluntary"
      "transparent_hugepage=never"
      "clocksource=tsc"
      "tsc=reliable"

      # Power management
      "workqueue.power_efficient=off"
      "amd_iommu=off"
      "pcie_aspm=off"

      # Audio and USB
      "amdgpu.audio=0"
      "usbcore.autosuspend=-1"
      "snd_hda_intel.power_save=0"
      "snd_hda_intel.probe_mask=1"
    ];

    kernel.sysctl = {
      # Virtual memory tweaks
      "vm.swappiness" = 10;
      "vm.dirty_ratio" = 60;
      "vm.dirty_background_ratio" = 2;
      "vm.vfs_cache_pressure" = 50;
      "vm.max_map_count" = 262144;

      # Kernel scheduler
      "kernel.sched_autogroup_enabled" = 0;
      "kernel.sched_child_runs_first" = 1;
      "kernel.sched_min_granularity_ns" = 10000000;
      "kernel.sched_wakeup_granularity_ns" = 15000000;

      # File system tweaks
      "fs.file-max" = 2097152;
      "fs.inotify.max_user_watches" = 524288;

      # Network optimization
      "net.core.rmem_max" = 2500000;
      "net.core.wmem_max" = 2500000;
      "net.core.rmem_default" = 1048576;
      "net.core.wmem_default" = 1048576;
      "net.ipv4.tcp_fastopen" = 3;
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.ipv4.tcp_slow_start_after_idle" = 0;

      # PID optimization
      "kernel.pid_max" = 4194304;
    };
  };
#######################
  #  DISPLAY & DESKTOP  #
  #######################

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # Enable extra portals
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    # Configure default portal behavior
    config = {
      common = {
        default = ["gtk"];
        "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
      };
      # Configure sway-specific portals
      sway = {
        default = ["wlr"];
        "org.freedesktop.impl.portal.Screenshot" = ["wlr"];
        "org.freedesktop.impl.portal.Screencast" = ["wlr"];
      };
    };
  };

  # AMD GPU specific hardware config
  hardware = {
    bluetooth.enable = true;
    ledger.enable = true;
    xone.enable = true;

    # New unified graphics setup for 24.11+
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        rocm-opencl-icd
        rocm-opencl-runtime
        amdvlk
      ];
      extraPackages32 = with pkgs; [
        driversi686Linux.amdvlk
      ];
    };
  };

  # Power management optimization
  powerManagement = {
    cpuFreqGovernor = "performance";
    enable = true;
    powertop.enable = true;
  };

# Display and window management configuration
  services.xserver = {
    enable = true;

    # Input settings
    xkb = {
      variant = "";
    };

    # AMD GPU optimizations
    videoDrivers = [ "amdgpu" ];
    deviceSection = ''
      Option "TearFree" "true"
      Option "VariableRefresh" "true"
      Option "AsyncFlipSecondaries" "true"
      Option "DRI" "3"
      Option "AccelMethod" "glamor"
    '';

    # Keep GDM as display manager
    displayManager = {
      gdm = {
        enable = true;
        wayland = true;
      };
      defaultSession = "sway";
    };
  };

  # Console settings
  console = {
    useXkbConfig = true;
    font = "Lat2-Terminus16";
  };

  # UWSM and dbus configuration
  services.dbus.implementation = "broker";  # Use dbus-broker as recommended

  programs.uwsm = {
    enable = true;
    waylandCompositors.sway = {
      prettyName = "Sway";
      binPath = "${pkgs.sway}/bin/sway";
      comment = "Tiling Wayland compositor";
    };
  };

  # Sway configuration
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;  # Enables GTK integration
  };

  # Wayland configuration
  programs = {
    xwayland.enable = true;
    waybar.enable = false;

    # Game optimizations
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
          amd_performance_level = "high";
          # APU specific settings
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

  # Environment variables for AMD and Wayland
  environment.variables = {
    # Wayland
    NIXOS_OZONE_WL = "1";
    # AMD variables
    AMD_VULKAN_ICD = "RADV";
    RADV_PERFTEST = "gpl,nosam";  # Optimized for APU
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json";
    # Compatibility
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
    # Wayland-specific
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    GDK_BACKEND = "wayland";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    XDG_SESSION_TYPE = "wayland";
    # Mesa optimization
    MESA_VK_VERSION_OVERRIDE = "1.3";
    MESA_LOADER_DRIVER_OVERRIDE = "radeonsi";
  };
#######################
  # AUDIO CONFIGURATION #
  #######################

  # Enable RealtimeKit
  security.rtkit.enable = true;

  # PipeWire Configuration
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    # Low-latency audio configuration
    extraConfig.pipewire = {
      "context.properties" = {
        # Core settings
        "default.clock.rate" = 48000;
        "default.clock.quantum" = 1024;
        "default.clock.min-quantum" = 1024;
        "default.clock.max-quantum" = 1024;
        "core.clock.power-of-two-quantum" = true;

        # Process settings
        "core.daemon" = true;
        "core.name" = "pipewire-0";
        "mem.allow-mlock" = true;

        # Latency settings
        "node.latency" = "256/48000";
        "vm.overcommit" = true;

        # Sample rates
        "default.clock.allowed-rates" = [ 44100 48000 88200 96000 ];

        # Recovery settings
        "core.recovery.time" = 10000;

        # Fragment settings
        "default.fragments" = 2;
        "default.fragment.size-max" = 4096;

        # Format settings
        "default.format" = "F32";
        "default.position" = ["FL" "FR"];

        # Additional optimizations
        "support.dbus" = true;
        "log.level" = 2;

        # PulseAudio compatibility settings
        "pulse.min.req" = 256;
        "pulse.default.req" = 256;
        "pulse.max.req" = 256;
        "pulse.min.frag" = 256;
        "pulse.default.frag" = 256;
        "pulse.max.frag" = 256;
      };

      # Module configuration
      "context.modules" = [
        {
          name = "libpipewire-module-rtkit";
          args = {
            "nice.level" = -20;
            "rt.prio" = 99;
            "rt.time.soft" = 2000000;
            "rt.time.hard" = 2000000;
          };
          flags = [ "ifexists" "nofail" ];
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

  # Unified PAM configuration
  security.pam = {
    loginLimits = [
      # Audio and realtime limits
      { domain = "@audio"; item = "memlock"; type = "-"; value = "unlimited"; }
      { domain = "@audio"; item = "rtprio"; type = "-"; value = "99"; }
      { domain = "@audio"; item = "nofile"; type = "soft"; value = "99999"; }
      { domain = "@audio"; item = "nofile"; type = "hard"; value = "99999"; }
      { domain = "@audio"; item = "nice"; type = "-"; value = "-20"; }
      { domain = "@realtime"; item = "nice"; type = "-"; value = "-20"; }
      { domain = "@realtime"; item = "rtprio"; type = "-"; value = "99"; }
      # System limits
      { domain = "*"; item = "memlock"; type = "soft"; value = "unlimited"; }
      { domain = "*"; item = "memlock"; type = "hard"; value = "unlimited"; }
    ];
    services.swaylock.text = "auth include login";
  };

  # Scheduling services
  systemd.services = {
    # CPU scheduler
    cpu-scheduler = {
      description = "CPU scheduler optimization";
      script = ''
        echo 2 > /sys/class/rtc/rtc0/max_user_freq
        echo 2048 > /proc/sys/vm/nr_hugepages
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      wantedBy = [ "multi-user.target" ];
    };

    # Audio scheduler
    audio-scheduler = {
      description = "Audio thread scheduling optimization";
      script = ''
        echo 75 > /proc/sys/kernel/sched_priority_audio
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      wantedBy = [ "multi-user.target" ];
    };
  };

  # Device rules
  services.udev.extraRules = ''
    # CPU and audio optimizations
    SUBSYSTEM=="cpu", ACTION=="add", ATTR{cpufreq/scaling_governor}="performance"
    SUBSYSTEM=="sound", ATTR{power/control}="on"
    # USB audio priority
    SUBSYSTEM=="usb", ATTR{power/control}="on"
    SUBSYSTEM=="usb", ATTR{power/autosuspend}="-1"
    # AMD GPU specific rules
    KERNEL=="card0", SUBSYSTEM=="drm", DRIVERS=="amdgpu", ATTR{device/power_dpm_force_performance_level}="high"
    # Audio device rules
    KERNEL=="snd_*", ENV{PULSE_IGNORE}="1"
  '';
#######################
  #      NETWORKING     #
  #######################

  networking = {
    hostName = "nixosthinkpad";
    # Network optimization
    networkmanager = {
      enable = true;
      wifi.powersave = false;
    };

    # Firewall configuration
    firewall = {
      enable = true;
      # Steam ports
      allowedTCPPorts = [ 27036 27037 ];
      allowedUDPPorts = [ 27031 27036 ];
    };
  };

  security.polkit.enable = true;

  services.gnome.gnome-keyring.enable = true;

  services.dbus = {
    enable = true;
    packages = [ pkgs.gcr ];
  };

  security.pam.services.login.enableGnomeKeyring = true;

  #########################
  # GAMING & APPLICATIONS #
  #########################

  # Steam configuration
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

  # Core programs
  programs = {
    zsh.enable = true;
    direnv.enable = true;
    git.enable = true;
    adb.enable = true;
    appimage.binfmt.enable = true;

    # Gamescope enhancement
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
    corectrl.enable = true;  # AMD GPU control
  };

  # Virtualization
  virtualisation = {
    docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };
  };

  #######################
  #   SYSTEM SERVICES   #
  #######################

  services = {
    # Printing
    printing = {
      enable = true;
      browsing = true;
      drivers = with pkgs; [ gutenprint hplip splix ];
    };

    # Network services
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    # System optimization
    fstrim = {
      enable = true;
      interval = "weekly";
    };

    # System services
    tailscale.enable = true;
    udisks2.enable = true;

    # Performance monitoring
    thermald.enable = true;  # CPU temperature management
  };

  #######################
  #   SYSTEM PACKAGES   #
  #######################

  environment.systemPackages = with pkgs; [
    # System utilities
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

    # Sway essentials
    swaylock
    swayidle
    sway
    dmenu
    xwayland

    # Development
    git
    cachix

    # Terminal utilities
    tldr
    ranger
    neofetch
    cpufetch

    # Window management
    fuzzel
    wofi

    # Network utilities
    wget
    nmap
    inetutils
    magic-wormhole-rs
    networkmanagerapplet

    # Media
    yt-dlp

    # AMD utilities
    radeontop
    radeon-profile

    # Security
    age

    # Fonts
    (nerdfonts.override {fonts = ["FiraCode"];})

    # Custom packages
    inputs.umu.packages.${pkgs.system}.umu
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
      "gamemode"  # Added for GameMode
      "kvm"       # For virtualization
    ];
    shell = pkgs.zsh;
  };
}
