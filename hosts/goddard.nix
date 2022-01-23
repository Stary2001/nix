{config, pkgs, ...}:
{
  imports = [ ../9net.nix ../netns.nix ../netns-wg.nix ../rutorrent-overlay.nix ../flood-overlay.nix ../modules/flood.nix ../secrets/oauth2_proxy.nix ];

  nine_net = {
    enable = true;
    node_name = "stary_goddard";
    ipv4_address = "172.31.0.3";
  };

  networking = {
    useDHCP = false;

    hostName = "goddard"; # Define your hostname.
    hostId = "765a774a";
  
    useNetworkd = true;
    interfaces = {
      "ens3" = {
        useDHCP = true;
      };
    };

    nameservers = [ "8.8.8.8" ];
  };

  # Set your time zone.
  time.timeZone = "Europe/London";

  services.nginx.enable = true;

  services.rtorrent = {
    enable = true;
    port = 56059; # port obtained via mullvad port forwarding
    dhtPort = 56431; # port obtained via mullvad port forwarding

    # yolo it
    useDHT = true;
    usePEX = true;
    useUDPTrackers = true;

    openFirewall = true;
  };

  services.flood = {
    enable = true;
    hostName = "goddard.9net.org";
    port = 3000;
    auth = "none";

    nginx.enable = true;
  };

  #services.rutorrent = {
  #  enable = true;
  #  hostName = "goddard.9net.org";
  #  plugins = [ "httprpc" "data" "diskspace" "edit" "erasedata" "theme" "trafic" ];

  #  nginx.enable = true;
  #};

  # Enable + require SSL
  services.nginx.virtualHosts."goddard.9net.org" = {
    enableACME = true;
    forceSSL = true;
  };

  security.acme = {
    acceptTerms = true;
    certs = {
      "goddard.9net.org".email = "zek@9net.org";
    };
  };

  users.users.oauth2_proxy.group = "oauth2_proxy";
  users.groups.oauth2_proxy = {};

  services.oauth2_proxy = {
    # clientID/clientSecret
    enable = true;
    provider = "google";
    nginx = {
      virtualHosts = [ "goddard.9net.org" ];
    };
    email = {
      addresses = "mctinfoilball@gmail.com";
    };
  };

  # Set up wireguard, confine rtorrent to wireguard
  my.wireguard = {
    enable = true;
    address = { IPv4 = "10.65.198.147/32"; IPv6 = "fc00:bbbb:bbbb:bb01::2:c692/128"; };
    peer = "VZwE8hrpNzg6SMwn9LtEqonXzSWd5dkFk62PrNWFW3Y=";
    endpoint = "185.195.232.66:51820";
    privateKey = "/etc/wireguard/mullvad.key";
    dns = "193.138.218.74";
  };

  systemd.services.rtorrent = {
    bindsTo = [ "wg.service" ];
    after = [ "wg.service" ];
    serviceConfig.NetworkNamespacePath = "/var/run/netns/wg";
  };

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [
    22 # ssh
    80 # http
    443 # https
    5355 # llmnr
  ];

  # none (tm)
  networking.firewall.allowedUDPPorts = [
  ];
}
