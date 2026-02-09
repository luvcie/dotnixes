{
  pkgs,
  lib,
  config,
  ...
}: let
  certDir = "${config.home.homeDirectory}/.tailscale-certs";
  domain = "proxmox-lab.tail5296cb.ts.net";
in {
  # make sure the directory exists
  home.file."${certDir}/.keep".text = "";

  systemd.user.services.tailscale-certs = {
    Unit = {
      Description = "fetch tailscale certificates";
      After = ["network.target"];
    };
    Service = {
      ExecStart = "${pkgs.tailscale}/bin/tailscale cert --cert-file ${certDir}/cert.pem --key-file ${certDir}/key.pem ${domain}";
      Restart = "always";
      RestartSec = "86400"; 
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };

  systemd.user.timers.tailscale-certs = {
    Unit = { Description = "daily tailscale certificate renewal"; };
    Timer = {
      OnCalendar = "daily";
      Persistent = true;
    };
    Install = { WantedBy = ["timers.target"]; };
  };
}