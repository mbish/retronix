{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.retronix.systems.gba;
  subtypes = import ../common-subtypes.nix {inherit lib config;};
  shortName = "gba";
in
  with lib; {
    options.retronix.systems.gba =
      subtypes.systemSubmodule
      // {
        enable = lib.mkEnableOption "Nintendo Game Boy Advance System";
        shortName = mkOption {
          default = shortName;
        };
        emulationstationName = mkOption {
          default = "Game Boy Advance";
        };
        pegasusName = mkOption {
          default = "Game Boy Advance";
        };
        skyscraperName = mkOption {
          default = shortName;
        };
        extensions = mkOption {
          default = ["gba"];
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
