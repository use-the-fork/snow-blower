topLevel @ {
  inputs,
  flake-parts-lib,
  ...
}: {
  imports = [
    ./systems.nix
    inputs.flake-parts.flakeModules.flakeModules
  ];
  flake.flakeModules.nixpkgs = {
    imports = [
      topLevel.config.flake.flakeModules.systems
    ];
    options.perSystem = flake-parts-lib.mkPerSystemOption ({system, ...}: {
      imports = [
        "${inputs.nixpkgs}/nixos/modules/misc/nixpkgs.nix"
      ];
      nixpkgs.hostPlatform = system;
      nixpkgs.config.allowUnfree = true;
    });
  };
}
