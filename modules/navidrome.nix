{
  pkgs,
  lib,
  config,
  ...
}: let
  navidromeDir = "${config.home.homeDirectory}/navidrome";
in {
  systemd.user.services.navidrome = {
    Unit = {
      Description = "navidrome music server podman container";
      After = ["network.target"];
    };
    Service = {
      Restart = "always";
      ExecStartPre = [
        "${pkgs.coreutils}/bin/mkdir -p ${navidromeDir}/data"
        "-${pkgs.podman}/bin/podman stop navidrome"
        "-${pkgs.podman}/bin/podman rm navidrome"
      ];
      ExecStart = "${pkgs.podman}/bin/podman run --name navidrome -p 4533:4533 " +
        "-v ${navidromeDir}/data:/data:Z " +
        "-v /mnt/media/music:/music:ro " +
        "-e ND_ENABLESHARING=true " +
        "docker.io/deluan/navidrome:latest";
      ExecStop = "${pkgs.podman}/bin/podman stop navidrome";
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };
}
