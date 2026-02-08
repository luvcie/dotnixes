{
  ##########
  # INPUTS #
  ##########

  inputs = {
    # Core
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.925861.tar.gz";

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

    sops-nix = {
      url = "github:Mic92/sops-nix";
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

    nixosConfigurations.T495 = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      modules = [
        inputs.nur.modules.nixos.default
        ./hosts/T495/configuration.nix
        ./hosts/T495/hardware-configuration.nix
        {
          nixpkgs.config.allowUnfree = true;
        }
      ];
    };

    #######################
    # Home Configuration  #
    #######################

    homeConfigurations."weew" = let
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
          ./hosts/proxmox-lab/home.nix
          inputs.nixvim.homeModules.nixvim
          inputs.sops-nix.homeManagerModules.sops
        ];
      };

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
          ./hosts/T495/home.nix
          inputs.nixvim.homeModules.nixvim
        ];
        #modules = inputs.ashley-dotfiles.homeModules ++ [
        #  ./home.nix
        #  inputs.nixvim.homeManagerModules.nixvim
        #];
      };
  };
}
