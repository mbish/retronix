{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.retronix.input-managers.moltengamepad;
  retronix = config.retronix;
in
  with lib; {
    options.retronix.input-managers.moltengamepad = {
      enable = mkEnableOption "Moltengamepad input manager configuration";
      gendev-files = mkOption {
        type = types.listOf types.path;
        description = "List of moltengamepad gendev files to include";
        default = [];
      };
      system-profiles = mkOption {
        type = types.submodule {
          options =
            builtins.mapAttrs (
              k: _:
                mkOption {
                  type = types.nullOr types.path;
                  description = "Controller profiles for sytem ${k}";
                  default = null;
                }
            )
            retronix.systems;
        };
        default = {};
      };
      extra-profiles = mkOption {
        type = types.listOf types.path;
        description = "Other profiles to include";
        default = [];
      };

      # more general config
      config-path = mkOption {
        type = types.path;
        default = "${config.xdg.configHome}/moltengamepad";
      };
      slotAssignments = mkOption {
        type = types.listOf (types.submodule {
          options = {
            slot = mkOption {
              type = types.str;
              example = "virtpad1";
              description = "the name of the moltengamepad slot to assign to";
            };
            type = mkOption {
              type = types.enum ["name" "uniq" "phys"];
              example = "name";
            };
            id = mkOption {
              type = types.str;
              example = "hn64_1";
            };
          };
        });
        default = [];
      };
      socketPath = mkOption {
        type = types.str;
        default = "$XDG_RUNTIME_DIR/moltengamepad/socket";
      };
    };
    config = let
      moltengamepadDir = cfg.config-path;
      enableSlotAssignments = cfg.slotAssignments != [];
      runDir = "$XDG_RUNTIME_DIR/moltengamepad";
      moltengamepad-assignments = assignments:
        pkgs.writeShellScriptBin "moltengamepad-assignments" ''
          ${pkgs.coreutils}/bin/cat << EOF |  ${pkgs.moltengamepadctl}/bin/moltengamepadctl --socket ${cfg.socketPath} -i
          ${builtins.concatStringsSep "\n" (map (x: "assign slot ${x.slot} to ${x.type} \"${x.id}\"") assignments)}
          EOF
        '';

      moltengamepad-start = pkgs.writeShellScriptBin "moltengamepad-start" ''
        ${pkgs.moltengamepad}/bin/moltengamepad --daemon --pidfile ${runDir}/pid --replace-fifo --fifo-path ${runDir}/fifo --make-socket --socket-path ${cfg.socketPath} --config-path ${moltengamepadDir}
      '';
    in
      mkIf cfg.enable (mkMerge [
        {
          home.file = mkMerge (
            (map (p: {
                "${moltengamepadDir}/gendevices/${builtins.baseNameOf p}.cfg".source = p;
              })
              cfg.gendev-files)
            ++ (map (k: {
              "${moltengamepadDir}/profiles/${k}".source = cfg.system-profiles.${k};
            }) (filter (k: cfg.system-profiles.${k} != null) (builtins.attrNames cfg.system-profiles)))
            ++ [
              (mkIf enableSlotAssignments {
                "${moltengamepadDir}/options/slots.cfg".text = mkIf enableSlotAssignments "auto_assign = false";
              })
            ]
            ++ [
              {
                "${moltengamepadDir}/profiles/reset".source = ./profiles/reset;
              }
            ]
          );
          home.sessionVariables = {
            SDL_GAMECONTROLLERCONFIG = let
              buttonLayout = "MoltenGamepad,platform:Linux,a:b0,b:b1,x:b3,y:b2,back:b6,start:b7,guide:b8,leftshoulder:b4,rightshoulder:b5,leftstick:b9,rightstick:b10,leftx:a0,lefty:a1,rightx:a3,righty:a4,lefttrigger:a2,righttrigger:a5,dpup:b11,dpleft:b13,dpdown:b12,dpright:b14,";
            in
              builtins.concatStringsSep "\n" [
                "0300000001000000010000000100000011,${buttonLayout}"
                "0300000001000000010000000100000012,${buttonLayout}"
                "0300000001000000010000000100000013,${buttonLayout}"
                "0300000001000000010000000100000014,${buttonLayout}"
              ];
          };
          systemd.user.services.moltengamepad = {
            Unit = mkMerge [
              {
                Description = "MoltenGamepad Event Translator";
              }
              (mkIf enableSlotAssignments {
                Requires = "moltengamepad-assignments.service";
                Before = "moltengamepad-assignments.service";
              })
            ];
            Service = {
              RuntimeDirectory = "moltengamepad";
              RuntimeDirectoryMode = "0755";
              StateDirectory = "moltengamepad";
              ConfigurationDirectory = "moltengamepad";
              Type = "forking";
              PIDFile = "moltengamepad/pid";
              ExecStop = "${pkgs.util-linux}/bin/kill $MAINPID";
              # TODO fixup how XDG_RUNTIME_DIR is expanded somehow
              ExecStart = "${moltengamepad-start}/bin/moltengamepad-start";
              # wait for listening socket to be established
              ExecStartPost = "${pkgs.coreutils}/bin/timeout 10 ${pkgs.runtimeShell} -c \"while ! ${pkgs.iproute2}/bin/ss -H -l src unix:${cfg.socketPath} | ${pkgs.gnugrep}/bin/grep -q LISTEN; do ${pkgs.coreutils}/bin/sleep 1; done\"";
              StandardOutput = "journal+console";
              StandardError = "journal+console";
            };
            Install.WantedBy = ["default.target"];
          };
        }
        (mkIf enableSlotAssignments {
          systemd.user.services.moltengamepad-assignments = {
            Unit = {
              Description = "Assign moltengamepad slots based on physical device attribute";
              After = "moltengamepad.service";
            };
            Service = {
              Type = "simple";
              ExecStart = "${moltengamepad-assignments cfg.slotAssignments}/bin/moltengamepad-assignments";
              StandardOutput = "journal+console";
              StandardError = "journal+console";
            };
          };
        })
      ]);
  }
