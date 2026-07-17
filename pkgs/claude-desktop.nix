{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, dpkg
, buildFHSEnv
, runCommand
, gtk3
, libnotify
, nss
, at-spi2-atk
, libdrm
, mesa
, libxcb
, libsecret
, libxtst
, alsa-lib
, util-linux
, libappindicator-gtk3
, OVMF
, virtiofsd
}:

let
  unwrapped = stdenv.mkDerivation rec {
    pname = "claude-desktop-unwrapped";
    version = "1.22209.0";

    src = fetchurl {
      url = "https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop/claude-desktop_${version}_amd64.deb";
      hash = "sha256-bRiueSwr3a0B7cl8LD9M9IkATO/o/tZ2Cmlu0lxJv2E=";
    };

    nativeBuildInputs = [ autoPatchelfHook dpkg ];

    buildInputs = [
      gtk3 libnotify nss at-spi2-atk libdrm mesa libxcb
      libsecret libxtst alsa-lib util-linux libappindicator-gtk3
    ];

    autoPatchelfIgnoreMissingDeps = true;

    unpackPhase = "dpkg-deb --fsys-tarfile $src | tar -x --no-same-permissions";
    sourceRoot = ".";

    installPhase = ''
      mkdir -p $out/lib $out/share
      cp -r usr/lib/claude-desktop $out/lib/claude-desktop
      rm -f $out/lib/claude-desktop/chrome-sandbox
      cp -r usr/share/applications $out/share/
      cp -r usr/share/icons $out/share/
    '';
  };

  # claude-desktop hardcodes /usr/share/OVMF/ and /usr/libexec/virtiofsd;
  # structure here matches what buildFHSEnv maps to /usr/
  fhsExtras = runCommand "claude-desktop-fhs-extras" {} ''
    mkdir -p $out/share/OVMF $out/libexec
    ln -s ${OVMF.fd}/FV/OVMF_CODE.fd $out/share/OVMF/OVMF_CODE.fd
    ln -s ${OVMF.fd}/FV/OVMF_VARS.fd $out/share/OVMF/OVMF_VARS.fd
    ln -s ${virtiofsd}/bin/virtiofsd $out/libexec/virtiofsd
  '';
in
buildFHSEnv {
  name = "claude-desktop";

  targetPkgs = _pkgs: [
    unwrapped
    fhsExtras
    gtk3 libnotify nss at-spi2-atk libdrm mesa libxcb
    libsecret libxtst alsa-lib util-linux libappindicator-gtk3
  ];

  extraInstallCommands = ''
    mkdir -p $out/share
    ln -s ${unwrapped}/share/applications $out/share/applications
    ln -s ${unwrapped}/share/icons $out/share/icons
  '';

  runScript = "${unwrapped}/lib/claude-desktop/claude-desktop --no-sandbox";

  meta = with lib; {
    description = "Desktop application for Claude.ai";
    homepage = "https://claude.ai";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "claude-desktop";
  };
}
