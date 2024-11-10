{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.retronix.systems.saturn;
  subtypes = import ../common-subtypes.nix {inherit lib config;};
  name = "Saturn";
  shortName = "saturn";
in
  with lib; {
    options.retronix.systems.saturn =
      subtypes.systemSubmodule
      // {
        enable = lib.mkEnableOption "Sega Saturn System";
        shortName = mkOption {
          default = shortName;
        };
        emulationstationName = mkOption {
          default = "Sega Saturn";
        };
        pegasusName = mkOption {
          default = "Saturn";
        };
        skyscraperName = mkOption {
          default = shortName;
        };
        extensions = mkOption {
          default = ["cue" "iso" "mdf" "chd" "m3u"];
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
