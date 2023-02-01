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

  users.users.jb = import ./jb.nix { inherit pkgs; };

  time.timeZone = "Europe/Paris";

  environment.systemPackages = with pkgs; [
    # BASE
    zsh
    git
    vim
    neovim
    tree
    unzip
    zip
    # TOOLS
    wget
    bind
    tree
    dnsutils
    inetutils
    iftop
    nload
    nmap
    # DEV
    python310
    python310Packages.poetry
    python310Packages.pip
    python39
  ];

  programs = {
    zsh.enable = true;
    vim.defaultEditor = true;
  };

  nixpkgs.config.allowUnfree = true;

  services.openssh = {
    permitRootLogin = "no";
    passwordAuthentication = false;
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
    };
  };
}

