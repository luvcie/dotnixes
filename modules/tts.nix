{pkgs, ...}: let
  # misaki (kokoro's G2P) calls spacy.cli.download at runtime, which shells
  # out to uv/pip and fails on nix. Put the model in the closure instead.
  kokoro-fixed = pkgs.python314Packages.kokoro.overridePythonAttrs (o: {
    dependencies =
      (o.dependencies or [])
      ++ [pkgs.python314Packages.spacy-models.en_core_web_sm];
  });
in {
  #####################
  # TEXT TO SPEECH    #
  #####################

  home.packages = with pkgs; [
    espeak
    piper-tts
    kokoro-fixed

    # espeak-style one-shot TTS: `say hello there` or `cmd | say`.
    # piper ignores -c and always reads <model>.onnx.json, so both files
    # have to be in the same directory, hence linkFarm.
    (writeShellScriptBin "say" ''
      { [ $# -gt 0 ] && printf '%s\n' "$*" || cat; } \
        | ${piper-tts}/bin/piper --output-raw -m ${linkFarm "piper-voice-lessac" {
        "en_US-lessac-medium.onnx" = fetchurl {
          url = "https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/lessac/medium/en_US-lessac-medium.onnx";
          hash = "sha256-Xv4J5pkCGHgnr2RuGm6dJp3udp+Yd9F7FrG0buqvAZ8=";
        };
        "en_US-lessac-medium.onnx.json" = fetchurl {
          url = "https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/lessac/medium/en_US-lessac-medium.onnx.json";
          hash = "sha256-7+GcQXvtBV8taZCCSMa6ZQ+hNbyGiw5quz2hgdq2kKA=";
        };
      }}/en_US-lessac-medium.onnx \
        | ${alsa-utils}/bin/aplay -q -r 22050 -f S16_LE -c 1 -
    '')

    # same as `say` but through kokoro: nicer voice, ~15s/sentence on CPU.
    # kokoro can only write a WAV file, so buffer to a temp file and play it.
    (writeShellScriptBin "sayk" ''
      f=$(mktemp --suffix=.wav)
      trap 'rm -f "$f" "$f.log"' EXIT
      { [ $# -gt 0 ] && printf '%s\n' "$*" || cat; } \
        | ${kokoro-fixed}/bin/kokoro -o "$f" >"$f.log" 2>&1 \
        || { cat "$f.log" >&2; exit 1; }
      ${alsa-utils}/bin/aplay -q "$f"
    '')
  ];
}
