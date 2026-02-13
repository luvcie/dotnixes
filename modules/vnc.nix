{
  pkgs,
  lib,
  config,
  ...
}: {
  home.packages = with pkgs; [
    xorg-server
    xdpyinfo
    openbox
    x11vnc
    dbus
  ];

  systemd.user.services.vnc-server = {
    Unit = {
      Description = "vnc server with openbox (nix-managed)";
      After = ["network.target"];
    };

    Service = {
      Type = "simple";
      # clean everything: old locks AND any process squatting on 5900
      ExecStartPre = [
        "-/usr/bin/pkill -u ${config.home.username} -f Xvfb"
        "-/usr/bin/pkill -u ${config.home.username} -f x11vnc"
        "-/usr/bin/pkill -u ${config.home.username} -f openbox"
        "-/usr/bin/rm -f /tmp/.X1-lock /tmp/.X11-unix/X1"
      ];
      
      ExecStart = pkgs.writeShellScript "start-vnc" ''
        export DISPLAY=:1
        export XAUTHORITY=${config.home.homeDirectory}/.Xauthority
        
        # 1. start xvfb
        ${pkgs.xorg-server}/bin/Xvfb :1 -screen 0 1280x800x24 &
        
        # wait for xvfb
        until ${pkgs.xdpyinfo}/bin/xdpyinfo -display :1 >/dev/null 2>&1; do
          sleep 1
        done
        
        # 2. start openbox directly
        DISPLAY=:1 ${pkgs.openbox}/bin/openbox &
        
        # 3. start x11vnc (blocking)
        # -shared and -forever keep it alive across connects
        exec ${pkgs.x11vnc}/bin/x11vnc -display :1 -rfbauth ${config.home.homeDirectory}/.vnc/passwd -localhost -rfbport 5900 -forever -shared -loop
      '';

      Restart = "always";
      RestartSec = 10;
    };

    Install = {
      WantedBy = ["default.target"];
    };
  };
}