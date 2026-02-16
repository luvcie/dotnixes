{
  pkgs,
  lib,
  config,
  ...
}: let
  couchdbDir = "${config.home.homeDirectory}/couchdb";
in {
  sops.templates."livesync.ini" = {
    mode = "0444";
    content = ''
      [couchdb]
      single_node = true

      [admins]
      ${config.sops.placeholder.couchdb_username} = ${config.sops.placeholder.couchdb_password}
      [chttpd]
      enable_cors = true
      require_valid_user = true
      max_http_request_size = 4294967296

      [chttpd_auth]
      require_valid_user = true

      [httpd]
      enable_cors = true
      WWW-Authenticate = Basic realm="couchdb"

      [cors]
      origins = app://obsidian.md,capacitor://localhost,http://localhost
      credentials = true
      headers = accept, authorization, content-type, origin, referer
      methods = GET, PUT, POST, HEAD, DELETE
      max_age = 3600
    '';
  };

  systemd.user.services.couchdb = {
    Unit = {
      Description = "couchdb podman container for obsidian livesync";
      After = ["network.target" "sops-nix.service"];
    };
    Service = {
      Restart = "always";
      ExecStartPre = [
        "${pkgs.coreutils}/bin/mkdir -p ${couchdbDir}/data"
        "-${pkgs.podman}/bin/podman stop couchdb"
        "-${pkgs.podman}/bin/podman rm couchdb"
      ];
      ExecStart = "${pkgs.podman}/bin/podman run --name couchdb -p 127.0.0.1:5984:5984 " +
        "-v ${couchdbDir}/data:/opt/couchdb/data:Z " +
        "-v ${config.sops.templates."livesync.ini".path}:/opt/couchdb/etc/local.d/livesync.ini " +
        "docker.io/library/couchdb:3";
      ExecStop = "${pkgs.podman}/bin/podman stop couchdb";
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };
}
