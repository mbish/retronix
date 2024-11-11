{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.retronix.emulators.rpcs3;
  subtypes = import ../common-subtypes.nix {inherit lib config;};
  retronix = config.retronix;
in
  with lib; {
    options.retronix.emulators.rpcs3 =
      subtypes.emulationSubmodule
      // {
        enable = mkEnableOption "RPCS3 retronix configuration";
        config-input = mkOption {
          type = types.path;
          description = "Input configuration file";
          default = ./config_input.yml;
        };
        config = mkOption {
          type = types.path;
          description = "System configuration file";
          default = ./config.yml;
        };
        firmware = mkOption {
          type = types.path;
          description = "PS3 firmware file";
        };
        mappings = mkOption {
          type = with types;
            listOf (submodule {
              options = {
                name = mkOption {
                  type = types.str;
                  example = "generic controller";
                };
                config = mkOption {
                  type = types.path;
                  description = "YAML file for control configuration";
                };
              };
            });
          description = "A set of 'mapping' files for RPCS3 controller configurations";
          default = [
            {
              name = "Virtual Gamepad";
              config = ./VirtualGamepad.yml;
            }
            {
              name = "Default";
              config = ./default_input.yml;
            }
          ];
        };
        systems = mkOption {
          default = ["ps3"];
        };
        launchCommand = mkOption {
          default = "${pkgs.rpcs3}/bin/rpcs3 --no-gui {{gamedir}}/{{basename}}";
        };
      };

    config = let
      savePath = "${retronix.saveDirectory}/rpcs3";
    in
      mkIf cfg.enable (mkMerge [
        (subtypes.commonEmulationConfig cfg)
        {
          nixpkgs.config.allowUnfree = true;
          home.file = let
            mappings = map (x: {"${savePath}/input_configs/global/${x.name}.yml".source = x.config;}) cfg.mappings;
          in
            mkMerge ([
                {
                  "${savePath}/config_input.yml".source = cfg.config-input;
                  # TODO have some guided installation process for first-time setup
                  "${savePath}/PS3UPDAT.PUP".source = cfg.firmware;
                  "${savePath}/config.yml".source = cfg.config;
                }
              ]
              ++ mappings);
          home.activation = {
            rpcs3Symlink =
              lib.hm.dag.entryBetween ["linkGeneration" "installPackages"] ["makeConfig"]
              ''
                mkdir -p ${savePath}
                ln -sTf ${savePath} ${config.xdg.configHome}/rpcs3
              '';
          };
        }
      ]);
  }
