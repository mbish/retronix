{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.retronix.backups;
in
  with lib; {
    imports = [
      ./local
      ./remote
    ];
  }
