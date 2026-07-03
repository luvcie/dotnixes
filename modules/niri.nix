{
  config,
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    grim
    slurp
    satty
    wl-clipboard
    brightnessctl
    pamixer
    xwayland-satellite
  ];

  home.sessionVariables = lib.mkDefault {
  };
}
