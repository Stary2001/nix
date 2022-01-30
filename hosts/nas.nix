{config, pkgs, ...}:
{
  imports = [ ../secrets/wifi.nix ../9net.nix ];

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

  networking = {
    useDHCP = false;
    wireless.enable = true;

    hostName = "nas"; # Define your hostname.
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

    8081
    8384 # syncthing
  ];

  # none (tm)
  networking.firewall.allowedUDPPorts = [
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

    guiAddress = "0.0.0.0:8384";
    dataDir = "/data/syncthing";

    openDefaultPorts = true;
  };
}
