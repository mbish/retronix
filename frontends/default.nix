{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.retronix.frontends;
in {
  imports = [
    ./pegasus-frontend
    ./emulationstation
  ];
}
