{ config, pkgs, lib, ... }:
{

  xdg.configFile = {
    "eww/scripts/get-workspaces.sh" = {
      text = ''
        #!/bin/sh
        swaymsg -t subscribe -m '["window", "workspace"]' | while read -r line; do
          swaymsg -t get_tree | jq -c '
            [
              recurse(.nodes[], .floating_nodes[]) |
              select(.type == "workspace") |
              {
                num: .num,
                focused: .focused,
                windows: [
                  recurse(.nodes[]?, .floating_nodes[]?) |
                  select(.app_id? != null or .window_properties?.class != null) |
                  {
                    app_id: .app_id,
                    class: (.window_properties.class // null)
                  }
                ]
              }
            ]
          '
        done
      '';
      executable = true;
    };

    "eww/eww.scss".text = ''
      * {
        all: unset;
      }

      .bar {
        background-color: rgba(0, 0, 0, 0.2);
        color: #ffffff;
        padding: 0.2rem;
      }

      .workspaces {
        margin-left: 8px;
      }

      .workspace-button {
        min-width: 20px;
        min-height: 20px;
        border-radius: 4px;
        padding: 0 4px;
        background-color: rgba(255, 255, 255, 0.05);
        transition: all 200ms ease;
      }

      .workspace-button.empty {
        background-color: rgba(255, 255, 255, 0.02);
        min-width: 16px;
        min-height: 16px;
        padding: 0 2px;
        opacity: 0.4;
      }

      .workspace-button.focused {
        background-color: rgba(255, 255, 255, 0.1);
        border: 1px solid rgba(255, 255, 255, 0.15);
        opacity: 1;
      }

      .workspace-button:hover {
        background-color: rgba(255, 255, 255, 0.1);
      }

      .window-icon {
        font-family: "FiraCode Nerd Font";
        font-size: 12px;
        color: rgba(255, 255, 255, 0.8);
        margin: 0 2px;
      }

      .status {
        padding: 0 1rem;
      }

      .volume-indicator,
      .brightness-indicator {
        background-color: rgba(0, 0, 0, 0.2);
        border: 1px solid rgba(255, 255, 255, 0.1);
        border-radius: 8px;
        padding: 1rem;
        margin: 1rem;
        color: #ffffff;
      }

      .volume-scale scale trough,
      .brightness-scale scale trough {
        background-color: rgba(255, 255, 255, 0.1);
        border-radius: 24px;
        margin: 0 1rem;
        min-height: 10px;
        min-width: 120px;
      }

      .volume-scale scale trough highlight,
      .brightness-scale scale trough highlight {
        background-color: #ffffff;
        border-radius: 24px;
      }
    '';

    "eww/eww.yuck".text = ''
      ;; Variable declarations
      (deflisten workspaces :initial "[]" "~/.config/eww/scripts/get-workspaces.sh")
      (defpoll volume :interval "1s" "pamixer --get-volume")
      (defpoll brightness :interval "1s" "brightnessctl -m | awk -F, '{print substr($4, 0, length($4)-1)}'")

      ;; Widget definitions
      (defwidget workspaces []
        (box :class "workspaces"
             :orientation "h"
             :space-evenly false
             :halign "start"
             :spacing 4
          (for workspace in workspaces
            (button
              :onclick "swaymsg workspace number {workspace.num}"
              :class {workspace.focused ? "workspace-button focused" :
                      arraylength(workspace.windows) > 0 ? "workspace-button occupied" :
                      "workspace-button empty"}
              (box :class "workspace-content"
                   :space-evenly false
                   :spacing 4
                (for window in {workspace.windows}
                  (label :class "window-icon"
                         :text {
                           window.app_id == "org.wezfurlong.wezterm" ? "󰆍" :
                           window.app_id == "firefox" ? "󰈹" :
                           window.app_id == "chromium-browser" ? "󰖟" :
                           window.app_id == "vesktop" ? "󰙯" :
                           window.class == "steam" ? "󰓓" :
                           window.app_id == "Bitwarden" ? "󰞀" :
                           window.app_id == "org.kde.kate" ? "󰯂" :
                           window.app_id == "nemo" ? "󰉋" :
                           window.app_id == "org.qbittorrent.qBittorrent" ? "󰻈" :
                           window.class == "Ankama Launcher" ? "󰯫" :
                           window.app_id == "Dofus.x64" ? "󰪯" :
                           window.app_id == "io.github.seadve.Kooha" ? "󱣵" :
                           ""
                         })))))))

      (defwidget metric [label value onchange]
        (box :orientation "h"
             :class "metric"
             :space-evenly false
          (box :class "label" label)
          (scale :min 0
                 :max 101
                 :active {onchange != ""}
                 :value value
                 :onchange onchange)))

      (defwidget time []
        (box :class "time"
             :orientation "h"
             :space-evenly false
             :halign "center"
          {formattime(EWW_TIME, "%H:%M")}))

      (defwidget volume []
        (box :class "volume-indicator"
             :orientation "h"
             :space-evenly false
          (box :class "volume-icon" "󰕾")
          (scale :class "volume-scale"
                 :value volume
                 :orientation "h"
                 :tooltip {volume + "%"}
                 :max 100
                 :min 0)))

      (defwidget brightness []
        (box :class "brightness-indicator"
             :orientation "h"
             :space-evenly false
          (box :class "brightness-icon" "󰃞")
          (scale :class "brightness-scale"
                 :value brightness
                 :orientation "h"
                 :tooltip {brightness + "%"}
                 :max 100
                 :min 0)))

      (defwidget sidestuff []
        (box :class "status"
             :orientation "h"
             :space-evenly false
             :halign "end"
             :spacing 15
          (metric :label "󰻠"
                  :value {EWW_RAM.used_mem_perc}
                  :onchange "")
          (metric :label "󰍛"
                  :value {round((1 - EWW_CPU.avg) * 100)}
                  :onchange "")
          (metric :label "󰋊"
                  :value {EWW_BATTERY["BAT0"].capacity}
                  :onchange "")))

      (defwidget bar []
        (centerbox :orientation "h"
          (workspaces)
          (time)
          (sidestuff)))
      ;; Window definitions
      (defwindow bar
        :monitor 0
        :exclusive true
        :geometry (geometry :x "0%"
                           :y "0%"
                           :width "100%"
                           :height "24px"
                           :anchor "top center")
        (bar))

      (defwindow volume-indicator
        :monitor 0
        :geometry (geometry :x "0%"
                           :y "80%"
                           :width "140px"
                           :height "40px"
                           :anchor "center")
        :stacking "overlay"
        (volume))

      (defwindow brightness-indicator
        :monitor 0
        :geometry (geometry :x "0%"
                           :y "80%"
                           :width "140px"
                           :height "40px"
                           :anchor "center")
        :stacking "overlay"
        (brightness))
    '';

    "eww/scripts/volume.sh" = {
      text = ''
        #!/bin/sh
        volume() {
          pamixer "$@"
          eww open volume-indicator
          sleep 1
          eww close volume-indicator
        }
        volume "$@"
      '';
      executable = true;
    };

    "eww/scripts/brightness.sh" = {
      text = ''
        #!/bin/sh
        brightness() {
          brightnessctl "$@"
          eww open brightness-indicator
          sleep 1
          eww close brightness-indicator
        }
        brightness "$@"
      '';
      executable = true;
    };

    "eww/start-bar.sh" = {
      text = ''
        #!/bin/sh
        pkill eww || true
        sleep 1
        eww daemon
        sleep 2
        eww open bar
      '';
      executable = true;
    };
  };
}
