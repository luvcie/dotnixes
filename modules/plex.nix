{
  pkgs,
  lib,
  config,
  ...
}: let
  plexDir = "${config.home.homeDirectory}/plex";
in {
  sops.templates."plex.env" = {
    path = "${plexDir}/plex.env";
    content = ''
      PUID=1000
      PGID=1000
      TZ=Europe/London
      PLEX_CLAIM=${config.sops.placeholder.plex_claim_token}
    '';
  };

  systemd.user.services.plex = {
    Unit = {
      Description = "plex media server podman container";
      After = ["network.target" "sops-nix.service"];
    };
    Service = {
      Restart = "always";
      ExecStartPre = [
        "-${pkgs.podman}/bin/podman stop plex"
        "-${pkgs.podman}/bin/podman rm plex"
      ];
      ExecStart = "${pkgs.podman}/bin/podman run --name plex -p 32400:32400 " +
        "--env-file ${config.xdg.configHome}/sops-nix/secrets/rendered/plex.env " +
        "-v ${plexDir}/config:/config:Z " +
        "-v /mnt/media:/data:ro " +
        "docker.io/linuxserver/plex:latest";
      ExecStop = "${pkgs.podman}/bin/podman stop plex";
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };
}
