{
  pkgs,
  lib,
  config,
  ...
}: let
  websiteDir = "${config.home.homeDirectory}/Development/luvcie-website";
in {
  # systemd service for the portfolio website
  systemd.user.services.website = {
    Unit = {
      Description = "luvcie portfolio website (astro preview)";
      After = ["network.target"];
    };
    Service = {
      WorkingDirectory = websiteDir;
      # dev mode is less strict and worked before
      ExecStart = "${pkgs.nodejs_24}/bin/npx astro dev --port 4321 --host 127.0.0.1";
      Restart = "always";
      RestartSec = 5;
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };
}
