{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ ./default.nix ];

  boot = {
    kernelModules = [ "kvm-intel" "vfio_pci" "vfio" "vfio_iommu_type1" "vfio_virqfd" ];
    extraModulePackages = [ ];

    initrd = {
      availableKernelModules = [ "xhci_pci" "ehci_pci" "ata_piix" "ahci" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];
      kernelModules = [ "dm-snapshot" "dm-mod" "dm-cache" "dm-cache-smq" "dm-thin-pool" "dm-raid" "raid1" "dm-crypt" ];
    };

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  services.lvm.boot.thin.enable = true;

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/A00E-E1DB";
      fsType = "vfat";
    };

    "/" = {
      device = "/dev/disk/by-uuid/199b0b89-1216-4ccc-a48c-91053f43928c";
      fsType = "ext4";
    };

    "/nix" = {
      device = "/dev/disk/by-uuid/bcedff18-a110-4b04-982a-0efea7846a33";
      fsType = "ext4";
    };
  };

  environment.systemPackages = with pkgs; [
  ];

  swapDevices = [ ];

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
