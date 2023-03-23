{ config, lib, pkgs, modulesPath, ... }:

{
  environment.systemPackages = with pkgs; [
    gns3-gui
    gns3-server
    dynamips
  ];

  users.groups.ubridge = { };

  security.wrappers.ubridge = {
    source = "${pkgs.ubridge}/bin/ubridge";
    capabilities = "cap_net_admin,cap_net_raw=ep";
    owner = "root";
    group = "ubridge";
    permissions = "u+rx,g+x";
  };

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };
}
