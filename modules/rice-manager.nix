{ config, pkgs, lib, ... }:
let
  cfg = config.programs.riceManager;
in {
  options.programs.riceManager = {
    enable = lib.mkEnableOption "Rice manager for switching between different desktop rices";

    currentRice = lib.mkOption {
      type = lib.types.enum [ "retroism" "caelestia" "none" ];
      default = "none";
      description = ''
        Select which rice configuration to use.
        Options: "retroism", "caelestia", "none"

        Change this value and rebuild to switch your default rice.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # Create rice-switch command for on-the-fly switching
    home.packages = [
      (pkgs.writeShellScriptBin "rice-switch" ''
        RICE="$1"

        if [ -z "$RICE" ]; then
          echo "╔════════════════════════════════════╗"
          echo "║       Rice Manager v1.0            ║"
          echo "╚════════════════════════════════════╝"
          echo ""
          echo "Current default rice: ${cfg.currentRice}"
          echo ""
          echo "Usage: rice-switch [retroism|caelestia|stop]"
          echo ""
          echo "  retroism   - Switch to retroism rice (90s aesthetic)"
          echo "  caelestia  - Switch to caelestia rice"
          echo "  stop       - Stop all rices"
          echo ""
          echo "To change default rice, edit home.nix:"
          echo "  programs.riceManager.currentRice = \"retroism\";"
          exit 0
        fi

        case "$RICE" in
          retroism)
            echo "→ Switching to retroism rice..."
            pkill -9 quickshell 2>/dev/null || true
            systemctl --user stop caelestia-shell.service 2>/dev/null || true
            sleep 0.5
            quickshell --config ~/.config/retroism/configs/quickshell/shell.qml &
            echo "✓ Retroism rice activated!"
            ;;
          caelestia)
            echo "→ Switching to caelestia rice..."
            pkill -9 quickshell 2>/dev/null || true
            sleep 0.5
            systemctl --user restart caelestia-shell.service
            echo "✓ Caelestia rice activated!"
            ;;
          stop)
            echo "→ Stopping all rices..."
            pkill -9 quickshell 2>/dev/null || true
            systemctl --user stop caelestia-shell.service 2>/dev/null || true
            echo "✓ All rices stopped"
            ;;
          *)
            echo "✗ Unknown rice: $RICE"
            echo "Available options: retroism, caelestia, stop"
            exit 1
            ;;
        esac
      '')
    ];

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
