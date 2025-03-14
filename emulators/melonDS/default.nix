{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.retronix.emulators.melonDS;
  retronix = config.retronix;
  subtypes = import ../common-subtypes.nix {inherit lib config;};
  retronix-utils = import ../../lib {inherit pkgs;};
in
  with lib; {
    options.retronix.emulators.melonDS =
      subtypes.emulationSubmodule
      // {
        enable = mkEnableOption "MelonDS retronix configuration";
        systems = mkOption {
          default = ["nds"];
        };
        launchCommand = mkOption {
          default = "${pkgs.melonDS}/bin/melonDS -f {{gamepath}}";
        };
      };

    config = mkIf cfg.enable (mkMerge [
      (subtypes.commonEmulationConfig cfg)
      {
      }
    ]);
  }
