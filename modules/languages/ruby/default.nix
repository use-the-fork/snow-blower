{
  inputs,
  flake-parts-lib,
  ...
}: {
  imports = [
    inputs.flake-parts.flakeModules.flakeModules
  ];
  flake.flakeModules.languages = {
    options.perSystem = flake-parts-lib.mkPerSystemOption ({
      lib,
      pkgs,
      config,
      ...
    }: let
      inherit (lib) types mkOption literalExpression;

      cfg = config.snow-blower.languages.ruby;
    in {
      options.snow-blower.languages.ruby = {
        enable = lib.mkEnableOption "tools for Ruby development";

        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.ruby;
          defaultText = lib.literalExpression "pkgs.ruby";
          description = "The Ruby package to use.";
        };

        bundler = {
          enable = lib.mkEnableOption "bundler";
          package = lib.mkOption {
            type = lib.types.package;
            default = pkgs.bundler.override {ruby = cfg.package;};
            defaultText = lib.literalExpression "pkgs.bundler.override { ruby = cfg.package; }";
            description = "The bundler package to use.";
          };
        };
      };

      config.snow-blower = lib.mkIf cfg.enable {
        languages.ruby = {
          bundler.enable = lib.mkDefault true;
        };

        env = {
          BUNDLE_PATH = config.snow-blower.env.PROJECT_STATE + "/.bundle";
          GEM_HOME = "${config.snow-blower.env.BUNDLE_PATH}/${cfg.package.rubyEngine}/${cfg.package.version.libDir}";
        };

        packages =
          lib.optional cfg.bundler.enable cfg.bundler.package
          ++ [
            cfg.package
          ];
      };
    });
  };
}
