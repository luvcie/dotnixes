{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";     
    }; 
	lobster.url = "github:justchokingaround/lobster";
  };
  outputs = inputs: {
    nixosConfigurations.nixos = inputs.nixpkgs.lib.nixosSystem { 
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
	  modules = [ 
        ./configuration.nix
        ./hardware-configuration.nix 
      ];
    };
  };
}
