{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.retronix.systems.n64;
  subtypes = import ../common-subtypes.nix {inherit lib config;};
  shortName = "n64";
in
  with lib; {
    options.retronix.systems.n64 =
      subtypes.systemSubmodule
      // {
        enable = lib.mkEnableOption "Nintendo 64 System";
        shortName = mkOption {
          default = shortName;
        };
        emulationstationName = mkOption {
          default = "Nintendo 64";
        };
        pegasusName = mkOption {
          default = "Nintendo 64";
        };
        skyscraperName = mkOption {
          default = shortName;
        };
        extensions = mkOption {
          default = ["z64" "n64" "v64"];
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
