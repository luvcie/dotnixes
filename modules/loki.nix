{
  pkgs,
  lib,
  config,
  ...
}: let
  lokiDir = "${config.home.homeDirectory}/loki";
in {
  # loki config — filesystem storage, single-node setup
  home.file."${lokiDir}/loki-config.yml".text = ''
    auth_enabled: false

    server:
      http_listen_port: 3100

    common:
      path_prefix: /loki
      storage:
        filesystem:
          chunks_directory: /loki/chunks
          rules_directory: /loki/rules
      replication_factor: 1
      ring:
        kvstore:
          store: inmemory

    schema_config:
      configs:
        - from: "2020-10-24"
          store: tsdb
          object_store: filesystem
          schema: v13
          index:
            prefix: index_
            period: 24h

    limits_config:
      retention_period: 30d

    compactor:
      working_directory: /loki/compactor
      retention_enabled: true
      delete_request_store: filesystem
  '';

  # loki systemd service
  systemd.user.services.loki = {
    Unit = {
      Description = "loki log aggregation podman container";
      After = ["network.target"];
    };
    Service = {
      Restart = "always";
      ExecStartPre = [
        "${pkgs.coreutils}/bin/mkdir -p ${lokiDir}/data"
        "-${pkgs.podman}/bin/podman stop loki"
        "-${pkgs.podman}/bin/podman rm loki"
      ];
      ExecStart = "${pkgs.podman}/bin/podman run --name loki " +
        "-p 3100:3100 " +
        "-v ${lokiDir}/loki-config.yml:/etc/loki/local-config.yaml:ro " +
        "-v ${lokiDir}/data:/loki:Z " +
        "--user 0:0 " +
        "docker.io/grafana/loki:latest " +
        "-config.file=/etc/loki/local-config.yaml";
      ExecStop = "${pkgs.podman}/bin/podman stop loki";
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };
}
