{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.retronix.scrapers;
in
  with lib; {
    imports = [./skyscraper];
  }
