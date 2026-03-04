{
  pkgs,
  lib,
  config,
  ...
}: let
  grafanaDir = "${config.home.homeDirectory}/grafana";
in {
  # datasource provisioning — wired to prometheus and loki on the host
  home.file."${grafanaDir}/provisioning/datasources/datasources.yml".text = ''
    apiVersion: 1
    datasources:
      - name: Prometheus
        type: prometheus
        access: proxy
        url: http://host.containers.internal:9090
        isDefault: true
        editable: true
      - name: Loki
        type: loki
        access: proxy
        url: http://host.containers.internal:3100
        editable: true
  '';

  # grafana admin password via sops
  sops.templates."grafana-env" = {
    path = "${grafanaDir}/grafana.env";
    content = ''
      GF_SECURITY_ADMIN_PASSWORD=${config.sops.placeholder.grafana_admin_password}
    '';
  };

  # grafana systemd service
  systemd.user.services.grafana = {
    Unit = {
      Description = "grafana dashboard podman container";
      After = ["network.target" "sops-nix.service" "prometheus.service" "loki.service"];
    };
    Service = {
      Restart = "always";
      ExecStartPre = [
        "${pkgs.coreutils}/bin/mkdir -p ${grafanaDir}/data"
        "${pkgs.coreutils}/bin/mkdir -p ${grafanaDir}/provisioning/datasources"
        "-${pkgs.podman}/bin/podman stop grafana"
        "-${pkgs.podman}/bin/podman rm grafana"
      ];
      # port 3200 since homepage already sits on 3000
      ExecStart = "${pkgs.podman}/bin/podman run --name grafana " +
        "-p 3200:3000 " +
        "--add-host host.containers.internal:host-gateway " +
        "--env-file ${config.xdg.configHome}/sops-nix/secrets/rendered/grafana-env " +
        "-v ${grafanaDir}/data:/var/lib/grafana:Z " +
        "-v /nix/store:/nix/store:ro " +
        "-v ${grafanaDir}/provisioning:/etc/grafana/provisioning:ro " +
        "-e GF_USERS_ALLOW_SIGN_UP=false " +
        "--user 0:0 " +
        "docker.io/grafana/grafana:latest";
      ExecStop = "${pkgs.podman}/bin/podman stop grafana";
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };
}
