{
  config,
  pkgs,
  lib,
  ...
}: let
  wallpaper = ../assets/wallpapers/wallpaper.png;

  # glpaper shader viewer/live-editor. Toggle key: press once to pick a .glsl
  # (fuzzel), a resolution, and — when an external display is connected — which
  # output(s); starts it detached (no terminal). Press again to stop it.
  # live = entr reloads on save; load = show once. Errors -> ~/.cache/shader-live.log.
  # Needs on PATH (all installed): fuzzel, entr, glpaper, setsid, niri.
  shaderLive = pkgs.writeShellScript "shader-live" ''
    set -eu

    # __paint worker: render $file on each given output. glpaper does one output
    # per process, so we spawn one per output and wait. The TERM trap kills them
    # cleanly so entr -r (live reload) and the group-kill toggle both work.
    if [ "''${1:-}" = __paint ]; then
      shift; pres="$1"; pfile="$2"; shift 2
      trap 'kill $(jobs -p) 2>/dev/null || true; exit 0' TERM INT
      for o in "$@"; do glpaper --fps 30 $pres "$o" "$pfile" & done
      wait || true
      exit 0
    fi

    dir="$HOME/.config/shaders"
    mode="''${1:-live}"                       # live | load
    pidfile="$HOME/.cache/shader-live.pid"
    log="$HOME/.cache/shader-live.log"
    internal=eDP-1                            # laptop panel
    mkdir -p "$HOME/.cache"

    running() { [ -f "$pidfile" ] && kill -0 "$(cat "$pidfile")" 2>/dev/null; }
    stop() {
      if [ -f "$pidfile" ]; then
        kill -- -"$(cat "$pidfile")" 2>/dev/null || true   # kill the whole process group
        rm -f "$pidfile"
      fi
    }

    # toggle: a session is up -> stop it and quit
    if running; then stop; exit 0; fi
    stop                                      # clear any stale pidfile

    spath="''${dir/#$HOME/~}"                  # ~/.config/shaders — shown as the picker prompt
    sel=$(cd "$dir" && ls *.glsl 2>/dev/null | fuzzel --dmenu --prompt "$spath/ ") || exit 0
    [ -n "$sel" ] || exit 0
    f="$dir/$sel"

    # resolution menu (screen is 1366x768). Empty = native.
    rsel=$(printf '%s\n' "half 683x384" "third 456x256" "quarter 342x192" "full native" \
             | fuzzel --dmenu --prompt "res> ") || exit 0
    [ -n "$rsel" ] || exit 0
    case "$rsel" in
      half*)    res="-W 683 -H 384" ;;
      third*)   res="-W 456 -H 256" ;;
      quarter*) res="-W 342 -H 192" ;;
      full*)    res="" ;;
      *)        res="-W 683 -H 384" ;;
    esac

    # output menu — only asked when an external display is connected.
    mapfile -t outs < <(niri msg outputs 2>/dev/null | sed -n 's/^Output .*(\(.*\))$/\1/p')
    externals=()
    for o in "''${outs[@]}"; do [ "$o" = "$internal" ] || externals+=("$o"); done
    targets=("$internal")
    if [ ''${#externals[@]} -gt 0 ]; then
      osel=$(printf '%s\n' "laptop only" "external only" "both" \
               | fuzzel --dmenu --prompt "output> ") || exit 0
      [ -n "$osel" ] || exit 0
      case "$osel" in
        laptop*)   targets=("$internal") ;;
        external*) targets=("''${externals[@]}") ;;
        both*)     targets=("$internal" "''${externals[@]}") ;;
      esac
    fi

    # detached via setsid: new session, leader pid == pgid, survives this script.
    # live watches the file and relaunches the worker on save; load runs it once.
    if [ "$mode" = live ]; then
      setsid sh -c "printf '%s\n' \"$f\" | entr -nr \"$0\" __paint \"$res\" \"$f\" ''${targets[*]}" >"$log" 2>&1 &
    else
      setsid "$0" __paint "$res" "$f" "''${targets[@]}" >"$log" 2>&1 &
    fi
    echo $! >"$pidfile"
  '';
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
        natural-scroll
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

    environment {
      // quickshell/Qt apps default to xcb without this and die "cannot open display"
      QT_QPA_PLATFORM "wayland"
      // GDK_BACKEND intentionally NOT set: niri docs warn a global GDK_BACKEND
      // breaks the gnome screencast portal (Discord/OBS share). Qt is covered by
      // QT_QPA_PLATFORM above; GDK_BACKEND only affects GTK apps anyway.
      // qt.platformTheme = "gtk" sets QT_QPA_PLATFORMTHEME=gtk2 which needs $DISPLAY
      QT_QPA_PLATFORMTHEME ""
    }

    output "*" {
      background-color "#000000"
    }

    window-rule {
      match app-id="^chromium$"
      default-column-width { proportion 0.5; }
    }

    window-rule {
      match app-id="^firefox$"
      default-column-width { proportion 0.75; }
    }

    window-rule {
      match app-id="^app.zen_browser.zen$"
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
      Mod+Return { spawn "ghostty"; }
      Mod+d { spawn "noctalia-shell" "ipc" "call" "launcher" "toggle"; }
      Mod+s { spawn "${shaderLive}" "live"; }        // pick a shader, live-edit it (entr reload on save)
      Mod+Shift+s { spawn "${shaderLive}" "load"; }  // pick a shader, load it once (no watch)
      Mod+Shift+Return { spawn "app.zen_browser.zen"; }
      Mod+Shift+q { close-window; }
      Mod+f { fullscreen-window; }
      Mod+m { maximize-column; }
      Mod+Shift+f { toggle-window-floating; }
      Mod+Shift+space { center-column; }
      Mod+Tab { switch-focus-between-floating-and-tiling; }

      // resize: width on b/v below; height here. Or mouse: Mod+right-drag.
      Mod+minus { set-window-height "-10%"; }
      Mod+equal { set-window-height "+10%"; }

      Mod+Left { focus-column-left; }
      Mod+Right { focus-column-right; }
      Mod+h { focus-column-left; }
      Mod+l { focus-column-right; }
      Mod+Up { focus-window-up; }
      Mod+Down { focus-window-down; }

      Mod+Shift+Left { move-column-left; }
      Mod+Shift+Right { move-column-right; }
      Mod+Shift+h { move-column-left; }
      Mod+Shift+l { move-column-right; }

      Mod+j { focus-workspace-down; }
      Mod+k { focus-workspace-up; }
      Mod+Shift+j { move-column-to-workspace-down; }
      Mod+Shift+k { move-column-to-workspace-up; }
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

      Mod+Escape { spawn "swaylock"; } // moved off Mod+l (now focus-column-right)
      Mod+Shift+e { quit; }

      Mod+WheelScrollDown { focus-workspace-down; }
      Mod+WheelScrollUp { focus-workspace-up; }
      Mod+Shift+WheelScrollDown { move-column-to-workspace-down; }
      Mod+Shift+WheelScrollUp { move-column-to-workspace-up; }
    }

    spawn-at-startup "sh" "-c" "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE DISPLAY && dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE DISPLAY"
    spawn-at-startup "gnome-keyring-daemon" "--start" "--components=secrets"
    spawn-at-startup "noctalia-shell"
    // spawn-at-startup "nwg-panel"  // disabled: noctalia provides the bar

    prefer-no-csd
  '';
}
