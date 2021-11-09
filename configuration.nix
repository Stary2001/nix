# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let unstable = import <nixos-unstable> {
  config = config.nixpkgs.config;
}; in
{
  boot.kernelParams = [ "vfio-pci.ids=10de:0fc1,10de:0e1b" ];
  boot.kernelModules = [ "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio" ];
  boot.blacklistedKernelModules = [ "nvidia" "nouveau" ];

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
    kicad-unstable = unstable.kicad-unstable;
  })

  ];

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "uk";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  services.xserver.windowManager.i3.enable = true;
  services.xserver.layout = "gb";  

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.stary = {
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" ]; # Enable ‘sudo’ for the user.
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     wget
     google-chrome
     autorandr
     git
     yadm
     rofi
     dex
     picom
     feh
     xbindkeys
     pavucontrol
     rxvt-unicode
     polybar
     killall

     slack
     discord
     hexchat
     todoist-electron
     signal-desktop
    
     python3
     rustup

     file
     carla
     jack2
     libvirt
     virt-manager

     sublime4
     maim
     slop
     xclip
     libreoffice

     # https://github.com/NixOS/nixpkgs/issues/2448
     dconf
     kicad-unstable
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

  services.avahi = {
    enable = true;
    nssmdns = true;
  };

  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
  };

  services.tinc.networks."9net"= {
    name = "stary_glados";
    debugLevel = 3;
    chroot = false;
    interfaceType = "tap";
    settings = {
      mode = "Switch";
    };
  };

  systemd.services.libvirtd.preStart = ''
    mkdir -p /var/lib/libvirt/hooks
    chmod 755 /var/lib/libvirt/hooks

    # Copy hook files
    cp -f /etc/libvirt/hooks/qemu /var/lib/libvirt/hooks/qemu

    # Make them executable
    chmod +x /var/lib/libvirt/hooks/qemu
  '';

  environment.etc = {
    "libvirt/hooks/qemu".source = pkgs.writeScript "tinc-up" ''
        #!${pkgs.stdenv.shell}
        if [ "$1" == "win10" ] || [ "$1" == "a" ]; then
          if [ "$2" == "started" ]; then
            echo -n '1' > /dev/serial/by-id/usb-Raspberry_Pi_Pico_E66038B7136D282F-if00
          elif [ "$2" == "release" ]; then
            echo -n '2' > /dev/serial/by-id/usb-Raspberry_Pi_Pico_E66038B7136D282F-if00
          fi
        fi
    '';
  };
}

