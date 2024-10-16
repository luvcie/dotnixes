# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./pksay.nix
  ];

  # Sandboxing
  nix.settings.sandbox = true;

  # Kernel version
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Desktop Environment and Display Manager
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;
  programs.xwayland.enable = true;
  services.xserver.windowManager.xmonad.enable = false;
  # programs.waybar.enable = true;

  # Hostname
  networking.hostName = "nixos";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  # Enable polkit
  security.polkit.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable bluetooth
  services.blueman.enable = false;
  hardware.bluetooth.enable = true;

  # Configure keymap
  services.xserver.xkb = {
    layout = "fr";
    variant = "";
  };
  console.keyMap = "fr";

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # If you want to use JACK applications, uncomment this
  #jack.enable = true;

  # use the example session manager (no others are packaged yet so this is enabled by default,
  # no need to redefine it in your config for now)
  #media-session.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # User groups
  users.users.lucie = {
    isNormalUser = true;
    description = "Lucie";
    extraGroups = ["networkmanager" "wheel" "docker"];
    shell = pkgs.zsh;
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = false;
  services.displayManager.autoLogin.user = "lucie";

  # Enable printing
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.printing = {
    enable = true;
    browsing = true;
    drivers = with pkgs; [
      gutenprint
      hplip
      splix
    ];
  };

  # KDE Connect

  programs.kdeconnect.enable = true;

  networking.firewall = {
    enable = true;
    allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      } # KDE Connect
    ];
    allowedUDPPortRanges = [
      {
        from = 1714;
        to = 1764;
      } # KDE Connect
    ];
  };

  # Allow to run appimages seamlessly with appimage-run
  programs.appimage.binfmt.enable = true;

  # Flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Docker
  virtualisation.docker.enable = true;

  # Gamemode
  programs.gamemode.enable = true;

  # zsh
  programs.zsh.enable = true;

  #direnv
  programs.direnv.enable = true;

  # Git
  programs.git.enable = true;

  # Tor
  services.tor.enable = false;

  # i2cp
  services.i2pd.proto.i2cp.enable = false;

  # Waydroid
  virtualisation.waydroid.enable = false;

  # Flatpak
  services.flatpak.enable = true;

  # Allow adb
  programs.adb.enable = true;

  # udev rules for Ledger devices
  hardware.ledger.enable = true;

  # Gamepad
  hardware.xone.enable = true;

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  # rkvm
  services.rkvm.enable = false;

  # gvfs and udisks 
  services.gvfs.enable = false;
  services.udisks2.enable = true;

  # hydra
  services.hydra = {
    enable = false;
    hydraURL = "http://localhost:3000";
    notificationSender = "hydra@localhost";
    buildMachinesFiles = [];
    useSubstitutes = true;
  };

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    vesktop
    fuzzel
    usbutils
    udiskie
    udisks
    yt-dlp
    cachix
    wget
    wofi
    btop
    tldr
    ranger
    p7zip
    unrar
    q4wine
    inetutils
    magic-wormhole-rs
    neofetch
    screenfetch
    cpufetch
    (nerdfonts.override {fonts = ["FiraCode"];})
    nmap
    tree
    git-agecrypt
    age
    killall
    unzip
    moe
    inputs.umu.packages.${pkgs.system}.umu
  ];

  # RIVER
  #  programs.river = {
  #    enable = true;
  #   extraPackages = with pkgs; [
  #    rivercarro
  #   foot
  #  xfce.thunar
  # swayidle
  #  waylock
  # swww
  # yambar
  # bemenu
  # libnotify mako
  # grim slurp swappy
  # wl-clipboard wlr-randr
  # networkmanagerapplet
  # fuzzel
  # ];
  #  };

  xdg.portal = {
    enable = true;
    config.common.default = ["wlr"];
  };

  security.pam.services.waylock = {
    text = "auth include login";
  };

  #OpenSSH
  services.openssh = {
    enable = true;
    ports = [22];
    settings = {
      PasswordAuthentication = true;
      AllowUsers = null; # Allows all users by default. Can be [ "user1" "user2" ]
      UseDns = true;
      X11Forwarding = true;
      PermitRootLogin = "prohibit-password"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
