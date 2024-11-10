{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.retronix.backups.local;
  retronix = config.retronix;
  service-name = "retronix-local-backup";
  backupJob = repository: keyFile: directories:
    pkgs.writeShellScriptBin "retronix-local-backup" ''
      ${pkgs.restic}/bin/restic init -r ${repository} -p ${keyFile} 2> /dev/null;
      ${pkgs.restic}/bin/restic backup -r ${repository} -p ${keyFile} ${builtins.concatStringsSep " " directories};
    '';
in
  with lib; {
    options.retronix.backups.local = {
      enable = mkEnableOption "Automated restic backup of local save folder";
      directories = mkOption {
        type = types.listOf types.path;
        example = ["/home/user/data" "/var/log/info.log"];
        description = "List of paths to be periodically backed up";
        default = [retronix.saveDirectory];
      };
      repository = mkOption {
        type = types.path;
        example = "/home/user/backup";
        description = "Path to the restic repository";
        default = retronix.backupDirectory;
      };
      keyFile = mkOption {
        type = types.path;
        description = "Path to the restic secret key";
      };
      intervalBackup = mkOption {
        type = types.submodule {
          options = {
            interval = mkOption {
              type = types.str;
              description = "How regularly to backup directories (using systemd's interval syntax)";
              default = "*:0/20";
            };
            enable = mkEnableOption "Enable interval restic backups";
          };
        };
        default = {
          enable = false;
        };
      };
      watchPath = mkOption {
        type = types.bool;
        description = "Use inotify to watch for save changes for restic backup";
        default = false;
      };
    };

    config = mkIf cfg.enable (
      mkMerge [
        {
          systemd.user.services.${service-name} = {
            Unit = {
              Description = "Retronix local file backup";
              Before = "shutdown.target";
            };
            Service = {
              Type = "oneshot";
              ExecStart = "${backupJob cfg.repository cfg.keyFile cfg.directories}/bin/retronix-local-backup";
              StandardOutput = "journal+console";
              StandardError = "journal+console";
            };
            Install.WantedBy = ["default.target" "shutdown.target"];
          };
          retronix.backups.remote.directories = mkDefault [cfg.repository];
        }
        (mkIf cfg.intervalBackup.enable
          {
            systemd.user.timers.periodic-restic-backup = {
              Unit.Description = "Periodic retronix local backup";
              Timer = {
                OnCalendar = cfg.intervalBackup.interval;
                Unit = "${service-name}.service";
              };
              Install.WantedBy = ["timers.target"];
            };
          })
        (mkIf cfg.watchPath
          {
            systemd.user.services.watch-retronix-local-backup = let
              watchJob = pkgs.writeShellScriptBin "watch-retronix-local-backup" ''
                while true; do
                  ${pkgs.inotify-tools}/bin/inotifywait -r -e modify -e create -e move ${builtins.concatStringsSep " " cfg.directories}
                  ${pkgs.restic}/bin/restic backup -r ${cfg.repository} -p ${cfg.keyFile} ${builtins.concatStringsSep " " cfg.directories};
                done
              '';
            in {
              Unit.Description = "Watches retronix folders for changes and runs a local backup";
              Unit.After = ["sops-nix.service"];
              Service = {
                Type = "simple";
                ExecStart = "${watchJob}/bin/watch-retronix-local-backup";
                StandardOutput = "journal+console";
                StandardError = "journal+console";
              };
              Install.WantedBy = ["default.target"];
            };
          })
      ]
    );
  }
