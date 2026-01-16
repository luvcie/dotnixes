{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../pksay.nix
    ../../modules/audio.nix
    ../../modules/kernel.nix
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
      automatic = false;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    optimise = {
      automatic = true;
      dates = ["weekly"];
    };
    package = lib.mkForce (pkgs.nix.overrideAttrs (oldAttrs: {
      separateDebugInfo = false;
      __structuredAttrs = true;
    }));
  };

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "max";
        editor = false;
      };
      efi.canTouchEfiVariables = true;
      timeout = 3;
    };

    plymouth = {
      enable = true;
      theme = "script";
    };

    # Hide boot messages for clean plymouth experience
    consoleLogLevel = 3;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];

    kernel.sysctl = {
      "vm.swappiness" = 10;
      "vm.vfs_cache_pressure" = 50;
    };
  };

  nixpkgs.config = {
    allowunfree = true;
    separateDebugInfo = false;
  };

  services.gvfs.enable = true;

  #######################
  #  DISPLAY & DESKTOP  #
  #######################

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
    ];
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
      niri = {
        default = lib.mkForce ["wlr"];
        "org.freedesktop.impl.portal.Screenshot" = ["wlr"];
        "org.freedesktop.impl.portal.Screencast" = ["wlr"];
      };
      hyprland = {
        default = ["wlr"];
        "org.freedesktop.impl.portal.Screenshot" = ["wlr"];
        "org.freedesktop.impl.portal.Screencast" = ["wlr"];
      };
      xfce = {
        default = ["gtk"];
        "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
      };
      cinnamon = {
        default = ["gtk"];
        "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
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
    cpuFreqGovernor = "schedutil";
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

    desktopManager = {
      xfce = {
        enable = true;
        enableScreensaver = false;
      };
      cinnamon.enable = true;
    };
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

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "ignore";
  };

  services.displayManager = {
    ly.enable = true;
    defaultSession = "cinnamon";
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

  programs.niri.enable = true;
  programs.hyprland.enable = true;

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
    AMD_VULKAN_ICD = "RADV";
    RADV_PERFTEST = "gpl,nosam";
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
    STEAM_RUNTIME_PREFER_HOST_LIBRARIES = "0";
    PROTON_FORCE_LARGE_ADDRESS_AWARE = "1";
    PROTON_USE_SECCOMP = "1";
    STEAM_GAMESCOPE_HDR = "1";
    STEAM_USE_DYNAMIC_VRS = "1";
  };

  security.pam = {
    loginLimits = [
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
    hostName = "T495";
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

  services.flatpak.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    # package = pkgs.steam-millennium;  # Temporarily disabled for faster builds
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };

  programs = {
    zsh.enable = true;
    direnv.enable = true;
    appimage.binfmt.enable = true;
    nix-ld.enable = true;

    nh = {
      enable = true;
      clean.enable = true;
      flake = "/home/lucie/dotnixes";
    };

    # gamescope = {
    #   enable = true;
    #   capSysNice = true;
    #   args = [
    #     "--adaptive-sync"
    #   ];
    # };
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
	clang
    gamescope
    ly
    android-tools
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
    cachix
    age
    tldr
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
      "video"
      "input"
      "render"
      "gamemode"
      "kvm"
      "dialout"
    ];
    shell = pkgs.zsh;
  };

  # ThinkPad LED morse code service
  systemd.services.morse-led = {
    description = "ThinkPad LED morse code (42)";
    wantedBy = ["multi-user.target"];
    after = ["multi-user.target"];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.bash}/bin/bash /home/lucie/dotnixes/morse.sh";
      Restart = "always";
      RestartSec = "10s";
    };
  };
}
