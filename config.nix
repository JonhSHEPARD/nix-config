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
    zsh
    git
    vim
    wget
    bind
    tree
    unzip
    dnsutils
    # DEV
    python310
  ];

  programs = {
    zsh.enable = true;
    vim.defaultEditor = true;
  };

  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nixUnstable; # or versioned attributes like nix_2_4
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}

