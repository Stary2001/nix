# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let unstable = import <nixos-unstable> {
  config = config.nixpkgs.config;
}; in
{
  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.permittedInsecurePackages = [
         "electron-11.5.0"
  ];

  nixpkgs.overlays = [ (self: super: {
    polybar = super.polybar.override {
      pulseSupport = true;
      i3Support = true;
    };
  })

  (self: super: {
    libvirt = unstable.libvirt;
    virt-manager = unstable.virt-manager;
    qemu = unstable.qemu;
    sublime4 = unstable.sublime4;
    kicad = unstable.kicad;
  })

  (self: super: {
    pinned-geant4 = ( super.callPackage ./pkgs/geant4/default.nix { qtbase = super.qtbase; wrapQtAppsHook = super.wrapQtAppsHook; } );
    pinned-root =  ( super.callPackage ./pkgs/root/default.nix { Cocoa = null; CoreSymbolication = null; OpenGL = null; } );
  })

  ( self: super: {
    flashplayer = ( super.callPackage ./pkgs/flashplayer.nix {} );
  })
  ];

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "uk";
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.stary = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  environment.systemPackages = with pkgs; [
     wget
     git
     yadm
     killall
     file
     cron
     rxvt-unicode.terminfo
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  services.cron.enable = true;
}

