{
  pkgs,
  lib,
  config,
  ...
}: let
  bridgeDir = "${config.home.homeDirectory}/Development/luvcie-website/shell-bridge";
  podmanPath = "${config.home.homeDirectory}/.nix-profile/bin/podman";

  terminalImage = pkgs.dockerTools.buildImage {
    name = "luvcie-lab";
    tag = "latest";
    copyToRoot = pkgs.buildEnv {
      name = "luvcie-lab-env";
      paths = with pkgs; [
      busybox
      bash
      fastfetch
      neofetch
      figlet
      cowsay
      lolcat
      cmatrix
      cbonsai
      asciiquarium
      vitetris
      solitaire-tui
      tree
      file
      nano
      vim
      helix
      pfetch-rs
      cpufetch
      ];
      pathsToLink = ["/bin" "/etc" "/share"];
    };
    config = {
      Cmd = ["/bin/sh"];
      WorkingDir = "/root";
    };
  };
in {
  # systemd service for the websocket terminal bridge
  systemd.user.services.shell-bridge = {
    Unit = {
      Description = "terminal websocket bridge";
      After = ["network.target"];
    };
    Service = {
      WorkingDirectory = bridgeDir;
      ExecStartPre = "${podmanPath} load -i ${terminalImage}";
      ExecStart = "${pkgs.nodejs_24}/bin/node ${bridgeDir}/server.js";
      Restart = "always";
      RestartSec = 5;
      TimeoutStartSec = 300;
      Environment = [
        "TERMINAL_IMAGE=localhost/luvcie-lab:latest"
        "SUPPRESS_BOLTDB_WARNING=true"
      ];
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };
}
