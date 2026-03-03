{
  pkgs,
  lib,
  config,
  ...
}: let
  nopasteDir = "${config.home.homeDirectory}/nopaste";
  # fetch the real source from github to get the "fancy" version
  nopasteSrc = pkgs.fetchFromGitHub {
    owner = "bokub";
    repo = "nopaste";
    rev = "master";
    sha256 = "sha256-raDDWoIsie1rZRDWJDYt9pWUsvMK/ikX7F0wQpqhU+M=";
  };
in {
  # nopaste systemd service
  systemd.user.services.nopaste = {
    Unit = {
      Description = "nopaste client-side pastebin caddy container";
      After = ["network.target"];
    };
    Service = {
      Restart = "always";
      ExecStartPre = [
        "-${pkgs.podman}/bin/podman stop nopaste"
        "-${pkgs.podman}/bin/podman rm nopaste"
      ];
      # we serve the fetched source directly via caddy
      ExecStart = "${pkgs.podman}/bin/podman run --name nopaste " +
        "-p 8081:80 " +
        "-v /nix/store:/nix/store:ro " +
        "-v ${nopasteSrc}:/usr/share/caddy:ro " +
        "docker.io/library/caddy:alpine " +
        "caddy file-server --root /usr/share/caddy --listen :80";
      ExecStop = "${pkgs.podman}/bin/podman stop nopaste";
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };
}
