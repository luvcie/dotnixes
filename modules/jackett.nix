{
  pkgs,
  lib,
  config,
  ...
}: let
  configDir = "${config.home.homeDirectory}/jackett/config";
in {
  systemd.user.services.jackett = {
    Unit = {
      Description = "jackett torrent indexer podman container";
      After = ["network.target"];
    };
    Service = {
      Restart = "always";
      ExecStartPre = [
        "${pkgs.coreutils}/bin/mkdir -p ${configDir}"
        "-${pkgs.podman}/bin/podman stop jackett"
        "-${pkgs.podman}/bin/podman rm jackett"
      ];
      ExecStart = "${pkgs.podman}/bin/podman run --name jackett -p 9117:9117 " +
        "-v ${configDir}:/config:Z " +
        "-e PUID=1000 " +
        "-e PGID=1000 " +
        "-e TZ=Europe/Paris " +
        "docker.io/linuxserver/jackett:latest";
      ExecStop = "${pkgs.podman}/bin/podman stop jackett";
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };
}
