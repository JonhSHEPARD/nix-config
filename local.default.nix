{ ... }:

# Copy this file as 'local.nix'

{
  imports = [
    # Laptop DEV
    # ./desktops/devlap.nix

    # Laptop WORK
    # ./desktops/worklap.nix

    # Server iPXE VM
    # ./servers/ipxe_vm.nix
  ];

  #services.openssh = {
  #  enable = true;
  #  passwordAuthentication = false;
  #};

  system.stateVersion = "23.05";
}
