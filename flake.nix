{

  ##########
  # INPUTS #
  ##########

  inputs = {
    # Core
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Lix
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.92.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # User Environment Management
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix User Repository
    nur.url = "github:nix-community/NUR";

    # Additional Repositories
    ashley-dotfiles = {
      url = "github:ashe/dotfiles/";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Applications
    lobster = { 
      url = "github:justchokingaround/lobster";
    };

    # Nixvim
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  ###########
  # OUTPUTS #
  ###########

  outputs = inputs: {

    ########################
    # System Configuration #
    ########################

    nixosConfigurations.nixosthinkpad = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        inputs.nur.modules.nixos.default
	inputs.lix-module.nixosModules.default
        ./configuration.nix
        ./hardware-configuration.nix
      ];
    };

    #######################
    # Home Configuration  #
    #######################

    homeConfigurations."lucie" = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        system = "x86_64-linux";
        # Overlay for custom packages
        overlays = [
          (prev: final: {
            # Neovim plugin build
            music-controls-nvim = prev.vimUtils.buildVimPlugin {
              pname = "music-controls-nvim";
              src = inputs.music-controls-nvim-src;
              version = "master";
            };
          })
        ];
      };

      # Pass inputs to modules
      extraSpecialArgs = { inherit inputs; };

      # Home-manager modules
      modules =
        inputs.ashley-dotfiles.homeModules ++ [
          ./home.nix
        ];
    };
  };
}
