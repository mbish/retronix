{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.retronix.launchers;
  common = import ../common.nix {inherit lib config;};
in
  with lib; {
    imports = [
      ./gamelauncher
      ./raw
    ];
    options.retronix.launchers = {
      systems = mkOption {
        type = types.attrsOf (types.submodule {
          options = {
            command = mkOption {
              type = types.str;
              example = "/usr/local/bin/emulator --fullscreen {file.path}";
              description = "Full launch command including variables";
            };
            name = mkOption {
              type = lib.types.str;
              example = "MAME";
              description = "short code for identifying system";
            };
          };
        });
        default = {};
      };
    };
  }
