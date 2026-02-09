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
    ../../modules/website.nix
    ../../modules/tailscale-certs.nix
    ../../modules/proxmox-cert-sync.nix
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
    };
  };
}
