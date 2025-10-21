{inputs, pkgs, lib, config, ... }:
{
  imports = [
    inputs.caelestia-shell.homeManagerModules.default
  ];

  programs.caelestia = {
    enable = true;
    systemd = {
      enable = true;
      target = "graphical-session.target";
      environment = [];
    };
    settings = {
      paths.wallpaperDir = "~/Wallpapers/";
      services.weatherLocation = "Paris";
	  services.useFahrenheit = false;
      workspaces.showWindows = false;
      workspaces.shown = 10;
      
      bar = {
        clock.showIcon = false;
        workspaces.showWindows = false;
        workspaces.shown = 5;
        status.showAudio = true;
        status.showBattery = true;
        # status.showMicrophone = true;
        status.showLockStatus = true;
        status.showBluetooth = true;
        tray.recolour = false;

        dragThreshold = 20;
        entries = [
          {
            id = "logo";
            enabled = true;
          }
          {
            id = "workspaces";
            enabled = true;
          }
          {
            id = "spacer";
            enabled = true;
          }
          {
            id = "spacer";
            enabled = true;
          }
          {
            id = "spacer";
            enabled = true;
          }
          {
            id = "tray";
            enabled = true;
          }
          {
            id = "clock";
            enabled = true;
          }
          {
            id = "statusIcons";
            enabled = true;
          }
          {
            id = "power";
            enabled = true;
          }
        ];
      };
    };
    cli = {
      enable = true;
      settings = {
        theme.enableTerm = true;
#       theme.enableHypr = true;
        theme.enableSpicetirfy = true;
        theme.enableGtk = true;
        theme.enableQt = true;
      };
    };
  };
  
}
