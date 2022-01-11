{config, pkgs, ...}:
{
  imports = [ ../9net.nix ../netns.nix ../netns-wg.nix ../rutorrent-overlay.nix ];

  services.tinc.networks."9net"= {
    name = "stary_goddard";
    debugLevel = 0;
    chroot = false;
    interfaceType = "tap";
    settings = {
      mode = "Switch";
    };
  };

  networking = {
    useDHCP = false;

    hostName = "goddard"; # Define your hostname.
    hostId = "765a774a";
  
    useNetworkd = true;
    bridges = {
      "9net-bridge" = {
        interfaces = [];
      };
    };
    interfaces = {
      "ens3" = {
        useDHCP = true;
      };

      "9net-bridge" = {
        ipv4 = {
          addresses = [ { address = "172.31.0.3"; prefixLength = 16; } ];
        };
      };
    };

    nameservers = [ "8.8.8.8" ];
  };

  # https://github.com/NixOS/nixpkgs/issues/30904
  systemd.services.systemd-networkd-wait-online.serviceConfig.ExecStart = [
    "" # clear old command
    "${config.systemd.package}/lib/systemd/systemd-networkd-wait-online --ignore 9net-bridge"
  ];

  # Set your time zone.
  time.timeZone = "Europe/London";

  services.nginx.enable = true;

  services.rtorrent = {
    enable = true;
    port = 56059; # port obtained via mullvad port forwarding
  };

  services.rutorrent = {
    enable = true;
    hostName = "goddard.9net.org";
    plugins = [ "httprpc" "data" "diskspace" "edit" "erasedata" "theme" "trafic" ];

    nginx.enable = true;
  };

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
}
