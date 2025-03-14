{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.retronix.systems.nds;
  subtypes = import ../common-subtypes.nix {inherit lib config;};
  shortName = "nds";
in
  with lib; {
    options.retronix.systems.nds =
      subtypes.systemSubmodule
      // {
        enable = lib.mkEnableOption "Nintendo DS";
        shortName = mkOption {
          default = shortName;
        };
        emulationstationName = mkOption {
          default = "Nintendo DS";
        };
        pegasusName = mkOption {
          default = "Nintendo DS";
        };
        skyscraperName = mkOption {
          default = shortName;
        };
        extensions = mkOption {
          default = ["nds"];
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
