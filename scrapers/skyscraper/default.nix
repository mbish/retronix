{
  lib,
  config,
  pkgs,
  ...
}: let
  retronix = config.retronix;
  cfg = config.retronix.scrapers.skyscraper;
in
  with lib; {
    options.retronix.scrapers.skyscraper = {
      enable = mkEnableOption "Retronix skyscraper configuration and utilities";
      artworkConfig = mkOption {
        type = types.path;
        description = "Path to the skyscraper artwork XML file";
      };
      metadataPath = mkOption {
        type = types.path;
        description = "Path to generated metadata";
      };
      platformsFile = mkOption {
        type = types.path;
        description = "Platforms.json file for system data";
        default = "${pkgs.skyscraper}/local/etc/skyscraper/platforms.json";
      };
      region = mkOption {
        type = types.str;
        default = "us";
        description = "Skyscraper region for scraping";
      };
      sources = mkOption {
        type = types.listOf types.str;
        default = ["arcadedb" "openretro" "screenscraper" "igdb" "mobygames"];
        description = "List of sources to scrape from";
      };
      frontend = mkOption {
        type = types.str;
        description = "name of frontend to generate metadata for";
        example = "pegasus";
      };
      systems = mkOption {
        type = types.listOf (types.submodule {
          options = {
            system = mkOption {
              type = types.str;
              description = "Skyscraper short code for the system";
              example = "snes";
            };
            paths = mkOption {
              type = types.listOf types.str;
              description = "list of directories to scrape for this system";
            };
            includePattern = mkOption {
              type = types.nullOr types.str;
              description = "pattern to use when searching for files";
              default = null;
            };
            addExtension = mkOption {
              type = types.nullOr types.str;
              description = "Force the scraping of a particular extension";
              default = null;
            };
          };
        });
        default = {};
      };
    };
    config =
      mkIf cfg.enable
      {
        home.file = let
          skyscraperLinesFromSystem = system:
            builtins.concatStringsSep "\n" (
              map
              (source:
                builtins.concatStringsSep "\n" (
                  map
                  (
                    x:
                      "${pkgs.skyscraper}/bin/Skyscraper -p ${system.system} -s ${source} -i \"${x}\" --region ${cfg.region} -d ${cfg.metadataPath}/cache/${system.system}"
                      + lib.strings.optionalString (system.addExtension != null) " --addext \"*.${system.addExtension}\" "
                      + lib.strings.optionalString (system.includePattern != null) " --includepattern \"${system.includePattern}\" "
                  )
                  system.paths
                ))
              cfg.sources
            );
          frontends = map (x: x.skyscraperName) (filter (x: x.enable) (builtins.attrValues retronix.frontends));
          scraper = pkgs.writeShellScriptBin "scrapeMetadata" (
            builtins.concatStringsSep "\n" (map skyscraperLinesFromSystem cfg.systems)
          );
          generatorLinesForFrontend = frontend:
            builtins.concatStringsSep "\n" (map (generatorLinesFromSystem frontend) cfg.systems);

          generatorLinesFromSystem = frontend: system:
            builtins.concatStringsSep "\n"
            (
              map
              (
                x:
                  "${pkgs.skyscraper}/bin/Skyscraper -f ${frontend} -p ${system.system} -i \"${x}\" -g ${cfg.metadataPath}/${system.system} -o ${cfg.metadataPath}/${system.system}/media -e \"skip\" -d ${cfg.metadataPath}/cache/${system.system} --flags skipped,unattend"
                  + lib.strings.optionalString (system.addExtension != null) " --addext \"*.${system.addExtension}\" "
                  + lib.strings.optionalString (system.includePattern != null) " --includepattern \"${system.includePattern}\" "
              )
              system.paths
            );
          generator =
            pkgs.writeShellScriptBin "generateMetadata"
            (
              builtins.concatStringsSep "\n" (map generatorLinesForFrontend frontends)
            );
        in {
          "${config.home.homeDirectory}/.skyscraper/artwork.xml".source = cfg.artworkConfig;
          "${config.home.homeDirectory}/.skyscraper/platforms.json".source = cfg.platformsFile;
          "${config.home.homeDirectory}/.skyscraper/screenscraper.json".source = "${pkgs.skyscraper}/local/etc/skyscraper/screenscraper.json";
          "${config.home.homeDirectory}/scrapeMetadata".source = "${scraper}/bin/scrapeMetadata";
          "${config.home.homeDirectory}/generateMetadata".source = "${generator}/bin/generateMetadata";
        };
      };
  }
