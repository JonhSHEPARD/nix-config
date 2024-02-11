{ config, pkgs, ... }:

let
  custom-python-packages = ps: with ps; [
    requests
    requests-oauthlib
  ];
in
{
  imports = [
    ./local.nix
  ];

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  users.users.jb = import ./jb.nix { inherit pkgs; };

  time.timeZone = "Europe/Paris";

  environment.systemPackages = with pkgs; [
    (python310.withPackages custom-python-packages)
    ansible
    awscli
    bind
    dnsutils
    git
    go
    htop
    iftop
    inetutils
    ipcalc
    jq
    ldns
    ncdu
    neofetch
    neovim
    nload
    nmap
    openvpn3
    poetry
    powertop
    siege
    smartmontools
    tree
    tree
    unzip
    vim
    wget
    wireguard-tools
    zip
    zsh
  ];

  programs = {
    zsh.enable = true;
    vim.defaultEditor = true;
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

  services.openssh.settings = {
    PermitRootLogin = "no";
    PasswordAuthentication = false;
  };

  nix = {
    package = pkgs.nixUnstable; # or versioned attributes like nix_2_4
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
    settings = {
      auto-optimise-store = true;
      substituters = [ "https://cache.nixos.org" "https://s3.cri.epita.fr/cri-nix-cache.s3.cri.epita.fr" ];
      trusted-users = [ "root" "jb" ];
    };
  };
}

