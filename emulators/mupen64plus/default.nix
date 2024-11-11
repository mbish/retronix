{
  config,
  pkgs,
  lib,
  utils,
  ...
}: let
  cfg = config.retronix.emulators.mupen64plus;
  retronix = config.retronix;
  subtypes = import ../common-subtypes.nix {inherit lib config;};
in
  with lib; {
    options.retronix.emulators.mupen64plus =
      subtypes.emulationSubmodule
      // {
        enable = mkEnableOption "Mupen64plus retronix configuration";
        input-auto-config = mkOption {
          type = types.path;
          description = "mupen64plus automatic input configuration file";
          default = ./InputAutoCfg.ini;
        };
        config = mkOption {
          type = types.path;
          description = "mupen64plus system configuration file";
          default = ./mupen64plus.cfg;
        };
        sharedData = mkOption {
          type = types.path;
          description = "Directory for mupen64plus shared data";
          default = "${pkgs.mupen64plus}/share/mupen64plus";
        };
        resolution = mkOption {
          type = lib.types.str;
          default = "1920x1080";
        };
        systems = mkOption {
          default = ["n64"];
        };
        launchCommand = mkOption {
          default = "${pkgs.mupen64plus}/bin/mupen64plus --nosaveoptions --datadir ${config.xdg.configHome}/mupen64plus/data --configdir ${config.xdg.configHome}/mupen64plus --emumode 2 --noosd --fullscreen ${cfg.resolution} {{gamepath}}";
        };
      };

    config = let
      mupen64plusConfig = utils.templateFile "mupen64plus.cfg" cfg.config {
        inherit (cfg) sharedData;
        savePath = "${retronix.saveDirectory}/mupen64plus";
      };
    in
      mkIf cfg.enable (mkMerge [
        # TODO parameterize resolution
        # not sure all these args are necessary
        (subtypes.commonEmulationConfig cfg)
        {
          xdg.configFile."mupen64plus/data/InputAutoCfg.ini" = {
            source = cfg.input-auto-config;
            force = cfg.forceOverwrites;
          };
          xdg.configFile."mupen64plus/mupen64plus.cfg" = {
            source = mupen64plusConfig;
            force = cfg.forceOverwrites;
          };
        }
      ]);
  }
