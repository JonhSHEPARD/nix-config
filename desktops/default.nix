# Default desktop config
{ config, lib, pkgs, modulesPath, ... }:

let
  chrome = pkgs.writeShellScriptBin "chrome" ''
    google-chrome-stable --enable-features=WebUIDarkMode --force-dark-mode
  '';
  vms = pkgs.writeShellScriptBin "vms" ''
    virt-manager
  '';
in {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  environment = {
    pathsToLink = [
      "/share/nix-direnv"
    ];

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
      direnv
      nix-direnv
      # ALIAS
      chrome
      vms
      # DEV
      apktool
      postgresql
      nodejs
      gnumake
      yarn
      maven
      jbang
      go
      # MEDIA
      asciinema
      asciinema-agg
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
      ncdu
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
      k9s
      docker
      dive
      stern
      terraform
      openstackclient
      ansible
      vault
      # IDE
      jetbrains.datagrip
      jetbrains.idea-ultimate
      jetbrains.goland
      vscode-with-extensions
      sublime4
    ];
  };

  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
    extraConfig = "load-module module-echo-cancel";
  };

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

  nix.settings = {
    keep-outputs = true;
    keep-derivations = true;
  };

  nixpkgs.overlays = [
    (self: super: { nix-direnv = super.nix-direnv.override { enableFlakes = true; }; } )
  ];

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

  sound.enable = true;

  virtualisation.docker.enable = true;
}

