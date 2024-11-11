{
  config,
  pkgs,
  lib,
  utils,
  ...
}: let
  cfg = config.retronix.emulators.dolphin;
  retronix = config.retronix;
  subtypes = import ../common-subtypes.nix {inherit lib config;};
in
  with lib; {
    options.retronix.emulators.dolphin =
      subtypes.emulationSubmodule
      // {
        enable = mkEnableOption "Dolphin retronix configuration";
        gc-pad-ini = mkOption {
          type = types.path;
          description = "GCPadNew.ini file";
          default = ./GCPadNew.ini;
        };
        wiimote-ini = mkOption {
          type = types.path;
          description = "WiimoteNew.ini file";
          default = ./WiimoteNew.ini;
        };
        dolphin-ini = mkOption {
          type = types.path;
          description = "Dolphin.ini file";
          default = ./Dolphin.ini;
        };
        gba-ini = mkOption {
          type = types.path;
          description = "GBA.ini file";
          default = ./GBA.ini;
        };
        gameSettings = mkOption {
          type = types.attrsOf types.path;
          description = "Mapping of game IDs to settings files";
          default = {};
        };
        gc-bios = mkOption {
          type = types.nullOr types.path;
          description = "Path to Gamecube BIOS file";
          default = null;
        };
        gba-bios = mkOption {
          type = types.nullOr types.path;
          description = "Path to GBA BIOS file";
          default = null;
        };
        systems = mkOption {
          default = ["gc" "wii"];
        };
        launchCommand = mkOption {
          default = "${pkgs.dolphin-emu}/bin/dolphin-emu -e {{gamepath}} -b";
        };
      };

    config = let
      paths = concatMap (s: retronix.systems.${s}.romPaths) cfg.systems;
      dolphinConfig = utils.templateFile "Dolphin.ini" cfg.dolphin-ini {
        savePath = "${retronix.saveDirectory}/dolphin-emu";
        isoPaths =
          builtins.concatStringsSep "\n"
          (lib.lists.imap0 (i: path: "ISOPath${builtins.toString i}=${path}") paths);
      };
    in
      mkIf cfg.enable (mkMerge [
        (subtypes.commonEmulationConfig cfg)
        {
          xdg.configFile = mkMerge [
            {
              "dolphin-emu/GCPadNew.ini" = {
                source = cfg.gc-pad-ini;
                force = cfg.forceOverwrites;
              };
              "dolphin-emu/WiimoteNew.ini" = {
                source = cfg.wiimote-ini;
                force = cfg.forceOverwrites;
              };
              "dolphin-emu/Dolphin.ini" = {
                source = dolphinConfig;
                force = cfg.forceOverwrites;
              };
              "dolphin-emu/GBA.ini" = {
                source = cfg.gba-ini;
                force = cfg.forceOverwrites;
              };
            }
          ];
          home.file = let
            dolphinDir = "${config.home.homeDirectory}/.local/share/dolphin-emu";
            gameSettingsDir = "${dolphinDir}/GameSettings";
          in
            mkMerge
            [
              (lib.attrsets.concatMapAttrs
                (k: v: {
                  "${gameSettingsDir}/${k}.ini".source = v;
                })
                cfg.gameSettings)
              (mkIf
                (cfg.gc-bios != null)
                {
                  "${config.home.homeDirectory}/.local/share/dolphin-emu/GC/USA/IPL.bin".source = cfg.gc-bios;
                })
              (mkIf
                (cfg.gba-bios != null)
                {
                  "${config.home.homeDirectory}/.local/share/dolphin-emu/GBA/gba_bios.bin".source = cfg.gc-bios;
                })
            ];
        }
      ]);
  }
