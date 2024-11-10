{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.retronix.systems.wii;
  subtypes = import ../common-subtypes.nix {inherit lib config;};
  shortName = "wii";
in
  with lib; {
    options.retronix.systems.wii =
      subtypes.systemSubmodule
      // {
        enable = lib.mkEnableOption "Nintendo Wii System";
        shortName = mkOption {
          default = shortName;
        };
        emulationstationName = mkOption {
          default = "Nintendo Wii";
        };
        pegasusName = mkOption {
          default = "Wii";
        };
        skyscraperName = mkOption {
          default = shortName;
        };
        extensions = mkOption {
          default = ["iso" "cso" "gcz" "wbfs" "rvz"];
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
