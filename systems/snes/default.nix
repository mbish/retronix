{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.retronix.systems.snes;
  subtypes = import ../common-subtypes.nix {inherit lib config;};
  shortName = "snes";
in
  with lib; {
    options.retronix.systems.snes =
      subtypes.systemSubmodule
      // {
        enable = lib.mkEnableOption "Super Nintendo Entertainment System";
        shortName = mkOption {
          default = shortName;
        };
        emulationstationName = mkOption {
          default = "Sega Game Gear";
        };
        pegasusName = mkOption {
          default = "Super Nintendo";
        };
        skyscraperName = mkOption {
          default = shortName;
        };
        extensions = mkOption {
          default = ["smc" "sfc" "fig" "swc" "mgd" "bin"];
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
