{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.retronix.systems.ps3;
  subtypes = import ../common-subtypes.nix {inherit lib config;};
  shortName = "ps3";
in
  with lib; {
    options.retronix.systems.ps3 =
      subtypes.systemSubmodule
      // {
        enable = lib.mkEnableOption "Sony Playstation 3 System";
        shortName = mkOption {
          default = shortName;
        };
        emulationstationName = mkOption {
          default = "Sony Playstation 3";
        };
        pegasusName = mkOption {
          default = "Playstation 3";
        };
        skyscraperName = mkOption {
          default = shortName;
        };
        extensions = mkOption {
          default = ["iso" "bin" "pkg" "m3u"];
        };
      };
    config =
      mkIf
      cfg.enable
      (mkMerge [
        (subtypes.commonConfig cfg)
        {
          retronix.scrapers.skyscraper.systems = [
            {
              system = "ps3";
              paths = cfg.romPaths;
              addExtension = "ps3";
              includePattern = "*.ps3";
            }
          ];
        }
      ]);
  }
