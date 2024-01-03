{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    ./default.nix
    ./../modules/network-tools-gui.nix
  ];

  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ];
    extraModulePackages = [ ];

    initrd = {
      availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
      kernelModules = [ "dm-crypt" "i915" ];

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
      betterlockscreen
      libsForQt5.kdeconnect-kde
      minicom
      nodePackages.pnpm
      virt-manager
      virtiofsd
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

    wireless.enable = false;

    networkmanager = {
      enable = true;
    };

    firewall = {
      enable = true;
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
      checkReversePath = "loose";
    };

    nameservers = [ "1.1.1.1" "9.9.9.9" ];
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  programs = {
    dconf.enable = true;

    light.enable = true;

    #xss-lock = {
    #  enable = true;
    #  lockerCommand = "${pkgs.betterlockscreen}/bin/betterlockscreen -l";
    #};
  };

  services = {
    #actkbd = {
    #  enable = true;
    #  bindings = [
    #    { keys = [ 225 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -A 10"; }
    #    { keys = [ 224 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -U 10"; }
    #  ];
    #};

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
