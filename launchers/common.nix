{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config) retronix;
  moltengamepadCmd = cmd: "${pkgs.moltengamepadctl}/bin/moltengamepadctl --socket ${retronix.input-managers.moltengamepad.socketPath} -e ${cmd}";
in rec {
  moltengamepadPreHooks = systemName:
    if retronix.input-managers.moltengamepad.enable
    then [
      # we reset here just to be safe
      (moltengamepadCmd "load profiles from reset")
      (moltengamepadCmd "load profiles from ${systemName}")
    ]
    else [];

  moltengamepadPostHooks = systemName:
    if retronix.input-managers.moltengamepad.enable
    then [
      (moltengamepadCmd "load profiles from reset")
    ]
    else [];

  preLaunchHooks = systemName: (moltengamepadPreHooks systemName);
  postLaunchHooks = systemName: (moltengamepadPostHooks systemName);
}
