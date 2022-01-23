{config, pkgs, ...}:
{
  imports = [ ../9net.nix ];

  nine_net = {
    enable = true;
    node_name = "stary_nas";
    ipv4_address = "172.31.1.6";
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" ];

  networking = {
    useDHCP = false;

    hostName = "nas"; # Define your hostname.
    hostId = "3302c071";
  
    useNetworkd = true;
    interfaces = {
      "enp4s0" = {
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
}
