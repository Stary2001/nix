{config, pkgs, ...}:
{
  imports = [ ../secrets/wifi.nix ../9net.nix ../avahi.nix ];

  fileSystems."/".options = [ "defaults" "size=2G" "mode=755" ];

  nine_net = {
    enable = true;
    node_name = "stary_nas";
    ipv4_address = "172.31.1.7";
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" ];

  boot.extraModulePackages = [
    # crap usb wifi
    config.boot.kernelPackages.rtl88x2bu
  ];

  boot.kernel.sysctl = {
    # https://docs.syncthing.net/users/faq.html#inotify-limits
    # Add more inotify watches.

    "fs.inotify.max_user_watches" = 204800;
  };

  networking = {
    useDHCP = false;
    wireless.enable = true;

    hostName = "karman"; # Define your hostname.
    hostId = "3302c071";
  
    useNetworkd = true;
    interfaces = {
      "enp4s0" = {
        useDHCP = true;
      };

      "wlp0s20u2" = {
        useDHCP = true;
      };
    };

    nameservers = [ "8.8.8.8" ];
  };

  # Set your time zone.
  time.timeZone = "Europe/London";

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [
    22 # ssh
    80 # http
    443 # https
    5355 # llmnr

    111 2049 4000 4001 4002 20048 # nfsv3
  ];

  # none (tm)
  networking.firewall.allowedUDPPorts = [
    111 2049 4000 4001 4002 20048 # nfsv3
  ];

  services.smokeping = {
    enable = true;
    hostName = "192.168.0.71";
    host = null;

    targetConfig = ''
      probe = FPing
      menu = Top
      title = Network Latency Grapher
      remark = Welcome to the SmokePing website of hacking society. \
               Here you will learn all about the latency of our network.

      + GoogleDNS
      menu = Google DNS
      title = Google DNS 8.8.8.8
      host = 8.8.8.8

      + Local
      menu = Local
      title = Router
      host = 192.168.0.1
    '';
  };

  services.syncthing = {
    enable = true;
    overrideDevices = false;
    overrideFolders = false;

    dataDir = "/data/syncthing";

    openDefaultPorts = true;
  };

  services.nfs.server = {
    enable = true;
    exports = ''
      /export 192.168.0.65(rw,fsid=0,no_subtree_check)
      /export/syncthing 192.168.0.65(rw,nohide,insecure,no_subtree_check)
      /export/media 192.168.0.65(rw,nohide,insecure,no_subtree_check)
    '';
    lockdPort = 4001;
    mountdPort = 4002;
    statdPort = 4000;
  };

  networking.nat.enable = true;
  networking.nat.internalInterfaces = ["ve-+"];
  networking.nat.externalInterface = "enp4s0";

  networking.nat.extraCommands = ''
    iptables -t nat -A nixos-nat-pre -p tcp -d 172.31.1.7 --dport 3000 -j DNAT --to 172.30.0.2:3000
  '';

  systemd.network.networks."40-veth" = {
    name = "ve-*";
    # Do nothing, hopefully
  };

  containers.torrent = {
    autoStart = true;

    privateNetwork = true;
    hostAddress = "172.30.0.1";
    localAddress = "172.30.0.2";

    bindMounts = {
      "/var/lib/rtorrent" = {
        hostPath = "/var/lib/rtorrent";
        isReadOnly = false;
      };

      "/data/rtorrent" = {
        hostPath = "/data/rtorrent";
        isReadOnly = false;
      };

     "/var/lib/flood" = {
        hostPath = "/var/lib/flood";
        isReadOnly = false;
      };

      "/etc/wireguard/mullvad.key" = {
        hostPath = "/etc/wireguard/mullvad.key";
        isReadOnly = true;
      };
    };

    config = {
      imports = [ ./container-torrent.nix ];
    };
  };

  services.vnstat.enable = true;

  services.zfs.autoSnapshot.enable = true;
  services.zfs.autoScrub.enable = true;

  users.users.stary.extraGroups = [ "libvirtd" ];
   virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";

    #qemu.ovmf.package = pkgs.OVMF.override { secureBoot = true; tpmSupport = true; };
    #qemu.swtpm.enable = true;
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts = {
      "karman.9net.org" = { default = true; };
      "flood.home.9net.org" = { locations."/".proxyPass = "http://172.30.0.2:3000"; };

      # security: "dude trust me"
      "syncthing.home.9net.org" = {
        locations."/" = {
          extraConfig = ''
            proxy_set_header Host localhost;
            proxy_pass http://localhost:8384;
          '';
        };
      };

      "smokeping.home.9net.org" = { locations."/".proxyPass = "http://localhost:8081/"; };
    };
  };
}
