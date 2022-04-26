# Desktop config for Lab CRI
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # audio
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };

  services = {
    printing.enable = true;
    #k3s = {
    #    enable = true;
    #    role = "server";
    #};

    xserver = {
      enable = true;
      layout = "us";
      xkbVariant = "altgr-intl";
      xkbOptions = "eurosign:e";

      displayManager = {
        autoLogin = {
          enable = true;
          user = "jb";
        };
      };
      windowManager.i3 = {
        enable = true;
        package = pkgs.i3-gaps;
      };
    };

    teamviewer.enable = true;

    pcscd.enable = true;
    udev.packages = with pkgs; [ yubikey-personalization ]; 
  };

  environment = {
    shellInit = ''
      export GPG_TTY="$(tty)"
      gpg-connect-agent /bye
      export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
    '';

    systemPackages = with pkgs; [
      # SYSTEM
      pciutils
      pavucontrol
      arandr
      # DEV
      apktool
      postgresql
      nodejs
      gnumake
      # TOOLS
      firefox
      gnupg
      yubikey-personalization
      teamviewer
      lightdm_gtk_greeter
      pinentry-curses
      pinentry-qt
      paperkey
      teams
      imagemagick
      discord
      slack
      nomacs
      neofetch
      flameshot
      thunderbird
      libreoffice
      gimp
      # DEVOPS
      #k3s
      #kubectl
      #kubectx
      krb5
      docker
      docker-compose
      # IDE
      jetbrains.clion
      jetbrains.webstorm
      jetbrains.datagrip
      jetbrains.pycharm-professional
      jetbrains.idea-ultimate
      sublime4
    ];
  };

  virtualisation.docker.enable = true;

  krb5 = {
    enable = true;
    libdefaults = {
      default_realm = "CRI.EPITA.FR";
      dns_fallback = true;
      dns_canonicalize_hostname = false;
      rnds = false;
      forwardable = true;
    };
    realms = {
      "CRI.EPITA.FR" = {
        admin_server = "kerberos.pie.cri.epita.fr";
      };
    }; 
  };

  programs = {
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryFlavor = "curses";
    };

    zsh.enable = true; 
  };
  
}

