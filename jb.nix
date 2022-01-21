{ pkgs, ... }:

{
  description = "Jean-Baptiste Bussignies";
  isNormalUser = true;
  createHome = true;
  extraGroups = [ "wheel" ];
  shell = pkgs.zsh;
  openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO1XQ2eo0i0ha7GbfnJcIoo2EfrA63hs/sC+mKupRdWY" ];
}

