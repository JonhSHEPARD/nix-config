# Default desktop config
{ config, lib, pkgs, modulesPath, ... }:

let
  unstable = import <nixos-unstable> {
    config = { allowUnfree = true; };
  };
  chrome = pkgs.writeShellScriptBin "chrome" ''
    google-chrome-stable --enable-features=WebUIDarkMode --force-dark-mode
  '';
  vms = pkgs.writeShellScriptBin "vms" ''
    virt-manager
  '';
in
{
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
      gnumake
      gnupg
      google-chrome
      gtk-engine-murrine
      gtk_engines
      imagemagick
      inkscape
      jbang
      jdk17
      libnotify
      libreoffice
      lightdm_gtk_greeter
      lxappearance
      maven
      nix-direnv
      nodejs
      nomacs
      nordic
      oh-my-zsh
      paperkey
      pavucontrol
      pciutils
      pinentry-qt
      polybarFull
      postgresql
      qbittorrent
      rxvt-unicode
      terraform
      thunderbird
      usbutils
      vault
      virt-manager
      virtiofsd
      vlc
      vms
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

  nix.settings = {
    keep-outputs = true;
    keep-derivations = true;
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

  services = {
    printing.enable = true;

    xserver = {
      enable = true;
      desktopManager = {
        xterm.enable = false;
        xfce = {
          enable = true;
          noDesktop = true;
          enableXfwm = false;
        };
      };
      displayManager = {
        autoLogin = {
          enable = true;
          user = "jb";
        };
        defaultSession = "xfce+i3";
      };
      windowManager.i3 = {
        enable = true;
        package = pkgs.i3-gaps;
      };
    };

    pcscd.enable = true;
    udev.packages = with pkgs; [ yubikey-personalization ];

    gvfs.enable = true;
  };

  sound.enable = true;

  virtualisation.docker.enable = true;
}

