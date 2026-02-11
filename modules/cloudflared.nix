{
  pkgs,
  lib,
  config,
  ...
}: {
  home.packages = [ pkgs.cloudflared ];

  # declarative tunnel config
  home.file.".cloudflared/config.nix.yml".text = ''
    tunnel: 9c49999e-2bd1-4c88-98c8-d95200454f08
    credentials-file: /home/weew/.cloudflared/9c49999e-2bd1-4c88-98c8-d95200454f08.json

    ingress:
      - hostname: godsfavouriteprincess.luvcie.love
        service: http://127.0.0.1:3923
      - hostname: files.luvcie.love
        service: http://127.0.0.1:3923
      - hostname: term.luvcie.love
        service: http://127.0.0.1:3001
      - hostname: test.luvcie.love
        service: http://127.0.0.1:4321
      - hostname: home.luvcie.love
        service: http://127.0.0.1:3000
      - hostname: plex.luvcie.love
        service: http://127.0.0.1:32400
      - hostname: music.luvcie.love
        service: http://127.0.0.1:4533
      - service: http_status:404
  '';

  # cloudflare tunnel service
  systemd.user.services.cloudflared = {
    Unit = {
      Description = "cloudflare tunnel for luvcie lab";
      After = ["network.target"];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --config ${config.home.homeDirectory}/.cloudflared/config.nix.yml run copyparty-tunnel";
      Restart = "always";
      RestartSec = "5";
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };
}
