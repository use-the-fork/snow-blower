# The importApply argument. Use this to reference things defined locally,
# as opposed to the flake where this is imported.
_localFlake:
# Regular module arguments; self, inputs, etc all reference the final user flake,
# where this module was imported.
{...}: {
  imports = [
    ./modules/files.nix
  ];

  perSystem = _: {
    # A copy of hello that was defined by this flake, not the user's flake.
    # packages.greeter = localFlake.withSystem system ({ config, ... }:
    #   config.packages.default
    # );
  };
}
