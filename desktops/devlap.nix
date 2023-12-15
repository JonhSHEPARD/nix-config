{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    ./default.nix
    ./../modules/network-tools-gui.nix
    ./../modules/battery-check.nix
  ];

  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ];
    extraModulePackages = [ ];

    initrd = {
      availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
      kernelModules = [ "dm-crypt" "i915" ];

      luks.devices = {
        uncrypted = {
          device = "/dev/disk/by-uuid/15382968-c73e-4211-a4f2-460830224829";
        };
      };
    };

    kernelModules = [ "kvm-intel" ];

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  environment = {
    systemPackages = with pkgs; [
      batsignal
      betterlockscreen
      minicom
      virt-manager
      virtiofsd
      xss-lock
      bash
      libsForQt5.kdeconnect-kde
    ];

    variables = {
      VDPAU_DRIVER = lib.mkDefault "va_gl";
    };
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/AF8B-D892";
      fsType = "vfat";
    };

    "/" = {
      device = "/dev/disk/by-uuid/fa10cf90-b78f-4ec9-b60c-a9aa153ba7aa";
      fsType = "ext4";
    };
  };

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = false;
    };
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    opengl.extraPackages = with pkgs; [
      vaapiIntel
      libvdpau-va-gl
      intel-media-driver
    ];
  };

  networking = {
    hostName = "jb-portable-dev";

    useDHCP = false;

    bridges = {
      #br-local = {
      #  interfaces = [
      #     "enp0s31f6"
      #     "wlp2s0"
      #  ];
      #};
    };

    interfaces = {
      enp0s31f6.useDHCP = true;
      wlp2s0.useDHCP = true;
    };

    wireless = {
      enable = true;
      #userControlled.enable = true;
    };

    firewall = {
      allowedTCPPorts = [
        80
        443
      ];
      allowedTCPPortRanges = [
        { from = 1714; to = 1764; } # KDE Connect
      ];
      allowedUDPPortRanges = [
        { from = 1714; to = 1764; } # KDE Connect
      ];
    };

    nameservers = [ "1.1.1.1" "9.9.9.9" ];
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  programs = {
    dconf.enable = true;

    light.enable = true;

    xss-lock = {
      enable = true;
      lockerCommand = "${pkgs.betterlockscreen}/bin/betterlockscreen -l";
    };
  };

  services = {
    actkbd = {
      enable = true;
      bindings = [
        { keys = [ 225 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -A 10"; }
        { keys = [ 224 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -U 10"; }
      ];
    };

    blueman.enable = true;

    logind = {
      extraConfig = ''
        IdleAction=lock
        IdleActionSec=3min
        HandlePowerKey=ignore
      '';
      lidSwitch = "hibernate";
      lidSwitchDocked = "hibernate";
      lidSwitchExternalPower = "hibernate";
    };

    printing = {
      enable = true;
      drivers = with pkgs; [
        gutenprint
        epson-escpr
        epson-escpr2
      ];
    };

    #thermald.enable = true;

    upower = {
      enable = true;
    };

    xserver = {
      libinput.enable = true;

      xautolock = {
        enable = true;
        time = 3;
        locker = "${pkgs.betterlockscreen}/bin/betterlockscreen -l";
        killtime = 10;
        killer = "/run/current-system/systemd/bin/systemctl suspend";
      };
    };
  };

  swapDevices = [ ];

  virtualisation.libvirtd = {
    enable = true;
    allowedBridges = [
      "br-local"
    ];
  };
}
