{
  pkgs,
  lib,
  config,
  ...
}: let
  funkwhaleDir = "${config.home.homeDirectory}/funkwhale";
in {
  systemd.user.services.funkwhale = {
    Unit = {
      Description = "funkwhale federated music server podman container";
      After = ["network.target"];
    };
    Service = {
      Restart = "always";
      ExecStartPre = [
        "${pkgs.coreutils}/bin/mkdir -p ${funkwhaleDir}/data"
        "-${pkgs.podman}/bin/podman stop funkwhale"
        "-${pkgs.podman}/bin/podman rm funkwhale"
      ];
      ExecStart = "${pkgs.podman}/bin/podman run --name funkwhale -p 3030:80 " +
        "-v ${funkwhaleDir}/data:/data:Z " +
        "-v /mnt/media/music:/music:ro " +
        "-e FUNKWHALE_HOSTNAME=funkwhale.luvcie.love " +
        "-e FUNKWHALE_PROTOCOL=https " +
        "-e NESTED_PROXY=1 " +
        "-e PUID=1000 " +
        "-e PGID=1000 " +
        "docker.io/funkwhale/all-in-one:1.2.10";
      ExecStop = "${pkgs.podman}/bin/podman stop funkwhale";
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };
}
