{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.retronix.emulators.flycast;
  subtypes = import ../common-subtypes.nix {inherit lib config;};
  retronix = config.retronix;
  retronix-utils = import ../../lib {inherit pkgs;};
in
  with lib; {
    options.retronix.emulators.flycast =
      subtypes.emulationSubmodule
      // {
        enable = mkEnableOption "Flycast personal configuration";
        emu-cfg = mkOption {
          type = types.path;
          description = "Flycast configuration file";
          default = ./emu.cfg;
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
                  type = types.str;
                };
              };
            });
          description = "A set of 'mapping' files for flycast controller configurations";
          default = [
            {
              name = "SDL_Virtual Gamepad (MoltenGamepad)";
              config = builtins.readFile ./moltengamepad.cfg;
            }
          ];
        };
        systems = mkOption {
          default = ["dreamcast"];
        };
        launchCommand = mkOption {
          default = "${pkgs.flycast}/bin/flycast -config window:fullscreen=yes {{gamepath}}";
        };
      };

    config = let
      config-file = retronix-utils.templateFileToFile "emu.cfg" cfg.emu-cfg {
        romPath = head retronix.systems.dreamcast.romPaths;
      };
    in
      mkIf cfg.enable (mkMerge [
        (subtypes.commonEmulationConfig cfg)
        {
          xdg.configFile = let
            mappings = map (x: {"flycast/mappings/${x.name}.cfg".text = x.config;}) cfg.mappings;
          in
            mkMerge ([
                {
                  "flycast/emu.cfg" = {
                    source = config-file;
                    force = cfg.forceOverwrites;
                  };
                }
              ]
              ++ mappings);
          home.activation = {
            flycastSymlink =
              lib.hm.dag.entryBetween ["linkGeneration" "installPackages"] ["makeConfig"]
              ''
                mkdir -p ${retronix.saveDirectory}/flycast
                mkdir -p ${config.home.homeDirectory}/.local/share
                ln -sTf ${retronix.saveDirectory}/flycast ${config.home.homeDirectory}/.local/share/flycast
              '';
          };
        }
      ]);
  }
