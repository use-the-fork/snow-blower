{
  inputs,
  flake-parts-lib,
  ...
}: {
  imports = [
    inputs.flake-parts.flakeModules.flakeModules
  ];
  flake.flakeModules.integrations = {
    options.perSystem = flake-parts-lib.mkPerSystemOption ({
      pkgs,
      config,
      lib,
      ...
    }: let
      inherit (lib) types mkOption;
      inherit (import ../utils.nix {inherit lib;}) mkIntegration;
      inherit (import ./utils.nix {inherit lib pkgs;}) commandType;

      cfg = config.snow-blower.integrations.aider;

      yamlFormat = pkgs.formats.yaml {};
    in {
      imports = [
        {
          options.snow-blower.integrations.aider.commands = mkOption {
            type = types.submoduleWith {
              modules = [{freeformType = types.attrsOf commandType;}];
              specialArgs = {inherit pkgs;};
            };
            default = {};
            description = ''
              The aider start commands that we can run with just.
            '';
          };
        }
      ];

      options.snow-blower.integrations.aider = mkIntegration {
        name = "Aider";
        package = pkgs.aider-chat;

        settings = {
          auto-commits = mkOption {
            description = "Enable/disable auto commit of LLM changes.";
            default = false;
            type = types.bool;
          };

          dirty-commits = mkOption {
            description = "Enable/disable commits when repo is found dirty";
            default = true;
            type = types.bool;
          };

          auto-lint = mkOption {
            description = "Enable/disable automatic linting after changes";
            default = true;
            type = types.bool;
          };

          dark-mode = mkOption {
            description = "Use colors suitable for a dark terminal background.";
            default = true;
            type = types.bool;
          };

          light-mode = mkOption {
            description = "Use colors suitable for a light terminal background";
            default = false;
            type = types.bool;
          };

          cache-prompts = mkOption {
            description = "Enable caching of prompts.";
            default = false;
            type = types.bool;
          };

          code-theme = mkOption {
            description = "Set the markdown code theme";
            default = "default";
            type = types.enum ["default" "monokai" "solarized-dark" "solarized-light"];
          };

          edit-format = mkOption {
            description = "Set the markdown code theme";
            default = "diff";
            type = types.enum ["whole" "diff" "diff-fenced" "udiff"];
          };

          extraConf = mkOption {
            type = types.submodule {freeformType = yamlFormat.type;};
            default = {};
            description = ''
              Extra configuration for aider, see
              <link xlink:href="See settings here: https://aider.chat/docs/config/aider_conf.html"/>
              for supported values.
            '';
          };
        };
      };

      config = lib.mkIf cfg.enable {
        snow-blower = {
          packages = [
            cfg.package
          ];

          shell = {
            startup = let
              cfgWithoutExcludedKeys = lib.attrsets.filterAttrs (name: _value: name != "conventions" && name != "extraConf" && name != "port" && name != "host") cfg.settings;
              cfgWithExtraConf = lib.attrsets.recursiveUpdate cfgWithoutExcludedKeys (cfg.settings.extraConf
                // {
                  check-update = false;
                });

              aiderYml = yamlFormat.generate "aider-conf" cfgWithExtraConf;
            in [
              ''
                ln -sf ${builtins.toString aiderYml} ./.aider.conf.yml
              ''
            ];
          };

          just.recipes = lib.mkMerge (lib.mapAttrsToList (
              name: cmdCfg: {
                "ai-${name}" = {
                  enable = true;
                  justfile = ''
                    # ${cmdCfg.description}
                    @ai-${name}:
                      ${lib.getExe cfg.package} ${lib.concatStringsSep " " (lib.filter (s: s != "") [
                      "--model ${cmdCfg.model}"
                      (
                        if cmdCfg.watchFiles
                        then "--watch-files"
                        else "--no-watch-files"
                      )
                      (
                        if cmdCfg.suggestShellCommands
                        then "--suggest-shell-commands"
                        else "--no-suggest-shell-commands"
                      )
                      (
                        if cmdCfg.detectUrls
                        then "--detect-urls"
                        else "--no-detect-urls"
                      )
                      (
                        if cmdCfg.gitCommitVerify
                        then "--git-commit-verify"
                        else "--no-git-commit-verify"
                      )
                      (lib.concatMapStringsSep " " (cmd: "--read \"${cmd}\"") cmdCfg.readFiles)
                      (lib.concatMapStringsSep " " (cmd: "--lint-cmd \"${cmd}\"") cmdCfg.lintCommands)
                      (lib.concatMapStringsSep " " (cmd: "--test-cmd \"${cmd}\"") cmdCfg.testCommands)
                      cmdCfg.extraArgs
                    ])}
                  '';
                };
              }
            )
            cfg.commands);
        };
      };
    });
  };
}
