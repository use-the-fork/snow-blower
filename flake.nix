{
  description = "snow-blower";

  inputs = {
    # global, so they can be `.follow`ed
    systems.url = "github:nix-systems/default-linux";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    treefmt-nix.url = "github:numtide/treefmt-nix";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    process-compose-flake.url = "github:Platonic-Systems/process-compose-flake";
    flake-root.url = "github:srid/flake-root";

    git-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = inputs @ {flake-parts, ...}: let
    bootstrap =
      inputs.flake-parts.lib.mkFlake {
        inherit inputs;
        moduleLocation = ./flake.nix;
      } ({...}: {
        imports = [
          ./modules/common.nix
          ./modules/options-document.nix
        ];
        systems = import inputs.systems;
      });
  in
    inputs.flake-parts.lib.mkFlake {inherit inputs;} ({...}: {
      imports = [
        bootstrap.flakeModules.common
        bootstrap.flakeModules.optionsDocument
      ];

      flake =
        bootstrap
        // {
          flakeModule.default = bootstrap.flakeModules.common;
        };
    });
}
