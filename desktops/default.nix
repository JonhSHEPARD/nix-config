# Default desktop config
{ config, lib, pkgs, modulesPath, ... }:

let
  chrome = pkgs.writeShellScriptBin "chrome" ''
    google-chrome-stable --enable-features=WebUIDarkMode --force-dark-mode
  '';
in {
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

    gvfs.enable = true;
  };

  environment = {
    shellInit = ''
      export GPG_TTY="$(tty)"
      gpg-connect-agent /bye
      export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"

      export OS_CLOUD=openstack
    '';

    systemPackages = with pkgs; [
      # SYSTEM
      pciutils
      usbutils
      pavucontrol
      arandr
      wireshark
      gnome.nautilus
      gvfs
      bashmount
      oh-my-zsh
      alacritty
      rxvt-unicode
      polybarFull
      htop
      gtk_engines
      gtk-engine-murrine
      lxappearance
      nordic
      chrome
      # DEV
      apktool
      postgresql
      nodejs
      gnumake
      yarn
      # MEDIA
      feh
      imagemagick
      nomacs
      flameshot
      libreoffice
      gimp
      vlc
      jami-daemon
      jami-client-qt
      qbittorrent
      inkscape
      xournal
      # TOOLS
      firefox
      google-chrome
      gnupg
      yubikey-personalization
      teamviewer
      lightdm_gtk_greeter
      pinentry-curses
      pinentry-qt
      paperkey
      teams
      discord
      betterdiscordctl
      slack
      neofetch
      thunderbird
      filezilla
      # DEVOPS
      #k3s
      krew
      kubectl
      kubectl-tree
      kubectl-doctor
      kubecolor
      kubectx
      kubernetes-helm
      krb5
      docker
      docker-compose
      stern
      terraform
      openstackclient
      ansible
      # IDE
      jetbrains.clion
      jetbrains.webstorm
      jetbrains.datagrip
      jetbrains.pycharm-professional
      jetbrains.idea-ultimate
      vscode-with-extensions
      sublime4
      # PYTHON
      openai
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
      enableExtraSocket = true;
      pinentryFlavor = "qt";
    };

    zsh.enable = true; 
  };
}

