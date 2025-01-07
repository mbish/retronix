{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.retronix.emulators.pcsx2;
  subtypes = import ../common-subtypes.nix {inherit lib config;};
  retronix = config.retronix;
  retronix-utils = import ../../lib {inherit pkgs;};
in
  with lib; {
    options.retronix.emulators.pcsx2 =
      subtypes.emulationSubmodule
      // {
        enable = mkEnableOption "PCSX2 emulator configuration";
        configPath = mkOption {
          type = types.str;
          default = "${config.xdg.configHome}/PCSX2";
          description = "Location to store PCSX2 config";
        };
        pkg = mkOption {
          type = types.path;
          description = "Location the PCSX2 installation";
          default = "${pkgs.pcsx2}";
        };
        reg-ini = mkOption {
          type = types.path;
          description = "PCSX2-reg.ini file";
          default = ./PCSX2-reg.ini;
        };
        ui-ini = mkOption {
          type = types.path;
          description = "PCSX2_ui.ini file";
          default = ./PCSX2_ui.ini;
        };
        vm-ini = mkOption {
          type = types.path;
          description = "PCSX2_vm.ini file";
          default = ./PCSX2_vm.ini;
        };
        pad-ini = mkOption {
          type = types.path;
          description = "PAD.ini file";
          default = ./PAD.ini;
        };
        pcsx2-ini = mkOption {
          type = types.path;
          description = "PS2 main ini";
          default = ./PCSX2.ini;
        };
        bios = mkOption {
          type = types.nullOr types.path;
          description = "Path to BIOS file for system";
          default = null;
        };
        systems = mkOption {
          default = ["ps2"];
        };
        launchCommand = mkOption {
          default = "${pkgs.pcsx2}/bin/pcsx2-qt {{gamepath}}";
        };
      };
    config = let
      savePath = "${retronix.saveDirectory}/PCSX2";
      reg-ini = retronix-utils.templateFileToFile "PCSX2-reg.ini" cfg.reg-ini {
        configPath = cfg.configPath;
        installPath = cfg.pkg;
      };
      ui-ini = "${retronix-utils.templateFileToFile "GSdx.ini" cfg.ui-ini {
        inherit savePath;
        configPath = cfg.configPath;
        installPath = cfg.pkg;
      }}";
      vm-ini = cfg.vm-ini;
      pad-ini = cfg.pad-ini;
      pcsx2-ini = cfg.pcsx2-ini;
    in
      mkIf cfg.enable (mkMerge [
        (subtypes.commonEmulationConfig cfg)
        {
          xdg.configFile = {
            # TODO might need to serve some of these files out of a service to deal with clobbering
            "PCSX2/bios/.exists".text = "";
            "${savePath}/memcards/.exists".text = "";
            "${savePath}/sstates/.exists".text = "";
            "PCSX2/PCSX2-reg.ini" = {
              source = reg-ini;
              force = cfg.forceOverwrites;
            };
            "PCSX2/inis/PCSX2_ui.ini" = {
              source = ui-ini;
              force = cfg.forceOverwrites;
            };
            "PCSX2/inis/PCSX2_vm.ini" = {
              source = vm-ini;
              force = cfg.forceOverwrites;
            };
            "PCSX2/inis/PAD.ini" = {
              source = pad-ini;
              force = cfg.forceOverwrites;
            };
            "PCSX2/inis/PCSX2.ini" = {
              source = pcsx2-ini;
              force = cfg.forceOverwrites;
            };
          };
        }
        (mkIf
          (cfg.bios != null)
          {
            home.file = {
              "${config.xdg.configHome}/PCSX2/bios/bios.bin" = {
                source = cfg.bios;
                force = cfg.forceOverwrites;
              };
            };
          })
      ]);
  }
