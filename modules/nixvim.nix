{
  pkgs,
  lib,
  config,
  ...
}: let
  fortyTwoHeaderRepo = pkgs.fetchFromGitHub {
    owner = "42paris";
    repo = "42header";
    rev = "master";
    sha256 = "sha256-WflranTZgaAoRTBqHsRuQEdvL15fv21ZRX77BzDMg0I=";
  };

  fortyTwoHeaderPlugin = pkgs.vimUtils.buildVimPlugin {
    name = "42header-vim";
    src = fortyTwoHeaderRepo;
  };
in {
  home.packages = with pkgs; [
    wl-clipboard
  ];

  programs.nixvim = {
    enable = true;
    enableMan = true;
    viAlias = true;
    vimAlias = true;

    extraPlugins = [
      fortyTwoHeaderPlugin
    ];

    clipboard.providers.wl-copy.enable = true;
    colorschemes.oxocarbon.enable = true;

    globals = {
      mapleader = " ";
      user42 = "lucpardo";
      mail42 = "lucpardo@student.42.fr";
    };

    extraConfigVim = ''

    '';

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
      {
        key = "<leader>e";
        action = "<cmd>NvimTreeToggle<cr>";
      }
      {
        key = "<leader>h";
        action = "<C-w>h";
      }
      {
        key = "<leader>j";
        action = "<C-w>j";
      }
      {
        key = "<leader>k";
        action = "<C-w>k";
      }
      {
        key = "<leader>l";
        action = "<C-w>l";
      }
      {
        key = "<leader>q";
        action = "<cmd>q!<cr>";
      }
      {
        key = "<leader>w";
        action = "<cmd>w<cr>";
      }
      {
        key = "<leader><leader>";
        action = "<cmd>so %<cr>";
      }
      {
        key = "<C-s>";
        mode = "i";
        action = "<esc><cmd>w<cr>a";
      }
      {
        key = "Y";
        action = "y$";
      }
      {
        key = "n";
        action = "nzzzv";
      }
      {
        key = "N";
        action = "Nzzzv";
      }
      {
        key = "J";
        action = "mzJ`z";
      }
      {
        key = "<C-d>";
        action = "<C-d>zz";
      }
      {
        key = "<C-u>";
        action = "<C-u>zz";
      }
      {
        key = "<leader>v";
        action = "<cmd>vsplit<cr>";
      }
      {
        key = "<leader>s";
        action = "<cmd>split<cr>";
      }
      {
        key = "<esc>";
        mode = "t";
        action = "<C-\\><C-n>";
      }
      {
        key = "<leader>tn";
        action = "<cmd>tabnew<cr>";
      }
      {
        key = "<leader>tc";
        action = "<cmd>tabclose<cr>";
      }
      {
        key = "<leader>to";
        action = "<cmd>tabonly<cr>";
      }
      {
        key = "<leader>tp";
        action = "<cmd>tabp<cr>";
      }
      {
        key = "<leader>tbn";
        action = "<cmd>tabn<cr>";
      }
      {
        key = "<leader>u";
        action = "<cmd>UndotreeToggle<CR>";
      }
      {
        key = "<leader>r";
        action = "<cmd>lua vim.lsp.buf.rename()<CR>";
      }
      {
        key = "<leader>ca";
        action = "<cmd>lua vim.lsp.buf.code_action()<CR>";
      }
      {
        key = "<leader>gd";
        action = "<cmd>lua vim.lsp.buf.definition()<CR>";
      }
      {
        key = "<leader>gr";
        action = "<cmd>lua vim.lsp.buf.references()<CR>";
      }
      {
        key = "<leader>gi";
        action = "<cmd>lua vim.lsp.buf.implementation()<CR>";
      }
      {
        key = "<leader>gh";
        action = "<cmd>lua vim.lsp.buf.hover()<CR>";
      }
      {
        key = "<leader>gs";
        action = "<cmd>lua vim.diagnostic.open_float()<CR>";
      }
      {
        key = "<leader>cp";
        action = "<cmd>lua vim.diagnostic.goto_prev()<CR>";
      }
      {
        key = "<leader>cn";
        action = "<cmd>lua vim.diagnostic.goto_next()<CR>";
      }
      {
        key = "<F1>";
        action = "<cmd>Stdheader<CR>";
      }
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
            {name = "nvim_lsp";}
            {name = "luasnip";}
            {name = "path";}
            {name = "buffer";}
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
              {name = "buffer";}
            ];
          };
          ":" = {
            mapping = {
              __raw = "cmp.mapping.preset.cmdline()";
            };
            sources = [
              {name = "path";}
              {
                name = "cmdline";
                option = {
                  ignore_cmds = ["Man" "!"];
                };
              }
            ];
          };
        };
      };

      lsp = {
        enable = true;
        servers = {
          # ansiblels.enable = true;  # Disabled due to missing package
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
          "<Leader>ff" = {action = "find_files";};
          "<Leader>fg" = {action = "live_grep";};
          "<Leader>fb" = {action = "buffers";};
          "<Leader>f?" = {action = "help_tags";};
          "<Leader>fm" = {action = "marks";};
          "<Leader>gg" = {action = "git_files";};
          "<Leader>gc" = {action = "git_commits";};
          "<Leader>gb" = {action = "git_branches";};
          "<Leader>gs" = {action = "git_status";};
          "<Leader>ft" = {action = "treesitter";};
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
      nvim-tree = {
        enable = true;
        settings.view = {
          width = 30;
          side = "left";
        };
      };
      undotree.enable = true;
      luasnip.enable = true;
      cmp-nvim-lsp.enable = true;
      cmp-buffer.enable = true;
      cmp-path.enable = true;
      cmp-cmdline.enable = true;
      cmp_luasnip.enable = true;
    };
  };
}
