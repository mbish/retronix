{
  lib,
  config,
  pkgs,
  system,
  utils,
  ...
}: let
  cfg = config.retronix.organizers.oxyromon;
  retronix = config.retronix;
in
  with lib; {
    options.retronix.organizers.oxyromon = {
      enable = mkEnableOption "Oxyromon module for Retronix";
      romDirectory = mkOption {
        type = types.path;
        description = "Path to directory that oxyromon manages";
        default = "${retronix.romDirectory}/managed";
      };
    };
    config = {
      retronix.systems = let
        stripTags = s: head (lib.strings.splitString " (" s);
      in
        builtins.mapAttrs (name: value: {
          romPaths =
            builtins.map (
              dat: let
                systemPath = utils.extractDatMetadata "system name" dat "datafile header name";
              in "${cfg.romDirectory}/${stripTags systemPath}"
            )
            value.datFiles;
        })
        retronix.systems;
      home.activation = let
        dats = concatMap (s: s.datFiles) (builtins.attrValues retronix.systems);
        importDat = dat: "${pkgs.oxyromon}/bin/oxyromon import-dats ${dat}";
        importDats = d: builtins.concatStringsSep "\n" (map importDat d);
      in {
        oxyromonSettings = lib.hm.dag.entryAfter ["linkGeneration"] ''
          ${pkgs.oxyromon}/bin/oxyromon config --set ROM_DIRECTORY ${cfg.romDirectory}
        '';
        oxyromonSymlink = lib.hm.dag.entryBetween ["oxyromonSettings"] ["makeConfig"] ''
          mkdir -p ${retronix.metadataDirectory}/oxyromon
          ln -sTf ${retronix.metadataDirectory}/oxyromon ${config.home.homeDirectory}/.local/share/oxyromon
        '';
        oxyromonDatImport = lib.hm.dag.entryAfter ["oxyromonSettings"] (importDats dats);
      };
      home.packages = [
        pkgs.p7zip
        pkgs.dolphin-emu
        pkgs.cdrkit
        pkgs.maxcso
        pkgs.mame-tools
        pkgs.oxyromon
      ];
    };
  }
