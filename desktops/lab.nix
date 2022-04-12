{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ ./default.nix ];

  boot = { 
    kernelModules = [ "kvm-intel" "vfio_pci" "vfio" "vfio_iommu_type1" "vfio_virqfd" ];
    extraModulePackages = [ ];

    initrd = {
      availableKernelModules = [ "xhci_pci" "ehci_pci" "ata_piix" "ahci" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];
      kernelModules = [ "dm-snapshot" "dm-mod" "dm-cache" "dm-cache-smq" "dm-thin-pool" "dm-raid" "raid1" "dm-crypt" ];
      
      extraUtilsCommands = ''
        for BIN in ${pkgs.thin-provisioning-tools}/{s,}bin/*; do
          copy_bin_and_libs $BIN
        done
      '';

      # Before LVM commands are executed, ensure that LVM knows exactly where our cache and thin provisioning tools are
      preLVMCommands = ''
        mkdir -p /etc/lvm
        echo "global/thin_check_executable = "$(which thin_check)"" >> /etc/lvm/lvm.conf
        echo "global/cache_check_executable = "$(which cache_check)"" >> /etc/lvm/lvm.conf
        echo "global/cache_dump_executable = "$(which cache_dump)"" >> /etc/lvm/lvm.conf
        echo "global/cache_repair_executable = "$(which cache_repair)"" >> /etc/lvm/lvm.conf
        echo "global/thin_dump_executable = "$(which thin_dump)"" >> /etc/lvm/lvm.conf
        echo "global/thin_repair_executable = "$(which thin_repair)"" >> /etc/lvm/lvm.conf
      '';

      luks.devices = {
        cryptlvm = {
          device = "/dev/disk/by-uuid/714ef2b6-f094-4bef-aa69-7a54c4330c51";
          preLVM = false;
        };
      };
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

  services.xserver.videoDrivers = [ "nvidia" "intel" ];

  environment.systemPackages = with pkgs; [
    virt-manager
  ];

  swapDevices = [ ];

  networking = {
    hostName = "jb-lab";
 
    bridges = {
      br-cri-lab = {
        interfaces = [
          "eno1"
        ];
      };
      br-local-pxe = {
        interfaces = [];
      };
    };

    interfaces = {
      br-cri-lab = {
        ipv4.addresses = [
          {
            address = "192.168.240.170";
            prefixLength = 24;
          }
        ];
      };
      eno1.useDHCP = false;
    };

    defaultGateway = "192.168.240.254";
    nameservers = [ "91.243.117.211" "8.8.8.8" ];

    dhcpcd.denyInterfaces = [
      "eno1"
      "br-cri-lab"
      "br-local-pxe"
    ];

    #firewall.allowedTCPPorts = [
    #  6443
    #];
 };

  programs = {
    dconf.enable = true;
  };

  virtualisation.libvirtd = {
    enable = true;
    allowedBridges = [
      "br-cri-lab"
      "br-local-pxe"
    ];
  };

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
