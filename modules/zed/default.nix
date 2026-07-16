{
  config,
  lib,
  pkgs,
  ...
}: let
  customLib = import ../../lib/default.nix;
in {
  programs.zed-editor = {
    enable = true;
    package = config.lib.nixGL.wrap pkgs.zed-editor;
    userSettings =
      (customLib.fromJsonFile ./settings.json)
      // {
        # c/c++ use the built-in clangd integration, but the auto-downloaded
        # binary cannot run on nixos, so point zed at the nixpkgs clangd.
        lsp.clangd.binary.path = "${pkgs.clang-tools}/bin/clangd";
        # same story for clojure-lsp: use the nixpkgs binary.
        lsp.clojure-lsp.binary.path = "${pkgs.clojure-lsp}/bin/clojure-lsp";
        # glsl: the "glsl" extension provides the language + glsl_analyzer LSP,
        # but its auto-downloaded binary won't run on nixos, so pin the nixpkgs one.
        lsp.glsl_analyzer.binary.path = "${pkgs.glsl_analyzer}/bin/glsl_analyzer";
      };
    userKeymaps = customLib.fromJsonFile ./keymap.json;

    mutableUserSettings = true;
    mutableUserKeymaps = true;
    mutableUserTasks = true;

    extensions = [
      # themes
      "tokyo-night"

      # languages
      "clojure"
      "glsl"
      "haskell"
      "haxe"
      "html"
      "latex"
      "lua"
      "neocmake"
      "nix"
      "scss"
    ];
  };

  home.packages = with pkgs; [
    nerd-fonts.fira-code

    # c/c++ toolchain + lsp (clangd)
    clang-tools # clangd, clang-format
    gcc # cc/g++ compilers

    clojure-lsp # clojure lsp
    # clojure cli + jdk17 already live in home.nix, so they cover the repl.
    # for zed's live eval (jupyter-backed repl), install the clojupyter kernel
    # once (it isn't in nixpkgs):
    #   clojure -Sdeps '{:deps {clojupyter/clojupyter {:mvn/version "0.3.3"}}}' \
    #     -M -m clojupyter.cmdline install
    # writes a kernel to ~/.local/share/jupyter/kernels that zed auto-discovers.
    # then: cursor on form -> ctrl-shift-enter.
  ];
}
