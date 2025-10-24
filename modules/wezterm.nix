{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  programs.wezterm = {
    enable = true;
    extraConfig = ''
           return {
             hide_tab_bar_if_only_one_tab = true,
             color_scheme = "Unikitty Dark (base16)",
      window_background_opacity = 0.86,
             front_end = "WebGpu",
           }
    '';
  };
}
