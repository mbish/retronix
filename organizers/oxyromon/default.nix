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
  mkOxyromonConfigListOption = name: list:
    if list == []
    then ""
    else
      builtins.concatStringsSep "\n" ([
          "${pkgs.oxyromon}/bin/oxyromon config -u ${name}"
        ]
        ++ (builtins.map (value: "${pkgs.oxyromon}/bin/oxyromon config --add ${name} \"${value}\"") list));

  mkOxyromonConfigBoolOption = name: value: "${pkgs.oxyromon}/bin/oxyromon config --set ${name} ${
    if value == true
    then "true"
    else "false"
  }";

  mkOxyromonConfigStringOption = name: value: "${pkgs.oxyromon}/bin/oxyromon config --set ${name} \"${value}\"";
in
  with lib; {
    options.retronix.organizers.oxyromon = {
      enable = mkEnableOption "Oxyromon module for Retronix";
      romDirectory = mkOption {
        type = types.path;
        description = "Path to directory that oxyromon manages";
        default = "${retronix.romDirectory}/managed";
      };
      regions-one = mkOption {
        type = types.listOf types.str;
        description = "Ordered list of regions for which you want to keep a single ROM file";
        example = ["US" "EU"];
        default = [];
      };
      discard-flags = mkOption {
        type = types.listOf types.str;
        description = "List of ROM flags to discard";
        example = ["Virtual Console"];
        default = [];
      };
      discard-releases = mkOption {
        type = types.listOf types.str;
        description = "List of ROM releases to discard";
        example = ["Beta"];
        default = [];
      };
      prefer-parents = mkOption {
        type = types.bool;
        description = "Favor parents in the 1G1R election process";
        default = true;
      };
      prefer-versions = mkOption {
        type = types.enum ["none" "new" "old"];
        description = "Favor newer or earlier versions of ROMs in the 1G1R election process";
        default = "new";
      };
      prefer-flags = mkOption {
        type = types.listOf types.str;
        description = "List of ROM flags to favor in the 1G1R election process";
        example = ["Rumble Version"];
        default = [];
      };
      languages = mkOption {
        type = types.listOf types.str;
        description = "List of languages you want to keep, applies only to ROMs that do specify them";
        example = ["En" "Ja"];
        default = [];
      };
      regions-one-strict = mkOption {
        type = types.bool;
        description = "true will elect ROMs regardless of them being available, false will only elect available ROMs, defaults to false";
        default = false;
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
          ${mkOxyromonConfigStringOption "ROM_DIRECTORY" cfg.romDirectory}
          ${mkOxyromonConfigListOption "REGIONS_ONE" cfg.regions-one}
          ${mkOxyromonConfigListOption "DISCARD_FLAGS" cfg.discard-flags}
          ${mkOxyromonConfigListOption "DISCARD_RELEASES" cfg.discard-releases}
          ${mkOxyromonConfigBoolOption "PREFER_PARENTS" cfg.prefer-parents}
          ${mkOxyromonConfigListOption "PREFER_FLAGS" cfg.prefer-flags}
          ${mkOxyromonConfigListOption "LANGUAGES" cfg.languages}
          ${mkOxyromonConfigBoolOption "REGIONS_ONE_STRICT" cfg.regions-one-strict}
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
