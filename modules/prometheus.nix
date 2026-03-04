{
  pkgs,
  lib,
  config,
  ...
}: let
  prometheusDir = "${config.home.homeDirectory}/prometheus";
in {
  # prometheus scrape config
  home.file."${prometheusDir}/prometheus.yml".text = ''
    global:
      scrape_interval: 15s
      evaluation_interval: 15s

    scrape_configs:
      - job_name: "prometheus"
        static_configs:
          - targets: ["localhost:9090"]
  '';

  # prometheus systemd service
  systemd.user.services.prometheus = {
    Unit = {
      Description = "prometheus metrics server podman container";
      After = ["network.target"];
    };
    Service = {
      Restart = "always";
      ExecStartPre = [
        "${pkgs.coreutils}/bin/mkdir -p ${prometheusDir}/data"
        "-${pkgs.podman}/bin/podman stop prometheus"
        "-${pkgs.podman}/bin/podman rm prometheus"
      ];
      # run as root inside container for volume permissions
      ExecStart = "${pkgs.podman}/bin/podman run --name prometheus " +
        "-p 9090:9090 " +
        "--add-host host.containers.internal:host-gateway " +
        "-v ${prometheusDir}/prometheus.yml:/etc/prometheus/prometheus.yml:ro " +
        "-v ${prometheusDir}/data:/prometheus:Z " +
        "--user 0:0 " +
        "docker.io/prom/prometheus:latest " +
        "--config.file=/etc/prometheus/prometheus.yml " +
        "--storage.tsdb.path=/prometheus " +
        "--storage.tsdb.retention.time=30d " +
        "--web.enable-remote-write-receiver";
      ExecStop = "${pkgs.podman}/bin/podman stop prometheus";
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };
}
