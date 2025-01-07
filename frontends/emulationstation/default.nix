{
  config,
  lib,
  pkgs,
  ...
}: let
  retronix-utils = import ../../lib {inherit pkgs;};
  inputConfig = with lib;
  with types;
    submodule {
      options = {
        deviceName = mkOption {
          type = str;
          example = "Virtual Gamepad";
        };
        type = mkOption {
          type = str;
          example = "joystick";
        };
        deviceGUID = mkOption {
          type = str;
          example = "03000000010000000100000001000000";
          # TODO document how you find these
        };
        inputs = mkOption {
          type = listOf (submodule {
            options = {
              name = mkOption {
                type = str;
                example = "a";
              };
              type = mkOption {
                type = str;
                example = "button";
              };
              id = mkOption {
                type = str;
                example = 1;
              };
              value = mkOption {
                type = str;
                example = 1;
              };
            };
          });
        };
      };
    };
  cfg = config.retronix.frontends.emulationstation;
  expand = command:
    builtins.replaceStrings
    ["{{gamepath}}" "{{basename}}"]
    # TODO this might need to change to %ROM_RAW%
    ["%ROM%" "%BASENAME%"]
    command;
  systemToString = system: "
      <system>
          <name>${system.name}</name>
          <fullname>${system.fullname}</fullname>
          <path>${system.path}</path>
          <extension>${builtins.concatStringsSep " " (map (x: ".${x}") system.extensions)}</extension>
          <command>${expand system.command}</command>
          <platform>${system.platform}</platform>
          <theme>${system.theme}</theme>
      </system>
    ";
  inputToString = input: "<input name=\"${input.name}\" type=\"${input.type}\" id=\"${input.id}\" value=\"${input.value}\"/>";

  inputConfigToString = inputConfig: "<inputConfig type=\"${inputConfig.type}\" deviceName=\"${inputConfig.deviceName}\" deviceGUID=\"${inputConfig.deviceGUID}\">
    ${builtins.concatStringsSep "\n      " (map inputToString inputConfig.inputs)}
  </inputConfig>";
