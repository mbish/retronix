{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.retronix.systems.gamegear;
  subtypes = import ../common-subtypes.nix {inherit lib config;};
  shortName = "gamegear";
in
  with lib; {
    options.retronix.systems.gamegear =
      subtypes.systemSubmodule
      // {
        enable = lib.mkEnableOption "Sega Game Gear System";
        shortName = mkOption {
          default = shortName;
        };
        emulationstationName = mkOption {
          # TODO verify this is accurate
          default = "Sega Game Gear";
        };
        pegasusName = mkOption {
          default = "Game Gear";
        };
        skyscraperName = mkOption {
          default = shortName;
        };
        extensions = mkOption {
          default = ["gg"];
        };
      };
    config =
      mkIf
      cfg.enable
      (mkMerge [
        (subtypes.commonConfig cfg)
        {
        }
      ]);
  }
