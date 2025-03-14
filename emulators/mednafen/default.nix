{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.retronix.emulators.mednafen;
  configDirectory = "${config.xdg.configHome}/mednafen";
  subtypes = import ../common-subtypes.nix {inherit lib config;};
  retronix = config.retronix;
  retronix-utils = import ../../lib {inherit pkgs;};
in
  with lib; {
    options.retronix.emulators.mednafen =
      subtypes.emulationSubmodule
      // {
        enable = mkEnableOption "Mednafen personal configuration";
        config = mkOption {
          type = types.path;
          description = "The full mednafen.cfg configuration";
          default = ./main.cfg;
        };
        systemOverrides = mkOption {
          type = with types;
            listOf (submodule {
              options = {
                core = mkOption {
                  type = str;
                  example = "sms";
                };
                config = mkOption {
                  type = str;
                };
              };
            });
          default = [];
        };
        psxBiosPath = mkOption {
          type = types.nullOr types.path;
          description = "Location for the PSX bios file";
          default = null;
        };
        systems = mkOption {
          default = ["gb" "gbc" "gba" "genesis" "saturn" "gamegear" "nes" "psx"];
        };
        launchCommand = mkOption {
          default = "${pkgs.mednafen}/bin/mednafen {{gamepath}}";
        };
      };
    config = let
      configFile = retronix-utils.templateFileToFile "main.cfg" cfg.config {
        savePath = "${retronix.saveDirectory}/mednafen";
        biosPath = cfg.psxBiosPath;
      };
    in
      mkIf cfg.enable
      (mkMerge [
        (subtypes.commonEmulationConfig cfg)
        {
          home.file = mkMerge (
            [
              {
                "${configDirectory}/mednafen.cfg" = {
                  source = configFile;
                  force = cfg.forceOverwrites;
                };
              }
            ]
            ++ (map (x: {"${configDirectory}/${x.core}.cfg".text = x.config;}) cfg.systemOverrides)
          );
        }
        # TODO this is probably unnecessary now
        {
          systemd.user.services.mednafen-config = {
            Unit.Description = "Copy over mednafen config";
            Service = {
              Type = "oneshot";
              ExecStart = "${pkgs.rsync}/bin/rsync -Lpr --chmod=F644 ${configDirectory}/ ${config.home.homeDirectory}/.mednafen";
              StandardOutput = "journal+console";
              StandardError = "journal+console";
            };
            Install.WantedBy = ["default.target"];
          };
        }
      ]);
  }
