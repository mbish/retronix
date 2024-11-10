{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.retronix.frontends.pegasus-frontend;
  retronix = config.retronix;
  expand = command:
    builtins.replaceStrings
    ["{{gamepath}}" "{{gamedir}}" "{{basename}}"]
    ["{file.path}" "{file.dir}" "{file.basename}"]
    command;
in
  with lib; {
    options.retronix.frontends.pegasus-frontend = {
      enable = mkEnableOption "Retronix Pegaus-Frontend configuration";
      theme = mkOption {
        type = types.submodule {
          options = {
            name = mkOption {
              type = types.str;
              example = "es2-simple";
              default = "current";
            };
            source = mkOption {
              type = lib.types.path;
              description = "Path to a pegasus-frontend theme";
            };
          };
        };
      };
      collections = mkOption {
        type =
          types.listOf
          (types.submodule {
            options = {
              name = mkOption {
                type = types.str;
                example = "Favorite Games";
              };
              extensions = mkOption {
                type = types.listOf types.str;
                example = ["iso" "bin"];
              };
              launch =
                mkOption
                {
                  type = types.str;
                  description = "Command used to launch rom";
                  example = "myemulator {file.path}";
                };
            };
          });
      };
      gamedirs = mkOption {
        type = types.listOf types.str;
        description = "List of directories in which games and metadata can be found";
      };
      skyscraperName = mkOption {
        type = types.str;
        description = "Name of the skyscraper frontend to use for this frontend";
        default = "pegasus";
      };
    };
    config = mkIf cfg.enable {
      home.file."${config.xdg.configHome}/pegasus-frontend/themes/${cfg.theme.name}".source = cfg.theme.source;
      home.file."${config.xdg.configHome}/pegasus-frontend/settings.txt".text = ''
        general.theme: themes/${cfg.theme.name}
        general.verify-files: true
        general.input-mouse-support: true
        general.fullscreen: true
        providers.steam.enabled: true
        providers.gog.enabled: true
        providers.es2.enabled: false
        providers.logiqx.enabled: true
        providers.lutris.enabled: true
        providers.skraper.enabled: true
        keys.page-up: PgUp,GamepadL1
        keys.page-down: PgDown,GamepadR1
        keys.prev-page: Q,A,GamepadL2
        keys.next-page: E,D,GamepadR2
        keys.menu: F1,GamepadStart
        keys.filters: F,GamepadY
        keys.details: I,GamepadX
        keys.cancel: Esc,Backspace,GamepadB
        keys.accept: Return,Enter,GamepadA
      '';
      home.file."${config.xdg.configHome}/pegasus-frontend/metafiles/metadata.txt".text = let
        collection = name: extensions: launch: ''
          collection: ${name}
          extensions: ${builtins.concatStringsSep "," extensions}
          launch: ${expand launch}
        '';
      in
        builtins.concatStringsSep "\n\n"
        (map (x: collection x.name x.extensions x.launch) cfg.collections);
      home.file."${config.xdg.configHome}/pegasus-frontend/game_dirs.txt".text =
        # TODO add metadata path for systems here
        builtins.concatStringsSep "\n" cfg.gamedirs;
      home.activation = {
        pegasusSymlink =
          lib.hm.dag.entryBetween ["linkGeneration" "installPackages"] ["makeConfig"]
          ''
            mkdir -p ${retronix.saveDirectory}/pegasus-frontend
            ln -sTf ${retronix.saveDirectory}/pegasus-frontend ${config.xdg.configHome}/pegasus-frontend
          '';
      };
    };
  }
