{ config, lib, pkgs, modulesPath, ... }:

let
  unstable = import <nixos-unstable> {
    config = { allowUnfree = true; };
  };
in
{
  imports = [
    ./default.nix
    ./../modules/network-tools-gui.nix
  ];

  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ];
    extraModulePackages = [ ];

    initrd = {
      # Check for those against generated configuration
      availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
      kernelModules = [ "dm-crypt" "i915" ];

      # Change this to the real values
      luks.devices = {
        eroot = {
          device = "/dev/disk/by-uuid/%%UUID_ROOT%%";
        };
        eswap = {
          device = "/dev/disk/by-uuid/%%UUID_SWAP%%";
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
      bash
      batsignal
      minicom
      nodePackages.pnpm
      (vscode-with-extensions.override {
        vscodeExtensions = with vscode-extensions; [
          dracula-theme.theme-dracula
          vscodevim.vim
          marp-team.marp-vscode
        ];
      })
    ];

    variables = {
      VDPAU_DRIVER = lib.mkDefault "va_gl";
    };
  };

  # Fix this
  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/%%UUID_BOOT%%";
      fsType = "vfat";
    };

    "/" = {
      device = "/dev/disk/by-uuid/%%FS_UUID_ROOT%%";
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
    hostName = "jb-portable-deeplink";

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

    wireless.enable = false;

    networkmanager = {
      enable = true;
    };

    firewall = {
      enable = true;
      allowedTCPPorts = [
        #80
        # 443
      ];
      allowedTCPPortRanges = [
        # { from = 1714; to = 1764; } # KDE Connect
      ];
      allowedUDPPortRanges = [
        # { from = 1714; to = 1764; } # KDE Connect
      ];
      checkReversePath = "loose"; # Needed for WireGuard
    };

    nameservers = [ "1.1.1.1" "9.9.9.9" ];
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  programs = {
    dconf.enable = true;

    light.enable = true;
  };

  services = {
    blueman.enable = true;

    logind = {
      extraConfig = ''
        HandlePowerKey=ignore
      '';
      lidSwitch = "hibernate";
      lidSwitchDocked = "suspend";
      lidSwitchExternalPower = "suspend";
    };

    printing = {
      enable = true;
      drivers = with pkgs; [
      ];
    };

    upower = {
      enable = true;
    };

    xserver = {
      libinput.enable = true;

      xkb = {
        layout = "us";
        variant = "altgr-intl";
        options = "eurosign:e";
      };
    };
  };

  swapDevices = [
    {
      device = "/dev/disk/by-uuid/%%FS_UUID_SWAP%%";
    }
  ];

  virtualisation.libvirtd = {
    enable = true;
    allowedBridges = [
      "br-local"
    ];
  };
}
