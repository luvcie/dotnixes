{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.programs.retroism;
in {
  options.programs.retroism = {
    enable = lib.mkEnableOption "Linux Retroism theme and configuration";

    configPath = lib.mkOption {
      type = lib.types.str;
      default = "${config.xdg.configHome}/retroism";
      description = "Path where retroism config files will be stored";
    };
  };

  config = lib.mkIf cfg.enable {
    home.file = {
      # Copy entire retroism repository to config directory
      "${cfg.configPath}" = {
        source = inputs.linux-retroism;
        recursive = true;
      };

      # Copy GTK theme to themes directory
      ".local/share/themes/ClassicPlatinumStreamlined" = {
        source = "${inputs.linux-retroism}/gtk_theme/ClassicPlatinumStreamlined";
        recursive = true;
      };

      # Copy icon theme to icons directory
      ".local/share/icons/RetroismIcons" = {
        source = "${inputs.linux-retroism}/icon_theme/RetroismIcons";
        recursive = true;
      };

      # Copy quickshell configs to the correct location
      ".config/quickshell" = {
        source = "${inputs.linux-retroism}/configs/quickshell";
        recursive = true;
      };
    };

    # Install required dependencies mentioned in the retroism repository
    home.packages = with pkgs; [
      # Core applications mentioned in retroism README
      nemo
      kitty
      nwg-look
      quickshell

      # Screenshot utilities
      grim
      slurp
      swappy

      # Additional utilities
      hyprshot
    ];

    # GTK theme configuration (commented out to avoid conflicts)
    # You can manually switch to retroism themes using nwg-look
    # gtk = {
    #   enable = true;
    #   theme = {
    #     name = "ClassicPlatinumStreamlined";
    #   };
    #   iconTheme = {
    #     name = "RetroismIcons";
    #   };
    # };
  };
}
