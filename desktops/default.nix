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

    xserver = {
      enable = true;
      layout = "us";
      xkbOptions = "eurosign:e";

      displayManager.lightdm.enable = true;
      windowManager.i3 = {
        enable = true;
        package = pkgs.i3-gaps;
      };
    };

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
      zsh
      git
      vim
      wget
      firefox
      gnupg
      python310
      pciutils
      yubikey-personalization
    ]; 
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

  networking = {
    hostName = "jb-lab";
    interfaces = {
      eno1.useDHCP = true;
    };
  };
}

