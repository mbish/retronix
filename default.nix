{inputs, ...}: {
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.retronix;
  mednafenSubmodule = with lib; {
    options = {
      core = mkOption {
        type = types.str;
        description = "Mednafen core to use";
      };
      config = mkOption {
        type = types.path;
        description = "Per-core override config to use for mednafen";
      };
    };
  };
  sources = inputs;
in
  with lib; {
    imports = [
      ./systems
      ./emulators
      ./launchers
      ./retroarch
      ./frontends
      ./scrapers
      ./organizers
      ./backups
      ./input-managers
    ];
    options.retronix = {
      enable = mkEnableOption "Retronix module for retro gaming on nix";
      frontend = mkOption {
        type = types.str;
        description = "Frontend to launch for retronix";
      };
      romDirectory = mkOption {
        type = types.path;
        description = "Path for ROM data";
        default = "${config.home.homeDirectory}/retronix/roms";
      };
      saveDirectory = mkOption {
        type = types.path;
        description = "Location to put save data and save states for backup";
        default = "${config.home.homeDirectory}/retronix/saves";
      };
      metadataDirectory = mkOption {
        type = types.path;
        description = "Path for system and rom metadata";
        default = "${config.home.homeDirectory}/retronix/metadata";
      };
      backupDirectory = mkOption {
        type = types.path;
        description = "Location for save file backups";
        default = "${config.home.homeDirectory}/retronix/backup";
      };
      inputs = mkOption {
        type = types.anything;
      };
      forceOverwrites = mkOption {
        type = types.bool;
        description = "Force overwrite of emulation configuration files";
        default = false;
      };
    };
    # how can we support different rom manager backends?
    # dat files can all get put onto retronix.dats which can then be parsed by the manager

    # I think we use oneOf and just declare emulator subtypes
    # you should only need a certain set of things for each emulator and system
    config =
      mkIf cfg.enable
      {
        retronix.inputs = mkDefault sources;
        retronix.scrapers.skyscraper = {
          inherit (cfg) frontend;
          metadataPath = cfg.metadataDirectory;
        };
        home.file = {
          "${config.xdg.configHome}/.exists".text = "";
          "${cfg.metadataDirectory}/.exists".text = "";
          "${cfg.romDirectory}/.exists".text = "";
          "${cfg.saveDirectory}/.exists".text = "";
          "${cfg.backupDirectory}/.exists".text = "";
        };
        home.packages = [
          pkgs.pegasus-frontend
          pkgs.gamelauncher
          pkgs.mp64-convert
          pkgs.skyscraper
        ];
      };
  }
