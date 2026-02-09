{
  pkgs,
  lib,
  config,
  ...
}: let
  certDir = "${config.home.homeDirectory}/.tailscale-certs";
  syncScript = pkgs.writeShellScript "sync-proxmox-certs" ''
    sudo cp ${certDir}/cert.pem /etc/pve/local/pve-ssl.pem
    sudo cp ${certDir}/key.pem /etc/pve/local/pve-ssl.key
    sudo systemctl restart pveproxy
  '';
in {
  systemd.user.services.proxmox-cert-sync = {
    Unit = {
      Description = "sync tailscale certs to proxmox";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${syncScript}";
    };
  };

  systemd.user.paths.proxmox-cert-sync = {
    Unit = {
      Description = "watch for tailscale cert changes";
    };
    Path = {
      PathModified = "${certDir}/cert.pem";
    };
    Install = {
      WantedBy = ["paths.target"];
    };
  };
}