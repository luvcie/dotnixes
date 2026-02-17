{
  pkgs,
  config,
  ...
}: let
  obsidianDir = "${config.home.homeDirectory}/obsidian";
in {
  systemd.user.services.obsidian = {
    Unit = {
      Description = "obsidian web app via linuxserver/obsidian (KasmVNC)";
      After = ["network.target"];
    };
    Service = {
      Restart = "always";
      ExecStartPre = [
        "${pkgs.coreutils}/bin/mkdir -p ${obsidianDir}/config"
        "-${pkgs.podman}/bin/podman stop obsidian"
        "-${pkgs.podman}/bin/podman rm obsidian"
      ];
      ExecStart = "${pkgs.podman}/bin/podman run --name obsidian --shm-size=1gb " +
        "-p 127.0.0.1:3050:3000 " +
        "-e PUID=1000 -e PGID=1000 -e TZ=Europe/Paris " +
        "-v ${obsidianDir}/config:/config:Z " +
        "lscr.io/linuxserver/obsidian:latest";
      ExecStop = "${pkgs.podman}/bin/podman stop obsidian";
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };
}
