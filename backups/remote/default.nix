{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.retronix.backups.remote;
  retronix = config.retronix;
  service-name = "retronix-remote-backup";
in
  with lib; {
    options.retronix.backups.remote = {
      enable = mkEnableOption "Automated remote syncing of retronix directories";
      directories = mkOption {
        type = types.listOf types.path;
        example = ["/home/user/data" "/var/log/info.log"];
        description = "List of paths to be periodically backed up into the remote";
      };
      remote = mkOption {
        type = types.str;
        example = "remote:destination";
        description = "The rclone remote destination to use for backups";
      };
      interval = mkOption {
        type = types.str;
        description = "How regularly to backup directories (using systemd's interval syntax)";
        default = "*:0/20";
      };
      rcloneConfig = mkOption {
        type = types.path;
        description = "rclone configuration file to use for sync";
      };
    };
    config = mkIf cfg.enable {
      systemd.user.services.${service-name} = {
        Unit = {
          Description = "retronix remote file backup";
          Before = "shutdown.target";
          After = "network-online.target";
          Wants = "network-online.target";
        };
        Service = let
          backupJob = remote: directories:
            pkgs.writeShellScriptBin "retronix-remote-backup" (
              builtins.concatStringsSep "\n"
              (map (directory: "${pkgs.rclone}/bin/rclone --config ${cfg.rcloneConfig} sync --verbose -L ${directory} ${remote}") directories)
            );
        in {
          Type = "simple";
          Restart = "on-failure";
          RestartSec = "30";
          ExecStart = "${backupJob cfg.remote cfg.directories}/bin/retronix-remote-backup";
          StandardOutput = "journal+console";
          StandardError = "journal+console";
        };
        Install.WantedBy = ["default.target" "shutdown.target"];
      };
      systemd.user.timers.periodic-retronix-remote-backup = {
        Unit.Description = "Periodic retronix remote backup";
        Timer = {
          OnCalendar = cfg.interval;
          Unit = "${service-name}.service";
        };
        Install.WantedBy = ["timers.target"];
      };
    };
  }
