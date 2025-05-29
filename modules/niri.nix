{ config, pkgs, lib, ... }:
let
  wallpaper = ../assets/wallpapers/wallpaper.png;
in {
  programs.niri = {
    settings = {
      input = {
        keyboard = {
          xkb = {
            layout = "us";
          };
          repeat-delay = 300;
          repeat-rate = 50;
        };
        
        touchpad = {
          tap = true;
          natural-scroll = false;
          accel-speed = 0.8;
          accel-profile = "adaptive";
          tap-button-map = "left-right-middle";
          scroll-method = "two-finger";
          dwt = true;
        };
        
        mouse = {
          accel-speed = 0.0;
          accel-profile = "flat";
        };
      };

      outputs."*" = {
        background-path = "${wallpaper}";
      };

      window-rules = [
        {
          matches = [{ app-id = "^chromium$"; }];
          default-column-width = { proportion = 0.5; };
        }
        {
          matches = [{ app-id = "^vesktop$"; }];
          open-on-workspace = "chat";
        }
        {
          matches = [{ app-id = "^firefox$"; }];
          default-column-width = { proportion = 0.75; };
        }
      ];

      workspaces = {
        "1" = {};
        "2" = {};
        "3" = {};
        "4" = {};
        "5" = {};
        "6" = {};
        "7" = {};
        "8" = {};
        "9" = {};
        "10" = {};
        "chat" = {};
      };

      layout = {
        gaps = 6;
        center-focused-column = "never";
        preset-column-widths = [
          { proportion = 0.33333; }
          { proportion = 0.5; }
          { proportion = 0.66667; }
        ];
        default-column-width = { proportion = 0.5; };
        focus-ring = {
          enable = true;
          width = 2;
          active.color = "#ffffff";
          inactive.color = "#505050";
        };
        border = {
          enable = true;
          width = 1;
          active.color = "#ffffff";
          inactive.color = "#505050";
        };
      };

      animations = {
        slowdown = 1.0;
        spring = {
          damping-ratio = 1.0;
          stiffness = 1000;
          epsilon = 0.001;
        };
        window-open = {
          duration-ms = 150;
          curve = "ease-out-expo";
        };
        window-close = {
          duration-ms = 150;
          curve = "ease-out-expo";
        };
        horizontal-view-movement = {
          duration-ms = 200;
          curve = "ease-out-expo";
        };
        workspace-switch = {
          duration-ms = 200;
          curve = "ease-out-expo";
        };
      };

      binds = {
        "Mod+Return".action.spawn = ["wezterm"];
        "Mod+d".action.spawn = ["wofi" "--show" "drun"];
        "Mod+Shift+Return".action.spawn = ["chromium"];

        "Mod+Shift+q".action.close-window = {};
        "Mod+f".action.fullscreen-window = {};
        "Mod+Shift+space".action.center-column = {};

        "Mod+Left".action.focus-column-left = {};
        "Mod+Right".action.focus-column-right = {};
        "Mod+Up".action.focus-window-up = {};
        "Mod+Down".action.focus-window-down = {};

        "Mod+Shift+Left".action.move-column-left = {};
        "Mod+Shift+Right".action.move-column-right = {};
        "Mod+Shift+Up".action.move-window-up = {};
        "Mod+Shift+Down".action.move-window-down = {};

        "Mod+1".action.focus-workspace = "1";
        "Mod+2".action.focus-workspace = "2";
        "Mod+3".action.focus-workspace = "3";
        "Mod+4".action.focus-workspace = "4";
        "Mod+5".action.focus-workspace = "5";
        "Mod+6".action.focus-workspace = "6";
        "Mod+7".action.focus-workspace = "7";
        "Mod+8".action.focus-workspace = "8";
        "Mod+9".action.focus-workspace = "9";
        "Mod+0".action.focus-workspace = "10";

        "Mod+Shift+1".action.move-column-to-workspace = "1";
        "Mod+Shift+2".action.move-column-to-workspace = "2";
        "Mod+Shift+3".action.move-column-to-workspace = "3";
        "Mod+Shift+4".action.move-column-to-workspace = "4";
        "Mod+Shift+5".action.move-column-to-workspace = "5";
        "Mod+Shift+6".action.move-column-to-workspace = "6";
        "Mod+Shift+7".action.move-column-to-workspace = "7";
        "Mod+Shift+8".action.move-column-to-workspace = "8";
        "Mod+Shift+9".action.move-column-to-workspace = "9";
        "Mod+Shift+0".action.move-column-to-workspace = "10";

        "Mod+b".action.set-column-width = "-10%";
        "Mod+v".action.set-column-width = "+10%";
        "Mod+r".action.reset-window-height = {};

        "Mod+period".action.focus-monitor-right = {};
        "Mod+comma".action.focus-monitor-left = {};
        "Mod+Shift+period".action.move-column-to-monitor-right = {};
        "Mod+Shift+comma".action.move-column-to-monitor-left = {};

        "Mod+Print".action.spawn = ["sh" "-c" "grim - | wl-copy"];
        "Mod+Shift+Print".action.spawn = ["sh" "-c" "grim -g \"$(slurp)\" ~/Pictures/$(date +'%Y-%m-%d-%H%M%S_grim.png') && grim -g \"$(slurp)\" - | wl-copy"];
        "Print".action.spawn = ["sh" "-c" "grim -g \"$(slurp)\" - | satty --filename - --output-filename - --copy-command wl-copy"];

        "XF86MonBrightnessDown".action.spawn = ["brightnessctl" "set" "2%-"];
        "XF86MonBrightnessUp".action.spawn = ["brightnessctl" "set" "+2%"];
        "XF86AudioMute".action.spawn = ["pamixer" "-t"];
        "XF86AudioRaiseVolume".action.spawn = ["pamixer" "--increase" "2"];
        "XF86AudioLowerVolume".action.spawn = ["pamixer" "--decrease" "2"];

        "Mod+l".action.spawn = ["swaylock"];
        "Mod+Shift+c".action.reload-config = {};
        "Mod+Shift+e".action.quit = {};

        "Mod+WheelScrollDown".action.focus-workspace-down = {};
        "Mod+WheelScrollUp".action.focus-workspace-up = {};
        "Mod+Shift+WheelScrollDown".action.move-column-to-workspace-down = {};
        "Mod+Shift+WheelScrollUp".action.move-column-to-workspace-up = {};
      };

      spawn-at-startup = [
        { command = ["nm-applet" "--indicator"]; }
        { command = ["nwg-panel"]; }
      ];

      cursor = {
        size = 24;
        theme = "default";
      };

      prefer-no-csd = true;
    };
  };

  home.packages = with pkgs; [
    grim
    slurp  
    satty
    wl-clipboard
    
    brightnessctl
    pamixer
  ];

  home.sessionVariables = lib.mkDefault {
    XDG_CURRENT_DESKTOP = "niri";
    XDG_SESSION_DESKTOP = "niri";
  };
}