in
  with lib; {
    options.retronix.frontends.emulationstation = {
      enable = mkEnableOption "Emulationstation config";
      user = mkOption {
        type = types.str;
        example = "testuer";
      };
      theme = mkOption {
        type = types.submodule {
          options = {
            name = mkOption {
              type = types.str;
              example = "Eudora Bigshot";
            };
            source = mkOption {
              type = lib.types.path;
              description = "Path to an emulationstation theme";
            };
          };
        };
      };
      systems = (
        let
          systemCfg = config.retronix.frontends.emulationstation.systems;
        in
          mkOption {
            type = with types;
              listOf (submodule ({localcfg, ...}: {
                options = {
                  name = mkOption {
                    type = str;
                    example = "snes";
                  };
                  fullname = mkOption {
                    type = str;
                    example = "Super Nintendo Enterntainment System";
                  };
                  path = mkOption {
                    type = path;
                    default = "";
                  };
                  extensions = mkOption {
                    type = listOf str;
                    example = ["sms" "sfc"];
                  };
                  command = mkOption {
                    type = str;
                    example = "mednafen %ROM%";
                  };
                  platform = mkOption {
                    type = str;
                    example = "snes";
                  };
                  theme = mkOption {
                    type = str;
                    example = "snes";
                  };
                };
              }));
          }
      );
      inputList = mkOption {
        type = types.listOf inputConfig;
        default = [
          {
            type = "joystick";
            deviceName = "Virtual Gamepad (MoltenGamepad)";
            deviceGUID = "03000000010000000100000001000000";
            inputs = [
              {
                name = "a";
                type = "button";
                id = "0";
                value = "1";
              }
              {
                name = "b";
                type = "button";
                id = "1";
                value = "1";
              }
              {
                name = "down";
                type = "button";
                id = "12";
                value = "1";
              }
              {
                name = "hotkeyenable";
                type = "button";
                id = "7";
                value = "1";
              }
              {
                name = "left";
                type = "button";
                id = "13";
                value = "1";
              }
              {
                name = "leftanalogdown";
                type = "axis";
                id = "1";
                value = "1";
              }
              {
                name = "leftanalogleft";
                type = "axis";
                id = "0";
                value = "-1";
              }
              {
                name = "leftanalogright";
                type = "axis";
                id = "0";
                value = "1";
              }
              {
                name = "leftanalogup";
                type = "axis";
                id = "1";
                value = "-1";
              }
              {
                name = "leftshoulder";
                type = "button";
                id = "4";
                value = "1";
              }
              {
                name = "leftthumb";
                type = "button";
                id = "9";
                value = "1";
              }
              {
                name = "lefttrigger";
                type = "axis";
                id = "2";
                value = "1";
              }
              {
                name = "right";
                type = "button";
                id = "14";
                value = "1";
              }
              {
                name = "rightanalogdown";
                type = "axis";
                id = "4";
                value = "1";
              }
              {
                name = "rightanalogleft";
                type = "axis";
                id = "3";
                value = "-1";
              }
              {
                name = "rightanalogright";
                type = "axis";
                id = "3";
                value = "1";
              }
              {
                name = "rightanalogup";
                type = "axis";
                id = "4";
                value = "-1";
              }
              {
                name = "rightshoulder";
                type = "button";
                id = "5";
                value = "1";
              }
              {
                name = "rightthumb";
                type = "button";
                id = "10";
                value = "1";
              }
              {
                name = "select";
                type = "button";
                id = "6";
                value = "1";
              }
              {
                name = "start";
                type = "button";
                id = "7";
                value = "1";
              }
              {
                name = "up";
                type = "button";
                id = "11";
                value = "1";
              }
              {
                name = "x";
                type = "button";
                id = "2";
                value = "1";
              }
              {
                name = "y";
                type = "button";
                id = "3";
                value = "1";
              }
            ];
          }
          {
            type = "keyboard";
            deviceName = "Keyboard";
            deviceGUID = "-1";
            inputs = [
              {
                name = "a";
                type = "key";
                id = "97";
                value = "1";
              }
              {
                name = "b";
                type = "key";
                id = "98";
                value = "1";
              }
              {
                name = "down";
                type = "key";
                id = "1073741905";
                value = "1";
              }
              {
                name = "left";
                type = "key";
                id = "1073741904";
                value = "1";
              }
              {
                name = "lefttrigger";
                type = "axis";
                id = "122";
                value = "1";
              }
              {
                name = "right";
                type = "key";
                id = "1073741903";
                value = "1";
              }
              {
                name = "righttrigger";
                type = "key";
                id = "120";
                value = "1";
              }
              {
                name = "select";
                type = "key";
                id = "115";
                value = "1";
              }
              {
                name = "start";
                type = "key";
                id = "13";
                value = "1";
              }
              {
                name = "up";
                type = "key";
                id = "1073741906";
                value = "1";
              }
              {
                name = "x";
                type = "key";
                id = "120";
                value = "1";
              }
              {
                name = "y";
                type = "key";
                id = "121";
                value = "1";
              }
            ];
          }
        ];
      };
      skyscraperName = mkOption {
        type = types.str;
        description = "Name of the skyscraper frontend to use for this frontend";
        default = "emulationstation";
      };
    };

    config = mkIf cfg.enable (mkMerge [
      {
        home.file = {
          ".emulationstation/es_systems.cfg".text = ''
            <!-- This is the EmulationStation Systems configuration file.
            All systems must be contained within the <systemList> tag.-->

            <systemList>
            ${builtins.concatStringsSep "\n" (map systemToString cfg.systems)}
            </systemList>
          '';
          ".emulationstation/es_settings.cfg".source = retronix-utils.templateFileToFile "es_settings.cfg" ./es_settings.cfg {
            configDir = "${config.home.homeDirectory}/.emulationstation";
            themeName = cfg.theme.name;
          };
        };
      }
      (mkIf ((length cfg.inputList) != 0) {
        home.file.".emulationstation/es_input.cfg".text = ''
          <?xml version="1.0"?>
          <inputList>
            ${builtins.concatStringsSep "\n" (map inputConfigToString cfg.inputList)}
          </inputList>
        '';
      })
      {
        home.file = mkMerge [
          {
            ".emulationstation/themes/${cfg.theme.name}".source = cfg.theme.source;
          }
        ];
      }
    ]);
  }
