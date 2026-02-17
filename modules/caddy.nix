{
  pkgs,
  config,
  ...
}: let
  caddyDir = "${config.home.homeDirectory}/caddy";
  certsDir = "${config.home.homeDirectory}/.tailscale-certs";
in {
  home.file."${caddyDir}/Caddyfile".text = ''
    {
        auto_https off
    }

    :5443 {
        tls /etc/caddy/certs/cert.pem /etc/caddy/certs/key.pem
        reverse_proxy localhost:5984
    }

    :5444 {
        tls /etc/caddy/certs/cert.pem /etc/caddy/certs/key.pem
        reverse_proxy localhost:3050
    }
  '';

  systemd.user.services.caddy = {
    Unit = {
      Description = "caddy reverse proxy for TLS termination";
      After = ["network.target" "couchdb.service" "obsidian.service"];
    };
    Service = {
      Restart = "always";
      ExecStartPre = [
        "${pkgs.coreutils}/bin/mkdir -p ${caddyDir}/data"
        "-${pkgs.podman}/bin/podman stop caddy"
        "-${pkgs.podman}/bin/podman rm caddy"
      ];
      ExecStart = "${pkgs.podman}/bin/podman run --name caddy --network=host " +
        "-v ${caddyDir}/Caddyfile:/etc/caddy/Caddyfile:ro " +
        "-v ${certsDir}:/etc/caddy/certs:ro " +
        "-v ${caddyDir}/data:/data:Z " +
        "docker.io/library/caddy:2";
      ExecStop = "${pkgs.podman}/bin/podman stop caddy";
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };
}
