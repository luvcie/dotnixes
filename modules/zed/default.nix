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
    userSettings = customLib.fromJsonFile ./settings.json;
    userKeymaps = customLib.fromJsonFile ./keymap.json;

    mutableUserSettings = true;
    mutableUserKeymaps = true;
    mutableUserTasks = true;

    extensions = [
      # themes
      "tokyo-night"

      # languages
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
  ];
}
