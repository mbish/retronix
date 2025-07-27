{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.retronix.systems._3ds;
  subtypes = import ../common-subtypes.nix {inherit lib config;};
  shortName = "3ds";
in
  with lib; {
    options.retronix.systems._3ds =
      subtypes.systemSubmodule
      // {
        enable = lib.mkEnableOption "Nintendo 3DS";
        shortName = mkOption {
          default = shortName;
        };
        emulationstationName = mkOption {
          default = "Nintendo 3DS";
        };
        pegasusName = mkOption {
          default = "Nintendo 3DS";
        };
        skyscraperName = mkOption {
          default = shortName;
        };
        extensions = mkOption {
          default = ["3ds"];
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
