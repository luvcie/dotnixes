{
  ##########
  # INPUTS #
  ##########

  inputs = {
    # Core
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.0.tar.gz";

    # Lix
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.92.0-3.tar.gz";
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

    homeConfigurations."lucie" =
      let
        pkgs = import inputs.nixpkgs {
          system = "x86_64-linux";
		  config = { allowUnfree = true; };
          overlays = [ ];
        };
      in
      inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit inputs pkgs;
        };
        modules = inputs.ashley-dotfiles.homeModules ++ [
          ./home.nix
          inputs.nixvim.homeManagerModules.nixvim
        ];
      };
  };
}

