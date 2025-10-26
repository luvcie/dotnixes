{
  ##########
  # INPUTS #
  ##########

  inputs = {
    # Core
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.0.tar.gz";

    # Lix
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/main.tar.gz";
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
    #    ashley-dotfiles = {
    #      url = "github:ashe/dotfiles/";
    #      inputs.nixpkgs.follows = "nixpkgs";
    #    };

    # Applications
    lobster = {
      url = "github:justchokingaround/lobster";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    linux-retroism = {
      url = "github:diinki/linux-retroism";
      flake = false;
    };

    millennium = {
      url = "git+https://github.com/SteamClientHomebrew/Millennium";
    };
  };

  ###########
  # OUTPUTS #
  ###########

  outputs = inputs: {
    ########################
    # System Configuration #
    ########################

    nixosConfigurations.T495 = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      modules = [
        inputs.nur.modules.nixos.default
        inputs.lix-module.nixosModules.default
        ./hosts/T495/configuration.nix
        ./hosts/T495/hardware-configuration.nix
        {
          nixpkgs.config.allowUnfree = true;
          nixpkgs.overlays = [
            inputs.millennium.overlays.default
          ];
        }
      ];
    };

    #######################
    # Home Configuration  #
    #######################

    homeConfigurations."lucie" = let
      pkgs = import inputs.nixpkgs {
        system = "x86_64-linux";
        config = {allowUnfree = true;};
        overlays = [];
      };
    in
      inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit inputs pkgs;
        };
        modules = [
          ./home.nix
          inputs.nixvim.homeModules.nixvim
        ];
        #modules = inputs.ashley-dotfiles.homeModules ++ [
        #  ./home.nix
        #  inputs.nixvim.homeManagerModules.nixvim
        #];
      };
  };
}
