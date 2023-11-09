{ config, lib, pkgs, modulesPath, ... }:

{
  systemd = {
    timers = {
      "battery-check" = {
        description = "Check battery level";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "1min";
          OnUnitActiveSec = "1min";
          Unit = "battery-check.service";
        };
      };
    };

    services = {
      "battery-check" = {
        description = "Check battery level";
        wantedBy = [ "default.target" ];
        serviceConfig = {
          Type = "simple";
          User = "jb";
        };
        script = ''
          #!/bin/sh
          export DBUS_SESSION_BUS_ADDRESS="''${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/''${UID}/bus}"
          ${pkgs.batsignal}/bin/batsignal -I ${pkgs.gnome.adwaita-icon-theme}/share/icons/Adwaita/32x32/status/battery-level-40-charging-symbolic.symbolic.png -w 15 -c 10 -d 5 -o
        '';
      };
    };
  };

  environment.systemPackages = with pkgs; [
    batsignal
  ];
}

