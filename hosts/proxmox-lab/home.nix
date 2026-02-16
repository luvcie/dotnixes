{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: {
  # grab the modules
  imports = [
    ../../modules/zsh.nix
    ../../modules/copyparty.nix
    ../../modules/vnc.nix
    ../../modules/homepage.nix
    ../../modules/cloudflared.nix
    ../../modules/portainer.nix
    ../../modules/shell-bridge.nix
    ../../modules/plex.nix
    ../../modules/navidrome.nix
    ../../modules/funkwhale.nix
    ../../modules/qbittorrent.nix
    ../../modules/jackett.nix
    ../../modules/lidarr.nix
    ../../modules/website.nix
    ../../modules/tailscale-certs.nix
    ../../modules/proxmox-cert-sync.nix
    ../../modules/i2pd.nix
    ../../modules/yggdrasil.nix
    ../../modules/sunshine.nix
    ../../modules/couchdb.nix
    ../../modules/caddy.nix
  ];

  programs.home-manager.enable = true;

  home = {
    username = "weew";
    homeDirectory = "/home/weew";
    stateVersion = "23.11";

    sessionPath = [
      "$HOME/.local/bin"
    ];

    packages = with pkgs; [
      helix
      kmod
      lvm2_vdo
      btop
      yazi
      bat
      gh
      ripgrep
      fd
      nh
      sops
      age
      tailscale
      fuse-overlayfs
    ];
  };

  nixpkgs.config.allowUnfree = true;

  sops = {
    defaultSopsFile = ../../vault/encrypted-sops-secrets.yaml;
    # point to your master key
    age.keyFile = "/home/weew/.config/sops/age/keys.txt";
    
    secrets = {
      copyparty_princess_password = {};
      copyparty_guest_password = {};
      proxmox_api_token = {};
      yggdrasil_private_key = {};
      plex_claim_token = {};
      jackett_api_key = {};
      qbittorrent_username = {};
      qbittorrent_password = {};
      portainer_api_key = {};
      couchdb_username = {};
      couchdb_password = {};
    };
  };
}
