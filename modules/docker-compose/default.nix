{
  inputs,
  flake-parts-lib,
  ...
}: {
  imports = [
    inputs.flake-parts.flakeModules.flakeModules
  ];
  flake.flakeModules.docker-compose = {
    options.perSystem = flake-parts-lib.mkPerSystemOption ({
      lib,
      pkgs,
      config,
      ...
    }: let
      inherit (lib) types mkOption;
      inherit (import ./utils.nix {inherit lib pkgs;}) serviceType;

      yamlFormat = pkgs.formats.yaml {};

      # Project state directory for volume mounts
      PROJECT_STATE = toString config.snow-blower.paths.state;
    in {
      imports = [
        {
          options.snow-blower.docker-compose.services = mkOption {
            type = types.submoduleWith {
              modules = [{freeformType = types.attrsOf serviceType;}];
              specialArgs = {inherit pkgs;};
            };
            default = {};
            description = ''
              The services that are available to docker-compose
            '';
          };
        }
      ];

      options.snow-blower.docker-compose = {
        fileName = mkOption {
          type = types.str;
          default = "docker-compose.yml";
          description = ''
            The name of the docker-compose file generated by this module.
          '';
        };
      };

      config.snow-blower = {
        packages = [
          pkgs.docker-compose
        ];

        shell = {
          startup = let
            composeServices =
              lib.mapAttrs (_name: service: service.outputs.service)
              config.snow-blower.docker-compose.services;

            # Extract volume names from service definitions
            volumeNames = lib.unique (lib.flatten (
              lib.mapAttrsToList (
                _name: service:
                  if service.enable && service.volumes != []
                  then
                    map (
                      v: let
                        parts = lib.splitString ":" v;
                      in
                        if builtins.length parts > 1
                        then lib.head parts
                        else null
                    )
                    (lib.filter (v: !(lib.hasPrefix "./" v) && !(lib.hasPrefix "/" v)) service.volumes)
                  else []
              )
              config.snow-blower.docker-compose.services
            ));

            # Create volume configuration
            volumes = lib.listToAttrs (map (name: {
                inherit name;
                value = {
                  driver_opts = {
                    type = "none";
                    o = "bind";
                    device = "${PROJECT_STATE}/${name}";
                  };
                };
              })
              (lib.filter (v: v != null) volumeNames));

            composeConfig = {
              services = composeServices;
              volumes =
                volumes
                // {
                  tailscale_state = {
                    driver_opts = {
                      type = "none";
                      o = "bind";
                      device = "${PROJECT_STATE}/tailscale_state";
                    };
                  };
                };
            };

            composeFile = yamlFormat.generate config.snow-blower.docker-compose.fileName composeConfig;
          in [
            ''
              ln -sf ${builtins.toString composeFile} ./${config.snow-blower.docker-compose.fileName}
            ''
          ];
        };
      };
    });
  };
}
