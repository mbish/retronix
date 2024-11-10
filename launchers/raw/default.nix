{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config) retronix;
  cfg = config.retronix.launchers.raw;
  expand = command:
    builtins.replaceStrings
    ["{{gamepath}}" "{{gamedir}}" "{{basename}}"]
    ["$1" "$2" "$3"]
    command;
  common = import ../common.nix {inherit lib config pkgs;};
in
  with lib; {
    options.retronix.launchers.raw = {
      enable = mkEnableOption "pass launch commands directly to frontend";
      wrapper = mkOption {
        type = types.nullOr types.path;
        description = "Wrapper for command to allow for monitoring events";
        default = null;
      };
    };
    config = let
      launcherSystems = retronix.launchers.systems;
      wrapped = command:
        if cfg.wrapper != null
        then "${cfg.wrapper} ${command}"
        else command;
      launchScript = precommands: launchCommand: postcommands: let
        script = pkgs.writeShellScriptBin "launch" (expand ''
          ${builtins.concatStringsSep "\n" precommands}
          ${wrapped launchCommand}
          ${builtins.concatStringsSep "\n" postcommands}
        '');
      in "${script}/bin/launch {{gamepath}} {{gamedir}} {{basename}}";
    in
      mkIf cfg.enable {
        retronix.systems =
          builtins.mapAttrs (k: v: {
            launchCommand = lib.mkDefault (launchScript (common.preLaunchHooks k)
              v.command
              (common.postLaunchHooks k));
          })
          launcherSystems;
      };
  }
