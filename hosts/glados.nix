{config, pkgs, ...}:
{
  imports = [ ../unstable-overlays.nix ../9net.nix ../netns.nix ../netns-wg.nix ../qemu-hook.nix ../desktop-ish.nix ../netns-wrapper.nix ];

  services.tinc.networks."9net"= {
    name = "stary_glados";
    debugLevel = 3;
    chroot = false;
    interfaceType = "tap";
    settings = {
      mode = "Switch";
    };
  };

  boot.kernelParams = [ "vfio-pci.ids=10de:0fc1,10de:0e1b" ];
  boot.kernelModules = [ "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio" "i2c-dev" ];
  boot.blacklistedKernelModules = [ "nvidia" "nouveau" ];
  boot.zfs.forceImportAll = true;

  boot.postBootCommands = ''
    echo "Loading ZFS keys from root (hopefully)"
    ${pkgs.zfs}/bin/zfs load-key -a
  '';

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" ];
  
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  services.xserver.windowManager.i3.enable = true;
  services.xserver.layout = "gb";

  users.users.stary.extraGroups = [ "libvirtd" "i2c" "plugdev" "dialout" "openrazer" ];

  environment.systemPackages = with pkgs; [
      razergenie
      hledger
      hledger-web
      aarch64-none-gcc
      tio
  ];
  
  # Enable sound.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  networking = {
    hostName = "glados"; # Define your hostname.
    hostId = "765a774a";
  
    useNetworkd = true;
    bridges = {
      br0 = {
        interfaces = [ "enp6s0" ];
      };
      "9net-bridge" = {
        interfaces = [];
      };
    };
    interfaces = {
      br0 = {
        useDHCP = true;
      };

      "9net-bridge" = {
        ipv4 = {
          addresses = [ { address = "172.31.1.5"; prefixLength = 16; } ];
        };
      };
    };

    nameservers = [ "8.8.8.8" ];
  };

  systemd.network.networks."40-br0" = {
    dhcpV4Config = {
      UseDNS = false;
    };
  };

  # https://github.com/NixOS/nixpkgs/issues/30904
  systemd.services.systemd-networkd-wait-online.serviceConfig.ExecStart = [
    "" # clear old command
    "${config.systemd.package}/lib/systemd/systemd-networkd-wait-online --ignore 9net-bridge"
  ];

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "Europe/London";

  # for ddcutil
  hardware.i2c.enable = true;
  systemd.services.shutdown-monitor = {
    wantedBy = [ "multi-user.target" ];
    description = "tell That Monitor to go away";
    serviceConfig = {
        Type = "oneshot";
        ExecStop = "${pkgs.ddcutil}/bin/ddcutil -d 2 setvcp d6 5";
        RemainAfterExit = "true";
      };
  };

  hardware.openrazer.enable = true;

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

  services.cron.systemCronJobs = [ "@weekly stary ${pkgs.python3}/bin/python /home/stary/bin/do_rofi_stuff.py /home/stary/.cache/rofi3.druncache" ];
  services.lorri.enable = true;

  services.dnsmasq.enable = true;
  services.dnsmasq.resolveLocalQueries = false;
  services.dnsmasq.extraConfig = ''
port=0 # disable DNS server
interface=br0
bind-interfaces
dhcp-range=192.168.0.0,proxy
log-dhcp

enable-tftp
tftp-root=/var/lib/tftp
pxe-service=0,"Raspberry Pi Boot"
  '';

  # Set up wireguard.
  my.wireguard = {
    enable = true;
    address = { IPv4 = "10.66.81.209/32"; IPv6 = "fc00:bbbb:bbbb:bb01::3:51d0/128"; };
    peer = "+iQWuT3wb2DCy1u2eUKovhJTCB4aUdJUnpxGtONDIVE=";
    endpoint = "185.248.85.18:51820";
    privateKey = "/etc/wireguard/mullvad.key";
    dns = "193.138.218.74";
  };

  programs.kdeconnect.enable = true;

  networking.firewall.enable = false;
}
