{
  lib,
  config,
  ...
}: let
  retronix = config.retronix;
in
  with lib; rec {
    emulationSubmodule = {
      systems = mkOption {
        type = types.listOf (types.enum (builtins.attrNames retronix.systems));
        description = "List of systems to use this emulator for";
      };
      launchCommand = mkOption {
        type = types.str;
        description = "Launch command to use for this emulator";
      };
      forceOverwrites = mkOption {
        type = types.bool;
        description = "Force overwrite of emulator configuration files";
        default = retronix.forceOverwrites;
      };
    };
    commonEmulationConfig = cfg: {
      retronix.launchers.systems = builtins.listToAttrs (builtins.map (k: {
          name = k;
          value = {
            command = lib.mkDefault cfg.launchCommand;
          };
        })
        cfg.systems);
    };
    commonRetroarchConfig = cfg: (mkMerge [
      (commonEmulationConfig cfg)
    ]);
  }
