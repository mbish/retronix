{
  lib,
  config,
  system,
  pkgs,
  ...
}: let
  inherit (config) retronix;
  cfg = config.retronix.launchers.gamelauncher;
  expand = command:
    builtins.replaceStrings
    ["{{gamepath}}" "{{gamedir}}" "{{basename}}"]
    ["{file.path}" "{file.dir}" "{file.basename}"]
    command;
  common = import ../common.nix {inherit lib config pkgs;};
in
  with lib; {
    options.retronix.launchers.gamelauncher = {
      enable = mkEnableOption "use simple JSON configured gamelauncher";
      configuration = mkOption {
        type = types.nullOr lib.types.path;
        description = "Path to gamelauncher JSON config file";
        default = null;
      };
      command = mkOption {
        type = lib.types.path;
        description = "Path to the gamelauncher binary";
        default = "${config.retronix.inputs.gamelauncher.packages."${system}".default}/bin/gamelauncher";
      };
      wrapper = mkOption {
        type = types.nullOr types.path;
        description = "Wrapper for command to allow for monitoring events";
        default = null;
      };
      systems = mkOption {
        type = types.attrsOf (types.submodule {
          options = {
            command = mkOption {
              type = types.str;
              example = "/usr/local/bin/emulator --fullscreen {file.path}";
              description = "Full launch command including variables";
            };
            name = mkOption {
              type = lib.types.str;
              example = "MAME";
              description = "short code for identifying system";
            };
            overrides = mkOption {
              type = types.listOf (types.submodule {
                options = {
                  name = mkOption {
                    type = lib.types.str;
                    description = "Name of the ROM to override launch command of (matches stem only)";
                    example = "2048";
                  };
                  command = mkOption {
                    type = lib.types.str;
                    description = "Alternative command for running specific ROM";
                    example = "/usr/local/bin/other-emulator --resolution 1080x1920 {file.path}";
                  };
                };
              });
              default = [];
            };
          };
        });
        default = {};
        description = "set of systems to generate launch commands for";
      };
    };
    config = let
      launcherSystems = retronix.launchers.systems;
      configPath = "${config.xdg.configHome}/gamelauncher/config.json";
      command =
        if cfg.wrapper != null
        then "${cfg.wrapper} ${cfg.command}"
        else cfg.command;
    in
      mkIf cfg.enable {
        # Loop through all systems in config.retronix.systems and set their launch commands to
        retronix.systems =
          builtins.mapAttrs (k: v: {
            launchCommand = lib.mkDefault "${command} -s ${k} -g {{gamepath}} -i ${configPath}";
          })
          launcherSystems;

        # Generate JSON file with module configuration
        home.file.${configPath} =
          if cfg.configuration == null
          then {
            text = builtins.toJSON (
              builtins.attrValues (builtins.mapAttrs (k: v: {
                  system = k;
                  command = expand v.command;
                  precommands = common.preLaunchHooks k;
                  postcommands = common.postLaunchHooks k;
                  overrides =
                    if builtins.elem k (attrNames cfg.systems)
                    then cfg.systems.${k}.overrides
                    else [];
                })
                launcherSystems)
            );
          }
          else {
            source = cfg.configuration;
          };
      };
  }
