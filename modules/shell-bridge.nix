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
      bunnyfetch
      figlet
      cowsay
      lolcat
      cmatrix
      cbonsai
      asciiquarium
      vitetris
      solitaire-tui
      tree
      yazi
      nbsdgames
      bsdgames
      file
      nano
      vim
      emacs
      helix
      pfetch-rs
      cpufetch
      ncurses
      ];
      pathsToLink = ["/bin" "/etc" "/share"];
    };
    config = {
      Cmd = ["/bin/sh"];
      WorkingDir = "/";
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
      ExecStartPre = pkgs.writeShellScript "load-luvcie-lab" ''
        marker="$HOME/.local/share/containers/luvcie-lab-loaded"
        if [ ! -f "$marker" ] || [ "$(cat "$marker")" != "${terminalImage}" ]; then
          ${podmanPath} load -i ${terminalImage}
          echo "${terminalImage}" > "$marker"
        fi
      '';
      ExecStart = "${pkgs.nodejs_24}/bin/node ${bridgeDir}/server.js";
      ExecStopPost = "${podmanPath} rm -f -a";
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
