{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.retronix.input-managers;
in {
  imports = [
    ./moltengamepad
  ];
}
