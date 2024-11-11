{
  config,
  pkgs,
  lib,
  utils,
  ...
}: let
  cfg = config.retronix.emulators.retroarch-parallel-64;
  subtypes = import ../common-subtypes.nix {inherit lib config;};
in
  with lib; {
    options.retronix.emulators.retroarch-parallel-64 =
      subtypes.emulationSubmodule
      // {
        enable = mkEnableOption "configuration for the Parallel 64 retroarch core";
        resolution = mkOption {
          type = lib.types.str;
          default = "1920x1080";
        };
        systems = mkOption {
          default = ["n64"];
        };
        launchCommand = mkOption {
          default = "${pkgs.libretro.parallel-n64}/bin/retroarch-parallel-n64 --fullscreen --size=${cfg.resolution} {{gamepath}}";
        };
      };
    config = mkIf cfg.enable (subtypes.commonRetroarchConfig cfg);
  }
