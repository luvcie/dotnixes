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
      dockerTools.fakeNss
      ];
      pathsToLink = ["/bin" "/etc" "/share"];
    };
    config = {
      Cmd = ["/bin/sh"];
      WorkingDir = "/";
      Env = [
        "TERMINFO=/share/terminfo"
        "HOME=/root"
      ];
    };
  };
  marker = "${config.home.homeDirectory}/.local/share/containers/luvcie-lab-loaded";
in {
  # load container image during home-manager activation (before service restart)
  home.activation.loadTerminalImage = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p "$(dirname "${marker}")"
    if [ ! -f "${marker}" ] || [ "$(cat "${marker}")" != "${terminalImage}" ]; then
      echo "loading luvcie-lab container image..."
      ${podmanPath} load -i ${terminalImage}
      echo "${terminalImage}" > "${marker}"
    else
      echo "luvcie-lab image unchanged, skipping load"
    fi
  '';

  # systemd service for the websocket terminal bridge
  systemd.user.services.shell-bridge = {
    Unit = {
      Description = "terminal websocket bridge";
      After = ["network.target"];
    };
    Service = {
      WorkingDirectory = bridgeDir;
      ExecStart = "${pkgs.nodejs_24}/bin/node ${bridgeDir}/server.js";
      ExecStopPost = pkgs.writeShellScript "cleanup-luvcie-lab" ''
        ${podmanPath} ps -q --filter ancestor=localhost/luvcie-lab:latest | xargs -r ${podmanPath} rm -f
      '';
      Restart = "always";
      RestartSec = 5;
      Environment = [
        "TERMINAL_IMAGE=localhost/luvcie-lab:latest"
        "SUPPRESS_BOLTDB_WARNING=true"
      ];
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };

  # periodic garbage collection for old nix generations
  systemd.user.services.nix-collect-garbage = {
    Unit.Description = "nix garbage collection";
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.nix}/bin/nix-collect-garbage --delete-older-than 7d";
    };
  };
  systemd.user.timers.nix-collect-garbage = {
    Unit.Description = "weekly nix garbage collection";
    Timer = {
      OnCalendar = "weekly";
      Persistent = true;
    };
    Install.WantedBy = ["timers.target"];
  };
}
