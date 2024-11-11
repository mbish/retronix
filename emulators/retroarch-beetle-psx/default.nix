{
  config,
  pkgs,
  lib,
  utils,
  ...
}: let
  cfg = config.retronix.emulators.retroarch-beetle-psx;
  subtypes = import ../common-subtypes.nix {inherit lib config;};
in
  with lib; {
    options.retronix.emulators.retroarch-beetle-psx =
      subtypes.emulationSubmodule
      // {
        enable = mkEnableOption "configuration for the Beetle PSX retroarch core";
        systems = mkOption {
          default = ["psx"];
        };
        bios = mkOption {
          type = types.nullOr types.path;
          description = "Path to the PSX bios";
          default = null;
        };
        resolution = mkOption {
          type = lib.types.str;
          default = "1920x1080";
        };
        launchCommand = mkOption {
          default = "${pkgs.libretro.beetle-psx}/bin/retroarch-mednafen-psx --fullscreen --size=${cfg.resolution} {{gamepath}}";
        };
      };
    config = mkIf cfg.enable (mkMerge [
      (subtypes.commonRetroarchConfig cfg)
      {
        home.file = mkMerge [
          {
            "${config.xdg.configHome}/retroarch/system/.exists".text = "";
          }
          (mkIf (cfg.bios != null) {
            "${config.xdg.configHome}/retroarch/system/scph5501.bin".source = cfg.bios;
          })
        ];
      }
    ]);
  }
