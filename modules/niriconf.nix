{
  config,
  pkgs,
  lib,
  ...
}: let
  wallpaper = ../assets/wallpapers/wallpaper.png;
in {
  home.file.".config/niri/config.kdl".text = ''
    input {
      keyboard {
        xkb {
          layout "us"
        }
        repeat-delay 300
        repeat-rate 50
      }

      touchpad {
        tap
        accel-speed 1
        accel-profile "adaptive"
        tap-button-map "left-right-middle"
        scroll-method "two-finger"
      }

      mouse {
        accel-speed 0.0
        accel-profile "flat"
      }
    }

    output "*" {
      background-color "#000000"
    }

    window-rule {
      match app-id="^chromium$"
      default-column-width { proportion 0.5; }
    }

    window-rule {
      match app-id="^vesktop$"
      open-on-workspace "chat"
    }

    window-rule {
      match app-id="^firefox$"
      default-column-width { proportion 0.75; }
    }

    workspace "1"
    workspace "2"
    workspace "3"
    workspace "4"
    workspace "5"
    workspace "6"
    workspace "7"
    workspace "8"
    workspace "9"
    workspace "10"
    workspace "chat"

    layout {
      gaps 16
      center-focused-column "never"

      preset-column-widths {
        proportion 0.33333
        proportion 0.5
        proportion 0.66667
      }

      default-column-width { proportion 0.5; }

      focus-ring {
        width 2
        active-color "#ffffff"
        inactive-color "#505050"
      }

      border {
        width 1
        active-color "#ffffff"
        inactive-color "#505050"
      }
    }

    animations {
      slowdown 1.0

      workspace-switch {
        spring damping-ratio=1.0 stiffness=1000 epsilon=0.0001
      }

      window-open {
        duration-ms 150
        curve "ease-out-expo"
      }

      window-close {
        duration-ms 150
        curve "ease-out-expo"
      }

      horizontal-view-movement {
        spring damping-ratio=1.0 stiffness=800 epsilon=0.0001
      }
    }

    binds {
      Mod+Return { spawn "wezterm"; }
      Mod+d { spawn "wofi" "--show" "drun"; }
      Mod+Shift+Return { spawn "chromium"; }
      Mod+Shift+q { close-window; }
      Mod+f { fullscreen-window; }
      Mod+Shift+space { center-column; }

      Mod+Left { focus-column-left; }
      Mod+Right { focus-column-right; }
      Mod+Up { focus-window-up; }
      Mod+Down { focus-window-down; }

      Mod+Shift+Left { move-column-left; }
      Mod+Shift+Right { move-column-right; }
      Mod+Shift+Up { move-window-up; }
      Mod+Shift+Down { move-window-down; }

      Mod+1 { focus-workspace "1"; }
      Mod+2 { focus-workspace "2"; }
      Mod+3 { focus-workspace "3"; }
      Mod+4 { focus-workspace "4"; }
      Mod+5 { focus-workspace "5"; }
      Mod+6 { focus-workspace "6"; }
      Mod+7 { focus-workspace "7"; }
      Mod+8 { focus-workspace "8"; }
      Mod+9 { focus-workspace "9"; }
      Mod+0 { focus-workspace "10"; }

      Mod+Shift+1 { move-column-to-workspace "1"; }
      Mod+Shift+2 { move-column-to-workspace "2"; }
      Mod+Shift+3 { move-column-to-workspace "3"; }
      Mod+Shift+4 { move-column-to-workspace "4"; }
      Mod+Shift+5 { move-column-to-workspace "5"; }
      Mod+Shift+6 { move-column-to-workspace "6"; }
      Mod+Shift+7 { move-column-to-workspace "7"; }
      Mod+Shift+8 { move-column-to-workspace "8"; }
      Mod+Shift+9 { move-column-to-workspace "9"; }
      Mod+Shift+0 { move-column-to-workspace "10"; }

      Mod+b { set-column-width "-10%"; }
      Mod+v { set-column-width "+10%"; }
      Mod+r { reset-window-height; }

      Mod+period { focus-monitor-right; }
      Mod+comma { focus-monitor-left; }
      Mod+Shift+period { move-column-to-monitor-right; }
      Mod+Shift+comma { move-column-to-monitor-left; }

      Mod+Print { spawn "sh" "-c" "grim - | wl-copy"; }
      Mod+Shift+Print { spawn "sh" "-c" "grim -g \"$(slurp)\" ~/Pictures/$(date +'%Y-%m-%d-%H%M%S_grim.png') && grim -g \"$(slurp)\" - | wl-copy"; }
      Print { spawn "sh" "-c" "grim -g \"$(slurp)\" - | satty --filename - --output-filename - --copy-command wl-copy"; }

      XF86MonBrightnessDown { spawn "brightnessctl" "set" "2%-"; }
      XF86MonBrightnessUp { spawn "brightnessctl" "set" "+2%"; }
      XF86AudioMute { spawn "pamixer" "-t"; }
      XF86AudioRaiseVolume { spawn "pamixer" "--increase" "2"; }
      XF86AudioLowerVolume { spawn "pamixer" "--decrease" "2"; }

      Mod+l { spawn "swaylock"; }
      Mod+Shift+e { quit; }

      Mod+WheelScrollDown { focus-workspace-down; }
      Mod+WheelScrollUp { focus-workspace-up; }
      Mod+Shift+WheelScrollDown { move-column-to-workspace-down; }
      Mod+Shift+WheelScrollUp { move-column-to-workspace-up; }
    }

    spawn-at-startup "nm-applet" "--indicator"
    spawn-at-startup "nwg-panel"

    prefer-no-csd
  '';
}
