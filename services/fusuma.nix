{ pkgs, lib, config, ... }:

with lib;

let
  cfg = config.services.fusuma;
in {
  options.services.fusuma = {
    enable = mkEnableOption "Enable fusuma service";

    package = mkOption {
      type = types.package;
      default = pkgs.fusuma;
      defaultText = "pkgs.fusuma";
      description = "Set version of fusuma package to use.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ]; # if user should have the command available as well
    services.dbus.packages = [ cfg.package ]; # if the package has dbus related configuration

    systemd.services.fusuma = {
      description = "Fusuma server daemon.";

      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ]; # if networking is needed

      restartIfChanged = true; # set to false, if restarting is problematic

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${cfg.package}/bin/fusuma";
        Restart = "always";
      };
    };
  };

  meta.maintainers = with lib.maintainers; [  ];
}
