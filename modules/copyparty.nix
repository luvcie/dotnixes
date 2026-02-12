{
  pkgs,
  lib,
  config,
  ...
}: let
  copypartyDir = "${config.home.homeDirectory}/copyparty";
  configDir = "${copypartyDir}/container_cfg";
in {
  home.packages = with pkgs; [
    podman
  ];

  # secrets template for the config file
  sops.templates."copyparty.conf" = {
    path = "${configDir}/copyparty.conf";
    content = ''
      [accounts]
        princess: ${config.sops.placeholder.copyparty_princess_password}
        guest: ${config.sops.placeholder.copyparty_guest_password}

      [/]
        ${copypartyDir}/share
        accs:
          A: princess

      [/guest]
        ${copypartyDir}/guest
        accs:
          r: guest
          A: princess

      [/music]
        /mnt/media/music
        accs:
          r: guest
          r: princess

      [/movies]
        /mnt/media/movies
        accs:
          r: guest
          r: princess

      [/tv]
        /mnt/media/tv
        accs:
          r: guest
          r: princess

      [/downloads]
        /mnt/media/downloads
        accs:
          A: princess

      [global]
        p: 3923
        e2dsa
        e2ts
        theme: 9
        xff-hdr: cf-connecting-ip
        xff-src: any
        rproxy: 1
        vague-403
        hist: ${copypartyDir}/.hist
    '';
  };

  # rootless podman service
  systemd.user.services.copyparty = {
    Unit = {
      Description = "copyparty podman container";
      After = ["network.target" "sops-nix.service"];
    };
    Service = {
      Restart = "always";
      ExecStartPre = [
        "-${pkgs.podman}/bin/podman stop copyparty"
        "-${pkgs.podman}/bin/podman rm copyparty"
      ];
      ExecStart = "${pkgs.podman}/bin/podman run --name copyparty -p 3923:3923 -v /nix/store:/nix/store:ro -v ${config.xdg.configHome}/sops-nix/secrets/rendered/copyparty.conf:/cfg/copyparty.conf:ro -v ${copypartyDir}:${copypartyDir}:Z -v /mnt/media/music:/mnt/media/music:ro -v /mnt/media/movies:/mnt/media/movies:ro -v /mnt/media/tv:/mnt/media/tv:ro -v /mnt/media/downloads:/mnt/media/downloads:ro docker.io/copyparty/ac";
      ExecStop = "${pkgs.podman}/bin/podman stop copyparty";
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };
}