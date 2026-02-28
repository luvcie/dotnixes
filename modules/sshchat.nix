{
  pkgs,
  lib,
  config,
  ...
}: let
  dataDir = "${config.home.homeDirectory}/sshchat";

  sshchatPkg = pkgs.stdenv.mkDerivation rec {
    pname = "ssh-chat";
    version = "1.10";
    src = pkgs.fetchurl {
      url = "https://github.com/shazow/ssh-chat/releases/download/v${version}/ssh-chat-linux_amd64.tgz";
      hash = "sha256-oFuShjlpfq5WURtn7VpBTqaTDLILJBcdGpN03XQjZSI=";
    };
    dontBuild = true;
    dontConfigure = true;
    unpackPhase = ''
      tar -xzf $src
    '';
    installPhase = ''
      mkdir -p $out/bin
      cp ssh-chat/ssh-chat $out/bin/ssh-chat
    '';
  };
in {
  home.file."sshchat/motd".text = ''
    welcome to luvcie's chat
    type /help for commands
  '';

  # generate a persistent host key on first activation so users don't get
  # host-changed warnings when the service restarts or the config is rebuilt
  home.activation.sshchatInit = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p "${dataDir}"
    if [ ! -f "${dataDir}/host_key" ]; then
      echo "generating sshchat host key..."
      ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -f "${dataDir}/host_key" -N ""
    fi
  '';

  systemd.user.services.sshchat = {
    Unit = {
      Description = "ssh-chat server";
      After = ["network.target"];
    };
    Service = {
      ExecStart = "${sshchatPkg}/bin/ssh-chat --identity ${dataDir}/host_key --bind :2222 --motd ${dataDir}/motd";
      Restart = "always";
      RestartSec = 5;
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };
}
