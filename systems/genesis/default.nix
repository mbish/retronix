{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.retronix.systems.genesis;
  subtypes = import ../common-subtypes.nix {inherit lib config;};
  shortName = "genesis";
in
  with lib; {
    options.retronix.systems.genesis =
      subtypes.systemSubmodule
      // {
        enable = lib.mkEnableOption "Sega Genesis System";
        shortName = mkOption {
          default = shortName;
        };
        emulationstationName = mkOption {
          default = "Sega Genesis";
        };
        pegasusName = mkOption {
          default = "Megadrive";
        };
        skyscraperName = mkOption {
          default = shortName;
        };
        extensions = mkOption {
          default = ["smd" "bin" "gen" "md" "sg"];
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
