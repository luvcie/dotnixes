{
  pkgs,
  lib,
  config,
  ...
}: let
  configDir = "${config.home.homeDirectory}/qbittorrent/config";
  downloadsDir = "/mnt/media/downloads";
in {
  sops.templates."jackett.json" = {
    path = "${config.home.homeDirectory}/qbittorrent/jackett.json";
    content = builtins.toJSON {
      api_key = config.sops.placeholder.jackett_api_key;
      thread_count = 20;
      tracker_first = false;
      url = "http://proxmox-lab.tail5296cb.ts.net:9117";
    };
  };

  systemd.user.services.qbittorrent = {
    Unit = {
      Description = "qbittorrent torrent client podman container";
      After = ["network.target" "sops-nix.service"];
    };
    Service = {
      Restart = "always";
      ExecStartPre = [
        "${pkgs.coreutils}/bin/mkdir -p ${configDir}"
        "${pkgs.coreutils}/bin/mkdir -p ${downloadsDir}"
        "-${pkgs.podman}/bin/podman stop qbittorrent"
        "-${pkgs.podman}/bin/podman rm qbittorrent"
      ];
      ExecStart = "${pkgs.podman}/bin/podman run --name qbittorrent --userns=keep-id -p 8085:8080 " +
        "-v ${configDir}:/config:Z " +
        "-v ${config.xdg.configHome}/sops-nix/secrets/rendered/jackett.json:/config/qBittorrent/nova3/engines/jackett.json:ro " +
        "-v ${downloadsDir}:/downloads:Z " +
        "-e PUID=1000 " +
        "-e PGID=1000 " +
        "-e TZ=Europe/Paris " +
        "-e WEBUI_PORT=8080 " +
        "docker.io/linuxserver/qbittorrent:latest";
      ExecStop = "${pkgs.podman}/bin/podman stop qbittorrent";
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };
}
