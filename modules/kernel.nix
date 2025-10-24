{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.modules.kernel;
in {
  options.modules.kernel = {
    enable = lib.mkEnableOption "Custom kernel, bootloader, and kernel parameter configurations for this host";
  };

  config = lib.mkIf cfg.enable {
    boot = {
      kernelPackages = pkgs.linuxPackages_zen;

      loader = {
        systemd-boot = {
          enable = true;
          consoleMode = "max";
          editor = false;
        };
        efi.canTouchEfiVariables = true;
        timeout = 3;
      };

      kernelParams = [
        "amdgpu.gpu_recovery=1"
        "transparent_hugepage=never"
      ];

      kernel.sysctl = {
        "vm.swappiness" = 10;
        "vm.vfs_cache_pressure" = 50;
        "vm.max_map_count" = 262144;

        "kernel.sched_autogroup_enabled" = 0;
        "kernel.sched_child_runs_first" = 1;

        "fs.file-max" = 2097152;
        "fs.inotify.max_user_watches" = 524288;

        "net.core.rmem_max" = 2500000;
        "net.core.wmem_max" = 2500000;
        "net.core.rmem_default" = 1048576;
        "net.core.wmem_default" = 1048576;
        "net.ipv4.tcp_fastopen" = 3;
        "net.ipv4.tcp_congestion_control" = "bbr";

        "kernel.pid_max" = 4194304;

        "kernel.unprivileged_userns_clone" = 1;
      };

      kernelModules = ["binder_linux" "ashmem_linux"];
    };
  };
}
