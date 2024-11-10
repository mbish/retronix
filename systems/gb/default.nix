{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.retronix.systems.gb;
  subtypes = import ../common-subtypes.nix {inherit lib config;};
  shortName = "gb";
in
  with lib; {
    options.retronix.systems.gb =
      subtypes.systemSubmodule
      // {
        enable = lib.mkEnableOption "Nintendo Game Boy System";
        shortName = mkOption {
          default = shortName;
        };
        emulationstationName = mkOption {
          default = "Game Boy";
        };
        pegasusName = mkOption {
          default = "Game Boy";
        };
        skyscraperName = mkOption {
          default = shortName;
        };
        extensions = mkOption {
          default = ["gb"];
        };
      };
    config =
      mkIf cfg.enable
      (mkMerge [
        (subtypes.commonConfig cfg)
        {
        }
      ]);
  }
