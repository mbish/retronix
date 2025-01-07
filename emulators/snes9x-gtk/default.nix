{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.retronix.emulators.snes9x-gtk;
  snes9x = pkgs.snes9x.override {withGtk = true;};
  subtypes = import ../common-subtypes.nix {inherit lib config;};
  retronix = config.retronix;
  retronix-utils = import ../../lib {inherit pkgs;};
in
  with lib; {
    options.retronix.emulators.snes9x-gtk =
      subtypes.emulationSubmodule
      // {
        enable = mkEnableOption "Snes9x-Gtk personal configuration";
        config = mkOption {
          type = types.path;
          description = "Snes9x configuration file";
          default = ./snes9x-gtk.conf;
        };
        systems = mkOption {
          default = ["snes"];
        };
        launchCommand = mkOption {
          default = "${snes9x}/bin/snes9x-gtk {{gamepath}}";
        };
      };

    config = let
      configFile = retronix-utils.templateFileToFile "snes9x-gtk.conf" cfg.config {
        romPath = head retronix.systems.snes.romPaths;
        savePath = "${retronix.saveDirectory}/snes9x";
      };
    in
      mkIf cfg.enable (mkMerge [
        (subtypes.commonEmulationConfig cfg)
        {
          xdg.configFile."snes9x/snes9x.conf".source = configFile;
        }
      ]);
  }
