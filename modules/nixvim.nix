
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    wl-clipboard
  ];

  programs.nixvim = {
    enable = true;
    enableMan = true;
    viAlias = true;
    vimAlias = true;

    clipboard.providers.wl-copy.enable = true;
    colorschemes.oxocarbon.enable = true;

    globals = {
      mapleader = " ";
    };

    opts = {
      encoding = "utf-8";
      nu = true;
      relativenumber = true;
      hlsearch = false;
      belloff = "all";
      swapfile = false;
      undofile = true;
      scrolloff = 8;
      ff = "unix";
      autoindent = true;
      clipboard = "unnamedplus";
      smarttab = true;
      expandtab = false;
      shiftwidth = 4;
      tabstop = 4;
      softtabstop = 4;
      splitright = true;
      splitbelow = true;
    };

    keymaps = [
      # your keymaps remain unchanged
      # ... (omitted for brevity)
    ];

    plugins = {
      cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          snippet = {
            expand = "function(args) require('luasnip').lsp_expand(args.body) end";
          };
          sources = [
            { name = "nvim_lsp"; }
            { name = "luasnip"; }
            { name = "path"; }
            { name = "buffer"; }
          ];
          mapping = {
            __raw = ''
              cmp.mapping.preset.insert({
                ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                ['<C-Space>'] = cmp.mapping.complete(),
                ['<C-e>'] = cmp.mapping.abort(),
                ['<CR>'] = cmp.mapping.confirm({ select = true }),
              })
            '';
          };
        };
        cmdline = {
          "/" = {
            mapping = {
              __raw = "cmp.mapping.preset.cmdline()";
            };
            sources = [
              { name = "buffer"; }
            ];
          };
          ":" = {
            mapping = {
              __raw = "cmp.mapping.preset.cmdline()";
            };
            sources = [
              { name = "path"; }
              {
                name = "cmdline";
                option = {
                  ignore_cmds = [ "Man" "!" ];
                };
              }
            ];
          };
        };
      };

      lsp = {
        enable = true;
        servers = {
          ansiblels.enable = true;
          bashls.enable = true;
          terraformls.enable = true;
          pyright.enable = true;
          gopls.enable = true;
          dockerls.enable = true;
          nixd.enable = true;
          lua_ls.enable = true;
          ccls.enable = true;
        };
      };

      lualine = {
        enable = true;
        settings = {
          options = {
            theme = "ayu_mirage";
          };
        };
      };

      which-key.enable = true;

      telescope = {
        enable = true;
        keymaps = {
          "<Leader>ff" = { action = "find_files"; };
          "<Leader>fg" = { action = "live_grep"; };
          "<Leader>fb" = { action = "buffers"; };
          "<Leader>f?" = { action = "help_tags"; };
          "<Leader>fm" = { action = "marks"; };
          "<Leader>gg" = { action = "git_files"; };
          "<Leader>gc" = { action = "git_commits"; };
          "<Leader>gb" = { action = "git_branches"; };
          "<Leader>gs" = { action = "git_status"; };
          "<Leader>ft" = { action = "treesitter"; };
        };
      };

      git-worktree = {
        enable = true;
        settings.autopush = true;
        enableTelescope = true;
      };

      treesitter.enable = true;
      autoclose.enable = true;
      fugitive.enable = true;
      colorizer.enable = true;
      vim-surround.enable = true;
      web-devicons.enable = true;
    };
  };
}
