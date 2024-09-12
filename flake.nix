{
  inputs = {
    music-controls-nvim-src = {
     url = "github:AntonVanAssche/music-controls.nvim";
     flake = false;
    };

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
    lobster = {
      url = "github:justchokingaround/lobster";
    };
    ashley-dotfiles = {
    url = "github:ashe/dotfiles/";
    inputs.nixpkgs.follows = "nixpkgs";
    };
    umu = {
      url = "git+https://github.com/Open-Wine-Components/umu-launcher/?dir=packaging\/nix&submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs: {
    nixosConfigurations.nixos = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      modules = [
        inputs.nur.nixosModules.nur
        ./configuration.nix
        ./hardware-configuration.nix
      ];
    };
    homeConfigurations."lucie" = inputs.home-manager.lib.homeManagerConfiguration {
  pkgs = import inputs.nixpkgs {
    system = "x86_64-linux";
    overlays = [
    (prev: final:
      {
        music-controls-nvim = prev.vimUtils.buildVimPlugin {
          pname = "music-controls-nvim";
          src = inputs.music-controls-nvim-src;
          version = "master";
        };
      }
    )
  ];
};
      extraSpecialArgs = {inherit inputs;};

      # Specify your home configuration modules here, for example,
      # the path to your home.nix.
      modules = inputs.ashley-dotfiles.homeModules ++ [
        inputs.nur.nixosModules.nur
        ./home.nix
        ./neovim.nix
      ];

      # Optionally use extraSpecialArgs
      # to pass through arguments to home.nix
    };
  };
}
