{
  pkgs,
  lib,
  config,
  ...
}: let
  yggDir = "${config.home.homeDirectory}/yggdrasil";
  podmanPath = "${config.home.homeDirectory}/.nix-profile/bin/podman";
  peers = [
    "tls://vpn.ltha.de:443"
    "tls://ygg1.mk16.de:1338"
    "tls://s2.i2pd.xyz:39575"
    "tls://23.137.249.65:444"
    "tls://23.184.48.86:993"
    "tls://mo.us.ygg.triplebit.org:993"
  ];

  # nix-built yggdrasil image (official docker image is stuck on 0.4.2)
  yggdrasilImage = pkgs.dockerTools.buildImage {
    name = "yggdrasil";
    tag = "latest";
    copyToRoot = pkgs.buildEnv {
      name = "yggdrasil-env";
      paths = with pkgs; [
        yggdrasil
        busybox
      ];
      pathsToLink = ["/bin"];
    };
    config = {
      Cmd = ["/bin/yggdrasil" "-useconf"];
      WorkingDir = "/";
    };
  };
  marker = "${config.home.homeDirectory}/.local/share/containers/yggdrasil-loaded";

  # nix-built socks5 proxy image
  proxyImage = pkgs.dockerTools.buildImage {
    name = "ygg-proxy";
    tag = "latest";
    copyToRoot = pkgs.buildEnv {
      name = "ygg-proxy-env";
      paths = with pkgs; [
        microsocks
      ];
      pathsToLink = ["/bin"];
    };
    config = {
      Cmd = ["/bin/microsocks" "-p" "1080"];
      WorkingDir = "/";
    };
  };
  proxyMarker = "${config.home.homeDirectory}/.local/share/containers/ygg-proxy-loaded";
in {
  # load container images during home-manager activation
  home.activation.loadYggdrasilImages = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p "$(dirname "${marker}")"
    if [ ! -f "${marker}" ] || [ "$(cat "${marker}")" != "${yggdrasilImage}" ]; then
      echo "loading yggdrasil container image..."
      ${podmanPath} load -i ${yggdrasilImage}
      echo "${yggdrasilImage}" > "${marker}"
    else
      echo "yggdrasil image unchanged, skipping load"
    fi
    if [ ! -f "${proxyMarker}" ] || [ "$(cat "${proxyMarker}")" != "${proxyImage}" ]; then
      echo "loading ygg-proxy container image..."
      ${podmanPath} load -i ${proxyImage}
      echo "${proxyImage}" > "${proxyMarker}"
    else
      echo "ygg-proxy image unchanged, skipping load"
    fi
  '';

  # yggdrasil config templated with sops (private key from vault)
  sops.templates."yggdrasil.conf" = {
    content = builtins.toJSON {
      PrivateKey = config.sops.placeholder.yggdrasil_private_key;
      Peers = peers;
      Listen = [];
      AdminListen = "unix:///var/run/yggdrasil.sock";
      MulticastInterfaces = [];
      AllowedPublicKeys = [];
      IfName = "auto";
      IfMTU = 65535;
      NodeInfoPrivacy = false;
      NodeInfo = {};
    };
  };

  # yggdrasil container service
  systemd.user.services.yggdrasil = {
    Unit = {
      Description = "yggdrasil mesh network";
      After = ["network.target" "sops-nix.service"];
    };
    Service = {
      Restart = "always";
      RestartSec = 5;
      ExecStartPre = [
        "-${pkgs.podman}/bin/podman stop yggdrasil-proxy"
        "-${pkgs.podman}/bin/podman rm yggdrasil-proxy"
        "-${pkgs.podman}/bin/podman stop yggdrasil"
        "-${pkgs.podman}/bin/podman rm yggdrasil"
      ];
      ExecStart = "${pkgs.podman}/bin/podman run --name yggdrasil "
        + "--cap-add=NET_ADMIN "
        + "--device=/dev/net/tun "
        + "--sysctl net.ipv6.conf.all.disable_ipv6=0 "
        + "--tmpfs /tmp "
        + "--tmpfs /var/run "
        + "-p 1080:1080 "
        + "-v ${config.xdg.configHome}/sops-nix/secrets/rendered/yggdrasil.conf:/etc/yggdrasil.conf:ro "
        + "localhost/yggdrasil:latest /bin/yggdrasil -useconffile /etc/yggdrasil.conf";
      ExecStop = "${pkgs.podman}/bin/podman stop yggdrasil";
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };

  # socks5 proxy for browsing yggdrasil sites from host
  # shares yggdrasil's network namespace so it can reach 200::/7 addresses
  systemd.user.services.yggdrasil-proxy = {
    Unit = {
      Description = "socks5 proxy for yggdrasil network";
      After = ["yggdrasil.service"];
      BindsTo = ["yggdrasil.service"];
    };
    Service = {
      Restart = "always";
      RestartSec = 5;
      ExecStartPre = [
        "-${pkgs.podman}/bin/podman stop yggdrasil-proxy"
        "-${pkgs.podman}/bin/podman rm yggdrasil-proxy"
      ];
      ExecStart = "${pkgs.podman}/bin/podman run --name yggdrasil-proxy "
        + "--network=container:yggdrasil "
        + "localhost/ygg-proxy:latest";
      ExecStop = "${pkgs.podman}/bin/podman stop yggdrasil-proxy";
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };
}
