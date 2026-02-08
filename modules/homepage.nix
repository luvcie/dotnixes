{
  pkgs,
  lib,
  config,
  ...
}: let
  homepageDir = "${config.home.homeDirectory}/homepage";
  configDir = "${homepageDir}/config";
in {
  # manage files individually to avoid ENOENT/directory collision errors
  home.file."${configDir}/settings.yaml".text = ''
    title: luvcie lab
    base: https://home.luvcie.love
    theme: dark
  '';

  home.file."${configDir}/services.yaml".text = ''
    - Services:
        - Copyparty:
            icon: copyparty.png
            href: https://files.luvcie.love
            description: file stash
        - Proxmox:
            icon: proxmox.png
            href: https://192.168.1.50:8006
            description: hypervisor
  '';

  home.file."${configDir}/bookmarks.yaml".text = ''
    - social:
        - github:
            - abbr: GH
              href: https://github.com/luvcie
  '';

  home.file."${configDir}/widgets.yaml".text = ''
    - datetime:
        format:
          dateStyle: long
          timeStyle: short
  '';

  home.file."${configDir}/docker.yaml".text = "[]";
  home.file."${configDir}/kubernetes.yaml".text = "[]";

  # systemd service for homepage
  systemd.user.services.homepage = {
    Unit = {
      Description = "homepage dashboard container";
      After = ["network.target"];
    };
    Service = {
      Restart = "always";
      ExecStartPre = [
        "-${pkgs.podman}/bin/podman stop homepage"
        "-${pkgs.podman}/bin/podman rm homepage"
      ];
      ExecStart = "${pkgs.podman}/bin/podman run --name homepage -p 3000:3000 " +
        "-v ${configDir}/settings.yaml:/app/config/settings.yaml:ro " +
        "-v ${configDir}/services.yaml:/app/config/services.yaml:ro " +
        "-v ${configDir}/bookmarks.yaml:/app/config/bookmarks.yaml:ro " +
        "-v ${configDir}/widgets.yaml:/app/config/widgets.yaml:ro " +
        "-v ${configDir}/docker.yaml:/app/config/docker.yaml:ro " +
        "-v ${configDir}/kubernetes.yaml:/app/config/kubernetes.yaml:ro " +
        "ghcr.io/benphelps/homepage:latest";
      ExecStop = "${pkgs.podman}/bin/podman stop homepage";
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };
}