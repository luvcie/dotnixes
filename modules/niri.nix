{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    grim
    slurp
    satty
    wl-clipboard
    brightnessctl
    pamixer
    wofi
	];

  home.sessionVariables = lib.mkDefault {
	XDG_CURRENT_DESKTOP = "niri";
	XDG_SESSION_DESKTOP = "niri";
  };
}
