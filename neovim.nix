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
        plugin = vim-pathogen;
        type = "lua";
        config = ''
          require('vim-pathogen').setup({})
        '';
      }
    ];
  };
}
