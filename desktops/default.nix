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
      #k3s
      alacritty
      apktool
      arandr
      asciinema
      asciinema-agg
      bashmount
      betterdiscordctl
      chrome
      direnv
      discord
      dive
      docker
      feh
      filezilla
      firefox
      flameshot
      gimp
      git-lfs
      gnome.nautilus
      gnumake
      gnupg
      google-chrome
      gtk-engine-murrine
      gtk_engines
      imagemagick
      inkscape
      jami-client-qt
      jami-daemon
      jbang
      jetbrains.datagrip
      jetbrains.goland
      jetbrains.idea-ultimate
      krew
      kubecolor
      kubectl
      kubectl-doctor
      kubectl-tree
      kubectx
      kubernetes-helm
      libreoffice
      lightdm_gtk_greeter
      lxappearance
      maven
      nix-direnv
      nodejs
      nomacs
      nordic
      oh-my-zsh
      openstackclient
      paperkey
      pavucontrol
      pciutils
      pinentry-qt
      polybarFull
      postgresql
      qbittorrent
      rxvt-unicode
      slack
      stern
      sublime4
      teamviewer
      terraform
      thunderbird
      usbutils
      vault
      vlc
      vms
      vscode-with-extensions
      xournal
      yarn
      yubikey-personalization
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

