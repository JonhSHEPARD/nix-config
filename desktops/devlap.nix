{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    ./default.nix
    ./../services/fusuma.nix
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

  swapDevices = [ ];

  networking = {
    hostName = "jb-portable-dev";
    wireless.enable = true;
    interfaces = {
      enp0s31f6.useDHCP = true;
      wlp2s0.useDHCP = true;
    };
  };

  services = {
    actkbd.enable = true;
    xserver = {
      synaptics.enable = true;
    };
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

}
