{
  pkgs,
  lib,
  config,
  ...
}: let
  i2pdDir = "${config.home.homeDirectory}/i2pd";
in {
  # systemd service for i2pd
  systemd.user.services.i2pd = {
    Unit = {
      Description = "i2pd daemon";
      After = ["network.target"];
    };
    Service = {
      Restart = "always";
      ExecStartPre = [
        "-${pkgs.podman}/bin/podman stop i2pd"
        "-${pkgs.podman}/bin/podman rm i2pd"
        # make sure directory exists with correct user permissions
        "${pkgs.coreutils}/bin/mkdir -p ${i2pdDir}"
      ];
      ExecStart = "${pkgs.podman}/bin/podman run --name i2pd " +
        "--network=host " +
        "-v ${i2pdDir}:/home/i2pd/data:Z " +
        "docker.io/purplei2p/i2pd:latest " +
        "--http.address=0.0.0.0 --http.strictheaders=false " +
        "--httpproxy.address=0.0.0.0 --socksproxy.address=0.0.0.0 " +
        "--sam.address=0.0.0.0 --port=31000 --ntcp2.port=31000 --ssu2.port=31000 " +
        "--nat " +
        "--bandwidth=L --share=30 " +
        "--ntcp2.published=true --ssu2.published=true " +
        "--i2pcontrol.enabled=true --i2pcontrol.address=127.0.0.1 --i2pcontrol.port=7650";
      ExecStop = "${pkgs.podman}/bin/podman stop i2pd";
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };
}
