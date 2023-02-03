{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    ./default.nix
  ];

  boot = { 
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];

    initrd = {
      availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
      kernelModules = [ "dm-crypt" ];

      luks.devices = {
        uncrypted = {
          device = "/dev/disk/by-uuid/15382968-c73e-4211-a4f2-460830224829";
        };
      };
    };

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
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

  environment.systemPackages = with pkgs; [
    virt-manager
    minicom
  ];

  swapDevices = [ ];

  networking = {
    hostName = "jb-portable-dev";
    wireless.enable = true;

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
  };

  services = {
    xserver = {
      libinput.enable = true;
    };

    actkbd = {
      enable = true;
      bindings = [
        { keys = [ 225 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -A 10"; }
        { keys = [ 224 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -U 10"; }
      ];
    };

    upower = {
      enable = true;
    };
  };

  virtualisation.libvirtd = {
      enable = true;
      allowedBridges = [
        "br-local"
      ];
  };

  programs.light.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

}
