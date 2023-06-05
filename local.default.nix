{ ... }:

# Copy this file as 'local.nix'

{
  imports = [
    # Lab CRI
    # ./desktops/lab.nix

    # Laptop DEV
    # ./desktops/devlap.nix
  
    #

    # Server iPXE VM
    # ./servers/ipxe_vm.nix

  ];

  #services.openssh = {
  #  enable = true;
  #  passwordAuthentication = false;
  #};

  system.stateVersion = "23.05";
}
