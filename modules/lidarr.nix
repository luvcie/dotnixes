{
  pkgs,
  lib,
  config,
  ...
}: let
  configDir = "${config.home.homeDirectory}/lidarr/config";
  downloadsDir = "/mnt/media/downloads";
  musicDir = "/mnt/media/music";
in {
  systemd.user.services.lidarr = {
    Unit = {
      Description = "lidarr music automation podman container";
      After = ["network.target"];
    };
    Service = {
      Restart = "always";
      ExecStartPre = [
        "${pkgs.coreutils}/bin/mkdir -p ${configDir}"
        "-${pkgs.podman}/bin/podman stop lidarr"
        "-${pkgs.podman}/bin/podman rm lidarr"
      ];
      ExecStart = "${pkgs.podman}/bin/podman run --name lidarr --userns=keep-id -p 8686:8686 " +
        "-v ${configDir}:/config:Z " +
        "-v ${downloadsDir}:/downloads:Z " +
        "-v ${musicDir}:/music:Z " +
        "-e PUID=1000 " +
        "-e PGID=1000 " +
        "-e TZ=Europe/Paris " +
        "docker.io/linuxserver/lidarr:latest";
      ExecStop = "${pkgs.podman}/bin/podman stop lidarr";
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };
}
