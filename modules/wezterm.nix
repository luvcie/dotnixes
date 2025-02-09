  { config, lib, pkgs, ... }:

with lib;

{
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      return {
        hide_tab_bar_if_only_one_tab = true,
        color_scheme = "Unikitty Dark (base16)",
        front_end = "WebGpu",
      }
    '';
  };
}
