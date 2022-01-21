{ config, pkgs, ... }:

{
  imports = [
    ./local.nix
  ];

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };


  time.timeZone = "Europe/Paris";

  environment.systemPackages = with pkgs; [
    arandr
    lightdm_gtk_greeter
    pinentry-curses
    pinentry-qt
    paperkey
  ];

  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nixUnstable; # or versioned attributes like nix_2_4
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}

