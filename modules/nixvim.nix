  { config, lib, pkgs, ... }:
{

programs.nixvim = {
    enable = true;
    colorschemes.catppuccin.enable = true;
    plugins.lualine.enable = true;
    plugins.wezterm.enable = true;
    plugins.snacks.enable = true;
    plugins.telescope.enable = true;
    plugins.web-devicons.enable = true;
    plugins.dashboard.enable = true;
    plugins.treesitter = {
      enable = true;
      grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        bash
        json
        lua
        markdown
        nix
        regex
        xml
        yaml
        c
      ];
    };
  };
}
