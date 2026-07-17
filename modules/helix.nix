{pkgs, ...}: {
  # evil-helix (installed in home.nix) reads ~/.config/helix/languages.toml.
  # Helix detects .glsl/.frag/.vert as the "glsl" language but ships no server.
  #
  # Two servers attached to glsl:
  #   glsl_analyzer  - completion/hover/goto for bare .glsl (no shader stage).
  #                    Its LSP publishes NO diagnostics, so it gives no squiggles.
  #   efm            - runs `glsl_analyzer --parse-file` and turns the output into
  #                    LSP diagnostics = the squiggles. Refreshes on save (the
  #                    parse-file linter needs a real path, so no live linting).
  xdg.configFile."helix/languages.toml".text = ''
    [language-server.glsl_analyzer]
    command = "${pkgs.glsl_analyzer}/bin/glsl_analyzer"

    [language-server.efm]
    command = "${pkgs.efm-langserver}/bin/efm-langserver"

    [[language]]
    name = "glsl"
    language-servers = ["glsl_analyzer", "efm"]
  '';

  # Transparent editor background so kitty's transparency shows through.
  xdg.configFile."helix/config.toml".text = ''
    theme = "transparent"
  '';
  # Inherit the default theme (keeps all its colors) and blank ui.background so
  # the editing area has no bg. Swap "inherits" to any theme you prefer.
  xdg.configFile."helix/themes/transparent.toml".text = ''
    inherits = "default"
    "ui.background" = {}
  '';

  # efm-langserver reads this by default. ''${INPUT} is a literal ${INPUT} that
  # efm substitutes with the file path.
  xdg.configFile."efm-langserver/config.yaml".text = ''
    version: 2
    languages:
      glsl:
        - lint-command: '${pkgs.glsl_analyzer}/bin/glsl_analyzer --parse-file ''${INPUT}'
          lint-stdin: false
          lint-formats:
            - '%f:%l:%c: %m'
          lint-ignore-exit-code: true
  '';
}
