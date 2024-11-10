{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.retronix.systems.dreamcast;
  subtypes = import ../common-subtypes.nix {inherit lib config;};
  shortName = "dreamcast";
in
  with lib; {
    options.retronix.systems.dreamcast =
      subtypes.systemSubmodule
      // {
        enable = lib.mkEnableOption "Sega Dreamcast System";
        shortName = mkOption {
          default = shortName;
        };
        emulationstationName = mkOption {
          default = "Sega Dreamcast";
        };
        pegasusName = mkOption {
          default = "Dreamcast";
        };
        skyscraperName = mkOption {
          default = shortName;
        };
        extensions = mkOption {
          default = ["cdi" "gdi" "iso" "chd" "m3u"];
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
