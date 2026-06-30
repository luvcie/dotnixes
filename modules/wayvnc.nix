{
  pkgs,
  config,
  lib,
  ...
}: {
  home.packages = [pkgs.wayvnc];

  # This service mirrors your current Wayland (Sway) session.
  # It will only start when sway is active.
  systemd.user.services.wayvnc = {
    Unit = {
      Description = "Wayland VNC server (mirroring)";
      After = ["cosmic-session.target"];
      PartOf = ["cosmic-session.target"];
    };
    Service = {
      # Listens on all interfaces on port 5900.
      # Tip: Connect using your Tailscale IP for a secure connection.
      ExecStart = "${pkgs.wayvnc}/bin/wayvnc 0.0.0.0";
      Restart = "on-failure";
      RestartSec = "5s";
    };
    Install = {
      WantedBy = ["cosmic-session.target"];
    };
  };
}
