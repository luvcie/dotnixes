{ pkgs, config, ... }: {

      config.wayland.windowManager.river.enable = true;
      config.home.packages = [ pkgs.rivercarro ];
    
      config.xdg.configFile."river" = {
        source = ./river;
        executable = true;
        recursive = true;
      };
    
      # XDG Desktop Portal for PipeWire screensharing etc.
      config.xdg.portal = {
        enable = true;
        config.river.default = [ "wlr" ];
        extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
      };
    }
