{
  pkgs,
  lib,
  config,
  ...
}: let
  configDir = "${config.home.homeDirectory}/qbittorrent/config";
  downloadsDir = "/mnt/media/downloads";
in {
  systemd.user.services.qbittorrent = {
    Unit = {
      Description = "qbittorrent torrent client podman container";
      After = ["network.target"];
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
