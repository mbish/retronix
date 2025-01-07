{
  description = "Retronix a hackable nix emulation platform";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    skyscraper = {
      url = "github:detain/skyscraper";
      flake = false;
    };
    pegasus-frontend = {
      url = "https://github.com/mmatyas/pegasus-frontend.git?rev=weekly_2024w38";
      flake = false;
      type = "git";
      submodules = true;
    };
    gamelauncher = {
      url = "github:mbish/gamelauncher";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    moltengamepadctl = {
      url = "github:mbish/moltengamepadctl";
      flake = true;
    };
    moltengamepad = {
      url = "github:mbish/MoltenGamepad";
      flake = true;
    };
    oxyromon = {
      url = "github:alucryd/oxyromon/develop";
      flake = false;
    };
    fenix = {
      url = "github:nix-community/fenix/24d0d5b664d1b179e391cec97838c90f5a191c86";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mp64-convert = {
      url = "github:drehren/ra_mp64_srm_convert/v1.0";
      flake = false;
    };
  };

  outputs = {nixpkgs, ...} @ inputs: let
    utils = import ./lib;
    forAllSystems = f: nixpkgs.lib.genAttrs systems f;
    systems = [
      "x86_64-linux"
    ];
  in {
    homeManagerModules = rec {
      retronix = import ./default.nix {
        inherit inputs;
        retronix-utils = utils;
      };
      default = retronix;
    };
    overlays = forAllSystems (
      system: (
        let
          inherit (nixpkgs) lib;
          pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
            ];
          };
        in
          _: prev: {
            gamelauncher = inputs.gamelauncher.packages."${system}".default;
            moltengamepad = inputs.moltengamepad.packages."${system}".default;
            moltengamepadctl = inputs.moltengamepadctl.packages."${system}".default;
            mp64-convert = import ./derivations/ra_mp64_srm_convert {inherit pkgs inputs system;};
            oxyromon = import ./derivations/oxyromon {inherit pkgs lib inputs;};
            pegasus-frontend = import ./derivations/pegasus-frontend {inherit pkgs lib inputs;};
            skyscraper = import ./derivations/skyscraper {inherit pkgs lib inputs;};
          }
      )
    );
  };
}
