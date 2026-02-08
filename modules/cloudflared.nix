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
        service: http://localhost:3923
      - hostname: files.luvcie.love
        service: http://localhost:3923
      - hostname: containers.luvcie.love
        service: http://localhost:9000
      - hostname: home.luvcie.love
        service: http://localhost:3000
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
