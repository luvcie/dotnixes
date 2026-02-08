{
  pkgs,
  lib,
  config,
  ...
}: let
  bridgeDir = "${config.home.homeDirectory}/Development/shell-bridge";
in {
  # systemd service for the websocket terminal bridge
  systemd.user.services.shell-bridge = {
    Unit = {
      Description = "terminal websocket bridge";
      After = ["network.target"];
    };
    Service = {
      WorkingDirectory = bridgeDir;
      ExecStart = "${pkgs.nodejs_24}/bin/node ${bridgeDir}/server.js";
      Restart = "always";
      RestartSec = 5;
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };
}
