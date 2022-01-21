{ ... }:

# Copy this file as 'local.nix'

{
  imports = [
    # Lab CRI
    # desktops/lab.nix

    # Laptop DEV
    # desktops/devlap.nix
  ];

  #services.openssh.enable = true;

  system.stateVersion = "21.11";
}
