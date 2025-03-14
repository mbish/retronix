{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.retronix.systems;
in
  with lib; {
    imports = [
      ./dreamcast
      ./nds
      ./gamegear
      ./gb
      ./gba
      ./gbc
      ./gc
      ./genesis
      ./n64
      ./nes
      ./ps2
      ./ps3
      ./psx
      ./saturn
      ./snes
      ./wii
    ];
  }
