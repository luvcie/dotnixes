{
  config,
  pkgs,
  lib,
  ...
}: let
  wallpaperDir = "/home/lucie/dotnixes/assets/wallpapers";
  cycleWallpaper = pkgs.writeShellScript "cycle-wallpaper" ''
    STATE_FILE="/tmp/sway-wallpaper-index"

    # Get sorted list of wallpapers
    wallpapers=($(${pkgs.coreutils}/bin/ls ${wallpaperDir}/*.{jpg,png} 2>/dev/null | ${pkgs.coreutils}/bin/sort))

    # Read current index, default to 0
    if [ -f "$STATE_FILE" ]; then
      current_index=$(${pkgs.coreutils}/bin/cat "$STATE_FILE")
    else
      current_index=0
    fi

    # Get next wallpaper (circular)
    next_index=$(( (current_index + 1) % ''${#wallpapers[@]} ))
    wallpaper="''${wallpapers[$next_index]}"

    # Save new index
    echo "$next_index" > "$STATE_FILE"

    # Set wallpaper
    ${pkgs.procps}/bin/pkill swaybg
    ${pkgs.swaybg}/bin/swaybg -i "$wallpaper" -m fill &
  '';
in {
  wayland.windowManager.sway = {
    enable = true;
    package = pkgs.swayfx;
    systemd.enable = true;
    wrapperFeatures.gtk = true;

    extraConfigEarly = ''
      exec "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway"
      exec autotiling-rs
      exec rm -f /tmp/sovpipe && mkfifo /tmp/sovpipe && tail -f /tmp/sovpipe | sov -t 500
    '';

    checkConfig = false;

    extraConfig = ''
      for_window [app_id="chromium-browser"] {
      opacity 1;
      }
      corner_radius 0
      shadows enable
      blur enable
      titlebar_separator disable
      font pango:Cozette 10
      gaps outer 0
      gaps inner 6
      titlebar_border_thickness 0
      set $border_width 1
      default_border pixel $border_width
      default_floating_border pixel $border_width
      title_align center
      client.focused          #000000 #000000    #FFFFFF  #000000    #000000
      client.focused_inactive #000000 #000000    #FFFFFF  #000000    #000000
      client.unfocused        #000000 #000000    #FFFFFF  #000000    #000000
      client.urgent           #000000 #000000    #FFFFFF  #000000    #000000
      client.placeholder      #000000 #000000    #FFFFFF  #000000    #000000
      client.background       #000000
    '';

    extraSessionCommands = ''
      export SWAYSOCK=/run/user/$UID/sway-ipc.$UID.$(pgrep -x sway).sock
      export WLR_NO_HARDWARE_CURSORS=1
      export NIXOS_OZONE_WL=1
      export MOZ_ENABLE_WAYLAND=1
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
      export GDK_BACKEND=wayland
      export SDL_VIDEODRIVER=wayland
      export CLUTTER_BACKEND=wayland
      export XDG_SESSION_TYPE=wayland
    '';

    config = rec {
      modifier = "Mod4";
      terminal = "wezterm";
      menu = "${pkgs.wofi}/bin/wofi --show drun";
      output = {
        # External monitor (Lenovo) - positioned at top
        "DP-1" = {
          position = "0,0";
        };
        # Laptop screen - positioned below external monitor
        "eDP-1" = {
          position = "0,1440";
        };
        # Fallback for any other displays
        "*" = {};
      };

      gaps = {
        inner = 6;
        outer = 6;
      };

      window = {
        border = 3;
        commands = [
          {
            criteria = {app_id = "zen-alpha";};
            command = "move container to workspace 2";
          }
          {
            criteria = {app_id = "vesktop";};
            command = "move container to workspace 3";
          }
          # Higurashi and other Unity/Wine games that resist fullscreen
          {
            criteria = {title = "Higurashi When They Cry.*";};
            command = "floating enable, border none, resize set 1366 768, move position 0 0";
          }
          # Habbo fishing auto-clicker
          {
            criteria = {title = "Fishing Setup";};
            command = "floating enable";
          }
          {
            criteria = {title = "Fishing...";};
            command = "floating enable";
          }
        ];
      };

      startup = [
        {command = "swaymsg 'workspace 1'";}
        {command = "nm-applet --indicator";}
        #       { command = "nwg-panel"; }
        {command = "${cycleWallpaper}";}
        {command = "${pkgs.swayidle}/bin/swayidle -w timeout 600 'swaylock -f' timeout 900 'swaymsg \"output * dpms off\"' resume 'swaymsg \"output * dpms on\"' before-sleep 'swaylock -f' --fork-after-sleep-command";}
        {command = "${pkgs.quickshell}/bin/quickshell";}
      ];

      keybindings = {
        "${modifier}+Up" = "focus up";
        "${modifier}+Down" = "focus down";
        "${modifier}+Left" = "focus left";
        "${modifier}+Right" = "focus right";

        "${modifier}+Shift+Up" = "move up";
        "${modifier}+Shift+Down" = "move down";
        "${modifier}+Shift+Left" = "move left";
        "${modifier}+Shift+Right" = "move right";

        "${modifier}+Shift+bracketright" = "move workspace to output right";
        "${modifier}+Shift+bracketleft" = "move workspace to output left";
        "${modifier}+period" = "focus output right";
        "${modifier}+comma" = "focus output left";

        "--no-repeat ${modifier}+1" = "workspace number 1; exec \"echo 1 > /tmp/sovpipe\"";
        "--no-repeat ${modifier}+2" = "workspace number 2; exec \"echo 1 > /tmp/sovpipe\"";
        "--no-repeat ${modifier}+3" = "workspace number 3; exec \"echo 1 > /tmp/sovpipe\"";
        "--no-repeat ${modifier}+4" = "workspace number 4; exec \"echo 1 > /tmp/sovpipe\"";
        "--no-repeat ${modifier}+5" = "workspace number 5; exec \"echo 1 > /tmp/sovpipe\"";
        "--no-repeat ${modifier}+6" = "workspace number 6; exec \"echo 1 > /tmp/sovpipe\"";
        "--no-repeat ${modifier}+7" = "workspace number 7; exec \"echo 1 > /tmp/sovpipe\"";
        "--no-repeat ${modifier}+8" = "workspace number 8; exec \"echo 1 > /tmp/sovpipe\"";
        "--no-repeat ${modifier}+9" = "workspace number 9; exec \"echo 1 > /tmp/sovpipe\"";
        "--no-repeat ${modifier}+0" = "workspace number 10; exec \"echo 1 > /tmp/sovpipe\"";

        "--release ${modifier}+1" = "exec \"echo 0 > /tmp/sovpipe\"";
        "--release ${modifier}+2" = "exec \"echo 0 > /tmp/sovpipe\"";
        "--release ${modifier}+3" = "exec \"echo 0 > /tmp/sovpipe\"";
        "--release ${modifier}+4" = "exec \"echo 0 > /tmp/sovpipe\"";
        "--release ${modifier}+5" = "exec \"echo 0 > /tmp/sovpipe\"";
        "--release ${modifier}+6" = "exec \"echo 0 > /tmp/sovpipe\"";
        "--release ${modifier}+7" = "exec \"echo 0 > /tmp/sovpipe\"";
        "--release ${modifier}+8" = "exec \"echo 0 > /tmp/sovpipe\"";
        "--release ${modifier}+9" = "exec \"echo 0 > /tmp/sovpipe\"";
        "--release ${modifier}+0" = "exec \"echo 0 > /tmp/sovpipe\"";

        "${modifier}+Shift+1" = "move container to workspace number 1";
        "${modifier}+Shift+2" = "move container to workspace number 2";
        "${modifier}+Shift+3" = "move container to workspace number 3";
        "${modifier}+Shift+4" = "move container to workspace number 4";
        "${modifier}+Shift+5" = "move container to workspace number 5";
        "${modifier}+Shift+6" = "move container to workspace number 6";
        "${modifier}+Shift+7" = "move container to workspace number 7";
        "${modifier}+Shift+8" = "move container to workspace number 8";
        "${modifier}+Shift+9" = "move container to workspace number 9";
        "${modifier}+Shift+0" = "move container to workspace number 10";

        "${modifier}+b" = "splith";
        "${modifier}+v" = "splitv";
        "${modifier}+f" = "fullscreen";
        "${modifier}+Shift+space" = "floating toggle";
        "${modifier}+a" = "focus parent";
        "${modifier}+r" = "mode resize";

        "${modifier}+Shift+c" = "exec swaymsg reload";
        "${modifier}+Shift+q" = "kill";
        "${modifier}+d" = "exec ${menu}";
        "${modifier}+Shift+d" = "exec ${pkgs.wofi}/bin/wofi --show run";
        "${modifier}+l" = "exec ${pkgs.swaylock}/bin/swaylock -f";
        "${modifier}+w" = "exec ${cycleWallpaper}";
        "${modifier}+Return" = "exec ${terminal}";
        "${modifier}+Shift+Return" = "exec $browser";
        "${modifier}+p" = "exec \"echo 'toggle visibility' > /tmp/wcp\"";

        "${modifier}+Print" = "exec grim - | wl-copy";
        "${modifier}+Shift+Print" = "exec grim -g \"$(slurp)\" ~/Pictures/$(date +'%Y-%m-%d-%H%M%S_grim.png') - | wl-copy";
        "Print" = "exec grim -g \"$(slurp)\" - | satty --filename - --output-filename - --copy-command wl-copy";
        "Control+Print" = "exec mkdir -p ~/Pictures/Screenshots && grim ~/Pictures/Screenshots/$(date +'%Y-%m-%d-%H%M%S.png')";

        "XF86MonBrightnessDown" = "exec brightnessctl set 2%-";
        "XF86MonBrightnessUp" = "exec brightnessctl set +2%";

        "--locked --no-repeat XF86AudioMute" = "exec pamixer -t";
        "--locked --no-repeat XF86AudioRaiseVolume" = "exec pamixer --increase 2";
        "--locked --no-repeat XF86AudioLowerVolume" = "exec pamixer --decrease 2";
        "--locked --no-repeat XF86AudioMicMute" = "exec pamixer --default-source -t";

        "${modifier}+XF86AudioPlay" = "exec \"echo 1 > /tmp/vmp\"";
        "${modifier}+XF86AudioNext" = "exec \"echo 2 > /tmp/vmp\"";
        "${modifier}+XF86AudioPrev" = "exec \"echo 3 > /tmp/vmp\"";

        "${modifier}+Shift+e" = "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -B 'Yes, exit sway' 'swaymsg exit'";

        "${modifier}+h" = "mode habbo_safety";
      };

      input = {
        "type:touchpad" = {
          tap = "enabled";
          natural_scroll = "disabled";
          middle_emulation = "enabled";
          pointer_accel = "0.8";
        };
        "type:keyboard" = {
          xkb_layout = "us";
          repeat_delay = "300";
          repeat_rate = "50";
        };
      };

      modes = {
        resize = {
          "Left" = "resize shrink width 10 px";
          "Down" = "resize grow height 10 px";
          "Up" = "resize shrink height 10 px";
          "Right" = "resize grow width 10 px";
          "Return" = "mode default";
          "Escape" = "mode default";
        };
        habbo_safety = {
          "Escape" = "nop";
          "${modifier}+h" = "mode default";

          # Enable workspace switching in safety mode
          "--no-repeat ${modifier}+1" = "workspace number 1; exec \"echo 1 > /tmp/sovpipe\"";
          "--no-repeat ${modifier}+2" = "workspace number 2; exec \"echo 1 > /tmp/sovpipe\"";
          "--no-repeat ${modifier}+3" = "workspace number 3; exec \"echo 1 > /tmp/sovpipe\"";
          "--no-repeat ${modifier}+4" = "workspace number 4; exec \"echo 1 > /tmp/sovpipe\"";
          "--no-repeat ${modifier}+5" = "workspace number 5; exec \"echo 1 > /tmp/sovpipe\"";
          "--no-repeat ${modifier}+6" = "workspace number 6; exec \"echo 1 > /tmp/sovpipe\"";
          "--no-repeat ${modifier}+7" = "workspace number 7; exec \"echo 1 > /tmp/sovpipe\"";
          "--no-repeat ${modifier}+8" = "workspace number 8; exec \"echo 1 > /tmp/sovpipe\"";
          "--no-repeat ${modifier}+9" = "workspace number 9; exec \"echo 1 > /tmp/sovpipe\"";
          "--no-repeat ${modifier}+0" = "workspace number 10; exec \"echo 1 > /tmp/sovpipe\"";
        };
      };

      bars = [];
    };
  };
}
