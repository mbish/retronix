{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.retronix.emulators.ares;
  configDirectory = "${config.xdg.dataHome}/ares";
  subtypes = import ../common-subtypes.nix {inherit lib config;};
  retronix = config.retronix;
  retronix-utils = import ../../lib {inherit pkgs;};
in
  with lib; {
    options.retronix.emulators.ares =
      subtypes.emulationSubmodule
      // {
        enable = mkEnableOption "Ares personal configuration";
        config = mkOption {
          type = types.path;
          description = "The full settings.bml configuration";
          default = ./settings.bml;
        };
        systems = mkOption {
          default = ["n64"];
        };
        launchCommand = mkOption {
          default = "${pkgs.ares}/bin/ares --fullscreen {{gamepath}}";
        };
      };
    config = let
      configFile = retronix-utils.templateFileToFile "settings.bml" cfg.config {
        savePath = "${retronix.saveDirectory}/ares/";
      };
    in
      mkIf cfg.enable
      (mkMerge [
        (subtypes.commonEmulationConfig cfg)
        {
          home.file = mkMerge [
            {
              "${configDirectory}/settings.bml" = {
                source = configFile;
                force = cfg.forceOverwrites;
              };
            }
          ];
        }
      ]);
  }
