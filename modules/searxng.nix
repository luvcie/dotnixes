{
  pkgs,
  lib,
  config,
  ...
}: let
  searxngDir = "${config.home.homeDirectory}/searxng";
in {
  # searxng config via sops template for secret key
  sops.templates."searxng-settings.yml" = {
    path = "${searxngDir}/settings.yml";
    content = ''
      use_default_settings: true
      server:
        port: 8080
        bind_address: "0.0.0.0"
        secret_key: "${config.sops.placeholder.searxng_secret_key}"
        base_url: https://searxng.luvcie.love
        image_proxy: true
      ui:
        static_use_hash: true
        theme: simple
      search:
        safe_search: 0
        autocomplete: google
        on_vacuum: 1
    '';
  };

  # searxng systemd service
  systemd.user.services.searxng = {
    Unit = {
      Description = "searxng metasearch engine podman container";
      After = ["network.target" "sops-nix.service"];
    };
    Service = {
      Restart = "always";
      ExecStartPre = [
        "${pkgs.coreutils}/bin/mkdir -p ${searxngDir}"
        "-${pkgs.podman}/bin/podman stop searxng"
        "-${pkgs.podman}/bin/podman rm searxng"
      ];
      # slirp4netns handles rootless networking
      ExecStart = "${pkgs.podman}/bin/podman run --name searxng " +
        "-p 8889:8080 " +
        "-v ${config.xdg.configHome}/sops-nix/secrets/rendered/searxng-settings.yml:/etc/searxng/settings.yml:ro " +
        "-e SEARXNG_SETTINGS_PATH=/etc/searxng/settings.yml " +
        "docker.io/searxng/searxng:latest";
      ExecStop = "${pkgs.podman}/bin/podman stop searxng";
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };
}
