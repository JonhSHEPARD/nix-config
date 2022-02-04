# Server config for iPXE VM
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  services = {
    printing.enable = true;
  };

  environment.systemPackages = with pkgs; [
    ipxe
  ];

}

