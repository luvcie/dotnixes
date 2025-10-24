{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.modules.audio;
in {
  options.modules.audio = {
    enable = lib.mkEnableOption "Custom audio configuration using PipeWire, RTKit, and PAM limits";
    userName = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "The primary user that should be added to audio-related groups.";
    };
  };

  config = lib.mkIf cfg.enable {
    #######################
    # AUDIO CONFIGURATION #
    #######################

    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;

      extraConfig.pipewire = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.quantum" = 1024;
          "default.clock.min-quantum" = 1024;
          "default.clock.max-quantum" = 1024;
          "core.clock.power-of-two-quantum" = true;

          "core.daemon" = true;
          "core.name" = "pipewire-0";
          "mem.allow-mlock" = true;

          "node.latency" = "256/48000";
          "vm.overcommit" = true;

          "default.clock.allowed-rates" = [44100 48000 88200 96000];

          "core.recovery.time" = 10000;

          "default.fragments" = 2;
          "default.fragment.size-max" = 4096;

          "default.format" = "F32";
          "default.position" = ["FL" "FR"];

          "support.dbus" = true;
          "log.level" = 2;

          "pulse.min.req" = 256;
          "pulse.default.req" = 256;
          "pulse.max.req" = 256;
          "pulse.min.frag" = 256;
          "pulse.default.frag" = 256;
          "pulse.max.frag" = 256;
        };

        "context.modules" = [
          {
            name = "libpipewire-module-rtkit";
            args = {
              "nice.level" = -20;
              "rt.prio" = 99;
              "rt.time.soft" = 2000000;
              "rt.time.hard" = 2000000;
            };
            flags = ["ifexists" "nofail"];
          }
          {
            name = "libpipewire-module-protocol-pulse";
            args = {
              "pulse.min.req" = "256/48000";
              "pulse.default.req" = "256/48000";
              "pulse.max.req" = "256/48000";
              "pulse.min.quantum" = "256/48000";
              "pulse.max.quantum" = "256/48000";
            };
          }
        ];
      };
    };

    security.pam.loginLimits = [
      {
        domain = "@audio";
        item = "memlock";
        type = "-";
        value = "unlimited";
      }
      {
        domain = "@audio";
        item = "rtprio";
        type = "-";
        value = "99";
      }
      {
        domain = "@audio";
        item = "nofile";
        type = "soft";
        value = "99999";
      }
      {
        domain = "@audio";
        item = "nofile";
        type = "hard";
        value = "99999";
      }
      {
        domain = "@audio";
        item = "nice";
        type = "-";
        value = "-20";
      }
      {
        domain = "@realtime";
        item = "nice";
        type = "-";
        value = "-20";
      }
      {
        domain = "@realtime";
        item = "rtprio";
        type = "-";
        value = "99";
      }
    ];

    environment.systemPackages = with pkgs; [
      pavucontrol
    ];

    users.users = lib.mkIf (cfg.userName != null && config.users.users."${cfg.userName}" != null) {
      "${cfg.userName}".extraGroups = ["audio" "realtime"];
    };
  };
}
