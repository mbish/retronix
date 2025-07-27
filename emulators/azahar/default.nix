{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.retronix.emulators.azahar;
  retronix = config.retronix;
  subtypes = import ../common-subtypes.nix {inherit lib config;};
  retronix-utils = import ../../lib {inherit pkgs;};
in
  with lib; {
    options.retronix.emulators.azahar =
      subtypes.emulationSubmodule
      // {
        enable = mkEnableOption "Azahar retronix configuration";
        systems = mkOption {
          default = ["3ds"];
        };
        launchCommand = mkOption {
          default = "${pkgs.azahar}/bin/azhar -f {{gamepath}}";
        };
      };

    config = mkIf cfg.enable (mkMerge [
      (subtypes.commonEmulationConfig cfg)
      {
      }
    ]);
  }
