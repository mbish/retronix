{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.retronix.retroarch;
  retronix = config.retronix;
  retronix-utils = import ../lib {inherit pkgs;};
in
  with lib; {
    options.retronix.retroarch = {
      enable = mkEnableOption "Retronix retroarch emulatino config";
      config = mkOption {
        type = types.path;
        description = "Path to your retroarch config";
        default = ./retroarch.cfg;
      };
      mappings = mkOption {
        type = with types;
          listOf (submodule {
            options = {
              name = mkOption {
                type = types.str;
                example = "generic controller";
              };
              config = mkOption {
                type = types.str;
              };
            };
          });
        description = "A set of controller 'mapping' files for retroarch";
        default = [
          {
            name = "MoltenGamepad";
            config = builtins.readFile ./moltengamepad.cfg;
          }
          {
            name = "Microsoft-X-Box-360-pad";
            config = builtins.readFile ./microsoft-xbox-360.cfg;
          }
        ];
      };
      configPath = mkOption {
        type = types.path;
        description = "Path to the retroarch config";
        default = "${config.xdg.configHome}/retroarch";
      };
      systems = mkOption {
        default = [];
      };
    };
    config = let
      mappingDir = "${config.xdg.configHome}/retroarch/autoconfig/udev";
      configFile = retronix-utils.templateFileToFile "retroarch.cfg" ./retroarch.cfg {
        inherit (cfg) configPath;
        savePath = "${retronix.saveDirectory}/retroarch";
        retroarchPath = "${pkgs.retroarch}";
        libretroPath = "${pkgs.libretro-core-info}";
      };
    in
      mkIf cfg.enable {
        home.file."${config.xdg.configHome}/retroarch/retroarch.cfg".source = configFile;
        home.activation = {
          retroarchSymlink =
            lib.hm.dag.entryBetween ["linkGeneration" "installPackages"] ["makeConfig"]
            ''
              mkdir -p ${retronix.saveDirectory}/retroarch/saves
              mkdir -p ${config.xdg.configHome}/retroarch
              ln -sTf ${retronix.saveDirectory}/retroarch/saves ${config.xdg.configHome}/retroarch/saves
              mkdir -p ${retronix.saveDirectory}/retroarch/states
              ln -sTf ${retronix.saveDirectory}/retroarch/states ${config.xdg.configHome}/retroarch/states
            '';
        };
        xdg.configFile = let
          mappings = map (x: {"${mappingDir}/${x.name}.cfg".text = x.config;}) cfg.mappings;
        in
          mkMerge ([
              {
                "retroarch/retroarch.cfg".source = configFile;
              }
            ]
            ++ mappings);
      };
  }
