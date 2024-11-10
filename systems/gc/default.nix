{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.retronix.systems.gc;
  subtypes = import ../common-subtypes.nix {inherit lib config;};
  shortName = "gc";
in
  with lib; {
    options.retronix.systems.gc =
      subtypes.systemSubmodule
      // {
        enable = lib.mkEnableOption "Nintendo Gamecube System";
        shortName = mkOption {
          default = shortName;
        };
        emulationstationName = mkOption {
          default = "Nintendo Gamecube";
        };
        pegasusName = mkOption {
          default = "Gamecube";
        };
        skyscraperName = mkOption {
          default = shortName;
        };
        extensions = mkOption {
          default = ["iso" "cso" "gcz" "gcm" "m3u" "rvz"];
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
