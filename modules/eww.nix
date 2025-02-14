{ config, pkgs, lib, ... }:
{
  xdg.configFile = {
    "eww/scripts/get-workspaces.sh" = {
      text = ''
        #!/bin/sh
        swaymsg -t subscribe -m '["window", "workspace"]' | while read -r line; do
          swaymsg -t get_tree | jq -c '[
            recurse(.nodes[], .floating_nodes[]) |
            select(.type == "workspace") |
            {
              num: .num,
              focused: .focused,
              windows: [
                recurse(.nodes[]?, .floating_nodes[]?) |
                select(.app_id? != null or .window_properties?.class != null) |
                { app_id: .app_id, class: .window_properties.class }
              ]
            }
          ]'
        done
      '';
      executable = true;
    };

    "eww/eww.scss".text = ''
      * { all: unset; }

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
      }

      .workspace-button.empty {
        background-color: rgba(255, 255, 255, 0.02);
        opacity: 0.4;
      }

      .workspace-button.focused {
        background-color: rgba(255, 255, 255, 0.1);
        border: 1px solid rgba(255, 255, 255, 0.15);
      }

      .window-icon {
        font-family: "FiraCode Nerd Font";
        font-size: 12px;
        margin: 0 2px;
      }
    '';

    "eww/eww.yuck".text = ''
      (deflisten workspaces :initial "[]" "~/.config/eww/scripts/get-workspaces.sh")

      (defwidget workspaces []
        (box :class "workspaces"
             :orientation "h"
             :space-evenly false
             :halign "start"
             :spacing 4
          (for workspace in workspaces
            (eventbox
              :onclick "swaymsg workspace number {workspace.num}"
              (box
                :class {workspace.focused ? "workspace-button focused" :
                        arraylength(workspace.windows) > 0 ? "workspace-button" :
                        "workspace-button empty"}
                :space-evenly false
                (for window in {workspace.windows}
                  (label
                    :class "window-icon"
                    :text {window.app_id == "org.wezfurlong.wezterm" ? "" :
                          window.app_id == "firefox" ? "󰈹" :
                          window.app_id == "chromium-browser" ? "" :
                          window.app_id == "vesktop" ? "" :
                          window.class == "steam" ? "" :
                          window.app_id == "Bitwarden" ? "󰞀" :
                          window.app_id == "org.kde.kate" ? "󰯂" :
                          window.app_id == "nemo" ? "󰉋" :
                          window.app_id == "org.qbittorrent.qBittorrent" ? "" :
                          window.class == "Ankama Launcher" ? "" :
                          window.app_id == "Dofus.x64" ? "󰪯" :
                          window.app_id == "io.github.seadve.Kooha" ? "󱣵" :
                          window.app_id == "Element" ? "󱥁" :
                          window.app_id == "org.telegram.desktop" ? "" :
                          window.app_id == "com.rtosta.zapzap" ? "" :
                          window.app_id == "org.nicotine_plus.Nicotine" ? "󱐍" :
                          ""})))))))

      (defwidget time []
        (box :class "time"
             :halign "center"
          {formattime(EWW_TIME, "%H:%M")}))

      (defwidget bar []
        (centerbox :orientation "h"
          (workspaces)
          (time)
          (box)))

      (defwindow bar
        :monitor 0
        :exclusive true
        :geometry (geometry :x "0%"
                          :y "0%"
                          :width "100%"
                          :height "24px"
                          :anchor "top center")
        (bar))
    '';

    "eww/start-bar.sh" = {
      text = ''
        #!/bin/sh
        pkill eww || true
        sleep 1
        ${pkgs.eww}/bin/eww daemon
        sleep 2
        ${pkgs.eww}/bin/eww open bar
      '';
      executable = true;
    };
  };
}
