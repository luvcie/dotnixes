{
  pkgs,
  ...
}: {

  # Use ashley's config module (yes i know its confusingly called 'neovim'
  neovim.enable = true;

  # Extra configuration for neovim
  programs.neovim = {

    #enable = true;
    # Sets alias vim=nvim
    #vimAlias = true;

    plugins = with pkgs.vimPlugins; [
         {
        plugin = vim-be-good;
        type = "lua";
        config = ''
          require('vim-be-good')
        '';
      }
         {
        plugin = nvim-notify;
        type = "lua";
        config = ''
          require('nvim-notify')
        '';
      }
         {
        plugin = pkgs.music-controls-nvim;
        type = "lua";
        config = ''
          require('pkgs.music-controls-nvim')
          default_player = 'elisa'
        '';
      }
    ];
  };
}
