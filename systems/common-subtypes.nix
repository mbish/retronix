{
  lib,
  config,
  ...
}: let
  retronix = config.retronix;
in
  with lib; rec {
    systemWithBios =
      systemSubmodule
      // {
        bios = mkOption {
          type = types.path;
          description = "Path to BIOS file for system";
        };
      };
    systemSubmodule = {
      name = mkOption {
        type = types.listOf types.str;
        description = "Name of the system";
      };
      shortName = mkOption {
        type = types.listOf types.str;
        description = "Abbreviated name of the system";
      };
      emulationStationName = mkOption {
        type = types.str;
        description = "Name emulationstation uses for the system";
      };
      pegasusName = mkOption {
        type = types.str;
        description = "Name pegasus uses for the system";
      };
      skyscraperName = mkOption {
        type = types.str;
        description = "Name skyscraper uses for the system";
      };
      extensions = mkOption {
        type = types.listOf types.str;
        description = "List of file extensions to use to identify games";
        default = [];
        example = ["bin" "iso"];
      };
      launchCommand = mkOption {
        type = types.str;
        description = "Command to run when launching game";
      };
      romPaths = mkOption {
        type = types.listOf types.path;
        description = "Paths to rom directories";
      };
      datFiles = mkOption {
        type = types.listOf types.path;
        description = "DAT files to use to identify ROMs for system";
        default = [];
      };
    };
    commonConfig = cfg: {
      retronix.frontends.pegasus-frontend = {
        collections = [
          {
            inherit (cfg) extensions;
            name = cfg.pegasusName;
            launch = cfg.launchCommand;
          }
        ];
        gamedirs = cfg.romPaths ++ ["${retronix.metadataDirectory}/${cfg.shortName}"];
      };
      retronix.frontends.emulationstation.systems = [
        {
          name = cfg.shortName;
          fullname = cfg.emulationstationName;
          path = head cfg.romPaths;
          extensions = cfg.extensions;
          command = cfg.launchCommand;
          platform = cfg.shortName;
          theme = cfg.shortName;
        }
      ];
      retronix.scrapers.skyscraper.systems = [
        {
          # This isn't always shortName for things like the genesis
          system = cfg.skyscraperName;
          paths = cfg.romPaths;
        }
      ];
    };
    mkSystemSubmodule = extraOptions: {
      options = systemSubmodule // extraOptions;
    };
  }
