{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.retronix.organizers;
in
  with lib; {
    imports = [./oxyromon];
  }
