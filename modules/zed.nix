{
  config,
  pkgs,
  lib,
  ...
}: let
  customLib = import ../lib/default.nix;
in {
  programs.zed-editor = {
    enable = true;
    package = config.lib.nixGL.wrap pkgs.zed-editor;

    userSettings = customLib.fromJsonFile ./zed/settings.json;
    userKeymaps = customLib.fromJsonFile ./zed/keymap.json;

    # allow editing configs in zed itself
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
}
