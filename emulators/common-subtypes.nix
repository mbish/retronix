{lib, ...}:
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
