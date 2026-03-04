{
  pkgs,
  lib,
  config,
  ...
}: let
  alloyDir = "${config.home.homeDirectory}/alloy";
in {
  home.packages = [ pkgs.grafana-alloy ];

  # alloy config — collects host metrics + journal logs, ships to prometheus + loki
  home.file."${alloyDir}/config.alloy".text = ''
    // host metrics via built-in node exporter
    prometheus.exporter.unix "host" {
      disable_collectors = ["ipvs", "btrfs", "infiniband", "xfs", "zfs"]
    }

    // scrape our own unix exporter
    prometheus.scrape "host" {
      scrape_interval = "15s"
      targets    = prometheus.exporter.unix.host.targets
      forward_to = [prometheus.remote_write.local.receiver]
    }

    // push metrics to prometheus
    prometheus.remote_write "local" {
      endpoint {
        url = "http://127.0.0.1:9090/api/v1/write"
      }
    }

    // collect systemd journal logs
    loki.source.journal "host" {
      max_age       = "12h"
      relabel_rules = loki.relabel.journal.rules
      forward_to    = [loki.write.local.receiver]
    }

    // extract useful labels from journal entries
    loki.relabel "journal" {
      forward_to = []

      rule {
        source_labels = ["__journal__systemd_unit"]
        target_label  = "unit"
      }
      rule {
        source_labels = ["__journal__hostname"]
        target_label  = "hostname"
      }
      rule {
        source_labels = ["__journal_syslog_identifier"]
        target_label  = "syslog_identifier"
      }
      rule {
        source_labels = ["__journal_priority_keyword"]
        target_label  = "level"
      }
    }

    // push logs to loki
    loki.write "local" {
      endpoint {
        url = "http://127.0.0.1:3100/loki/api/v1/push"
      }
    }
  '';

  # alloy runs natively — full access to journal, /proc, /sys, everything
  systemd.user.services.alloy = {
    Unit = {
      Description = "grafana alloy telemetry collector";
      After = ["network.target" "prometheus.service" "loki.service"];
    };
    Service = {
      Restart = "always";
      ExecStart = "${pkgs.grafana-alloy}/bin/alloy run ${alloyDir}/config.alloy --storage.path=${alloyDir}/data";
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };
}
