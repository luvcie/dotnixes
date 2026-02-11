{
  pkgs,
  lib,
  config,
  ...
}: let
  xorgConf = pkgs.writeText "xorg-sunshine.conf" ''
    Section "ServerLayout"
        Identifier "layout"
        Screen 0 "screen0"
    EndSection

    Section "Files"
        ModulePath "${pkgs.xorg.xorgserver}/lib/xorg/modules"
        ModulePath "${pkgs.xorg.xorgserver}/lib/xorg/modules/drivers"
        ModulePath "${pkgs.xorg.xorgserver}/lib/xorg/modules/extensions"
        ModulePath "/usr/lib/xorg/modules"
        ModulePath "/usr/lib/xorg/modules/drivers"
    EndSection

    Section "Device"
        Identifier "nvidia"
        Driver "nvidia"
    EndSection

    Section "Screen"
        Identifier "screen0"
        Device "nvidia"
        Option "AllowEmptyInitialConfiguration" "true"
        DefaultDepth 24
        SubSection "Display"
            Depth 24
            Modes "1920x1080"
        EndSubSection
    EndSection
  '';

  # stable path for the sudoers NOPASSWD entry
  xorgWrapper = pkgs.writeShellScript "xorg-sunshine" ''
    exec ${pkgs.xorg.xorgserver}/bin/Xorg :2 \
      -config ${xorgConf} \
      -noreset +extension GLX
  '';
in {
  home.packages = with pkgs; [
    sunshine
    xorg.xhost
  ];

  # symlink wrapper to a stable path so sudoers entry survives rebuilds
  home.file.".local/bin/xorg-sunshine".source = xorgWrapper;

  systemd.user.services.sunshine = {
    Unit = {
      Description = "sunshine game streaming with nvidia xorg";
      After = ["network.target"];
    };

    Service = {
      Type = "simple";
      ExecStartPre = [
        "-/usr/bin/sudo /usr/bin/pkill -f 'Xorg.*:2'"
        "-/usr/bin/pkill -u ${config.home.username} -f sunshine"
        "-/usr/bin/sudo /usr/bin/rm -f /tmp/.X2-lock /tmp/.X11-unix/X2"
      ];

      ExecStart = pkgs.writeShellScript "start-sunshine" ''
        export DISPLAY=:2

        # start xorg as root (requires sudoers NOPASSWD entry)
        sudo ${config.home.homeDirectory}/.local/bin/xorg-sunshine &

        # wait for xorg
        until ${pkgs.xorg.xdpyinfo}/bin/xdpyinfo -display :2 >/dev/null 2>&1; do
          sleep 1
        done

        # allow local user connections to the root-owned X server
        ${pkgs.xorg.xhost}/bin/xhost +local:

        # start sunshine capturing display :2
        exec ${pkgs.sunshine}/bin/sunshine
      '';

      Restart = "always";
      RestartSec = 10;
    };

    Install = {
      WantedBy = ["default.target"];
    };
  };
}
