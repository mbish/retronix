{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.retronix.systems.gbc;
  subtypes = import ../common-subtypes.nix {inherit lib config;};
  shortName = "gbc";
in
  with lib; {
    options.retronix.systems.gbc =
      subtypes.systemSubmodule
      // {
        enable = lib.mkEnableOption "Game Boy Color system";
        shortName = mkOption {
          default = shortName;
        };
        emulationstationName = mkOption {
          default = "Game Boy Color";
        };
        pegasusName = mkOption {
          default = "Game Boy Color";
        };
        skyscraperName = mkOption {
          default = shortName;
        };
        extensions = mkOption {
          default = ["gbc"];
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
