{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.retronix.systems.psx;
  subtypes = import ../common-subtypes.nix {inherit lib config;};
  shortName = "psx";
in
  with lib; {
    options.retronix.systems.psx =
      subtypes.systemSubmodule
      // {
        enable = lib.mkEnableOption "Sony Playstation System";
        shortName = mkOption {
          default = shortName;
        };
        emulationstationName = mkOption {
          default = "Sony Playstation";
        };
        pegasusName = mkOption {
          default = "Playstation";
        };
        skyscraperName = mkOption {
          default = shortName;
        };
        extensions = mkOption {
          default = ["cue" "cbn" "img" "iso" "m3u" "mdf" "pbp" "toc" "z" "znx" "chd"];
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
