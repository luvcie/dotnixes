{
  lib,
  stdenv,
  stdenvNoCC,
  autoPatchelfHook,
  fetchFromGitHub,
  fetchurl,
  makeWrapper,
  # endcord's pyproject sets python_last_safe = "3.13.14"; pin rather than
  # follow the python3 alias, since the dave-py wheel below is cp313-only.
  python313,
  aspell,
  aspellDicts,
  git,
  libnotify,
  mpv,
  pulseaudio,
  wl-clipboard,
  xclip,
  xdg-utils,
  yt-dlp,
}: let
  # libdave bindings (Discord's E2EE for voice), not in nixpkgs. The manylinux
  # wheel patchelfs fine, so no CMake build. x86_64+cp313 only, so swap the
  # url and hash if either moves.
  dave-py = python313.pkgs.buildPythonPackage {
    pname = "dave-py";
    version = "1.0.0";
    format = "wheel";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/51/86/837680b93df4d15c4cf7ba080ce64258780ebc12fc9d50dcc8d868b7c4b4/dave_py-1.0.0-cp313-cp313-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl";
      hash = "sha256-eah1j7L1hco8N/4C/XkFt3kMDnQ02XVEZooKh8f26kw=";
    };
    nativeBuildInputs = [autoPatchelfHook];
    buildInputs = [stdenv.cc.cc.lib];
    pythonImportsCheck = ["dave"];
    meta.license = lib.licenses.mit;
  };

  py = python313.withPackages (ps:
    with ps; [
      # [project.dependencies]
      websocket-client
      python-socks
      orjson
      soundcard
      soundfile
      numpy
      pycryptodome
      # [dependency-groups.media] - inline images, video playback, voice calls
      av
      pillow
      pynacl
      dave-py
    ]);
in
  # endcord has no [build-system]; setup.py only builds the optional
  # endcord_cython accelerators, which every call site guards with find_spec.
  # Nothing to install, so drop the tree in $out and point an interpreter at it.
  stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "endcord";
    version = "1.5.3";

    src = fetchFromGitHub {
      owner = "sparklost";
      repo = "endcord";
      tag = finalAttrs.version;
      hash = "sha256-QYcVOdIXxGeGEdY7kNG2ugcn/x2yOptbFaQx7mtmJJs=";
    };

    nativeBuildInputs = [makeWrapper];

    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/endcord
      cp -r endcord main.py themes LICENSE $out/share/endcord/

      makeWrapper ${py.interpreter} $out/bin/endcord \
        --add-flags $out/share/endcord/main.py \
        --prefix PATH : ${lib.makeBinPath [
        aspell
        git
        libnotify # notify-send
        mpv
        pulseaudio # paplay
        wl-clipboard
        xclip
        xdg-utils # xdg-open
        yt-dlp
      ]} \
        --set-default ASPELL_CONF "dict-dir ${aspellDicts.en}/lib/aspell"

      runHook postInstall
    '';

    meta = {
      description = "Feature rich Discord TUI client";
      homepage = "https://github.com/sparklost/endcord";
      # source-available: redistribution of modified versions is not permitted
      license = lib.licenses.unfree;
      mainProgram = "endcord";
      platforms = ["x86_64-linux"];
    };
  })
