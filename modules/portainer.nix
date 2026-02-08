{
  pkgs,
  lib,
  config,
  ...
}: let
  portainerDir = "${config.home.homeDirectory}/portainer";
in {
  home.packages = with pkgs; [ podman ];

  # manage the podman socket declaratively since we're using nix podman
  systemd.user.sockets.podman = {
    Unit = {
      Description = "podman api socket";
    };
    Socket = {
      ListenStream = "%t/podman/podman.sock";
      SocketMode = "0660";
    };
    Install = {
      WantedBy = ["sockets.target"];
    };
  };

  systemd.user.services.podman = {
    Unit = {
      Description = "podman api service";
      Requires = ["podman.socket"];
      After = ["podman.socket"];
    };
    Service = {
      Type = "exec";
      ExecStart = "${pkgs.podman}/bin/podman system service";
    };
  };

  # systemd service for portainer
  systemd.user.services.portainer = {
    Unit = {
      Description = "portainer container management web ui";
      After = ["network.target" "podman.socket"];
      Requires = ["podman.socket"];
    };
    Service = {
      Restart = "always";
      ExecStartPre = [
        "-${pkgs.podman}/bin/podman stop portainer"
        "-${pkgs.podman}/bin/podman rm portainer"
      ];
      ExecStart = "${pkgs.podman}/bin/podman run --name portainer -p 9000:9000 -p 9443:9443 " +
        "-v /run/user/1000/podman/podman.sock:/var/run/docker.sock:Z " +
        "-v ${portainerDir}/data:/data:Z " +
        "docker.io/portainer/portainer-ce:latest";
      ExecStop = "${pkgs.podman}/bin/podman stop portainer";
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };
}