{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.retronix.systems.ps2;
  subtypes = import ../common-subtypes.nix {inherit lib config;};
  shortName = "ps2";
in
  with lib; {
    options.retronix.systems.ps2 =
      subtypes.systemSubmodule
      // {
        enable = lib.mkEnableOption "Sony Playstation 2 System";
        shortName = mkOption {
          default = shortName;
        };
        emulationstationName = mkOption {
          default = "Sony Playstation 2";
        };
        pegasusName = mkOption {
          default = "Playstation 2";
        };
        skyscraperName = mkOption {
          default = shortName;
        };
        extensions = mkOption {
          default = ["iso" "cue" "img" "mdf" "z" "z2" "bz2" "dump" "cso" "ima" "gz" "chd"];
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
