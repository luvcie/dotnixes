{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";     
    }; 
    nur.url = "github:nix-community/NUR";
    lobster = {
      url = "github:justchokingaround/lobster";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    telescope = {
      url = "github:StardustXR/telescope";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    envision = {
      url = "gitlab:Scrumplex/envision/nix"; # NOTE: This is pointing to the branch of MR 11: https://gitlab.com/gabmus/envision/-/merge_requests/11. Once merged, the url should be updated to "gitlab:gabmus/envision"
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs: {
    nixosConfigurations.nixos = inputs.nixpkgs.lib.nixosSystem { 
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
	  modules = [ 
        inputs.nur.nixosModules.nur
        ./configuration.nix
        ./hardware-configuration.nix 
      ];
    };
    homeConfigurations."lucie" = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
      extraSpecialArgs = { inherit inputs; };

      # Specify your home configuration modules here, for example,
      # the path to your home.nix.
      modules = [ 
        inputs.nur.nixosModules.nur
        ./home.nix 
      ];

      # Optionally use extraSpecialArgs
      # to pass through arguments to home.nix
    };
  };
}
