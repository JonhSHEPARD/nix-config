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
        encrypted = {
          device = "/dev/disk/by-uuid/8b2b8265-c2a7-4dbe-b585-fd6330c50926";
        };
        eswap = {
          device = "/dev/disk/by-uuid/9c82d8ea-189f-4277-a378-d6fca6af1ce1";
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
      #betterlockscreen
      minicom
      nodePackages.pnpm
      xss-lock
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
      device = "/dev/disk/by-uuid/BDAB-FDA5";
      fsType = "vfat";
    };

    "/" = {
      device = "/dev/disk/by-uuid/3660cd38-7772-479b-979f-003919be5e8d";
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
        #killtime = 10;
        #killer = "/run/current-system/systemd/bin/systemctl suspend";
        extraOptions = [
          "-detectsleep"
          "-notify 15"
          "-notifier 'notify-send -u critical -i lock -t 10000 -- 'Locking screen in 15 seconds'"
          "-corners '++--'"
          "-cornerdelay 5"
        ];
      };
      xkb = {
        layout = "us";
        variant = "altgr-intl";
        options = "eurosign:e";
      };
    };
  };

  swapDevices = [
    {
      device = "/dev/disk/by-uuid/e9f6a364-c23f-4798-8618-dc58fb532b67";
    }
  ];

  virtualisation.libvirtd = {
    enable = true;
    allowedBridges = [
      "br-local"
    ];
  };
}
