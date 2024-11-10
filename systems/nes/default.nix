{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.retronix.systems.nes;
  subtypes = import ../common-subtypes.nix {inherit lib config;};
  name = "NES";
  shortName = "nes";
in
  with lib; {
    options.retronix.systems.nes =
      subtypes.systemSubmodule
      // {
        enable = lib.mkEnableOption "Nintendo Entertainment System";
        shortName = mkOption {
          default = shortName;
        };
        emulationstationName = mkOption {
          default = "Nintendo Entertainment System";
        };
        pegasusName = mkOption {
          default = "NES";
        };
        skyscraperName = mkOption {
          default = shortName;
        };
        extensions = mkOption {
          default = ["nes" "smc" "sfc" "fig" "swc" "mgd"];
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
