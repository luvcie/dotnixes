{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.programs.riceManager;
in {
  options.programs.riceManager = {
    enable = lib.mkEnableOption "Rice manager for switching between different desktop rices";

    currentRice = lib.mkOption {
      type = lib.types.enum ["retroism" "caelestia" "none"];
      default = "none";
      description = ''
        Select which rice configuration to use.
        Options: "retroism", "caelestia", "none"

        To switch rices:
        1. Edit this value in home.nix
        2. Run: nh home switch .
        3. Reload Sway (Mod+Shift+C)
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # Auto-start the selected rice on Sway startup
    wayland.windowManager.sway.config.startup = lib.mkIf (cfg.currentRice != "none") [
      {
        command =
          if cfg.currentRice == "retroism"
          then "quickshell"
          else if cfg.currentRice == "caelestia"
          then "systemctl --user start caelestia-shell.service"
          else "";
      }
    ];
  };
}
