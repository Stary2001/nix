{config, pkgs, ...}:
{
  imports = [ ../9net.nix ../secrets/oauth2_proxy.nix ];

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

  networking.nat.enable = true;
  networking.nat.internalInterfaces = ["ve-+"];
  networking.nat.externalInterface = "ens3";

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
      imports = [ ../rutorrent-overlay.nix ../flood-overlay.nix ../modules/flood.nix ];

      networking.nameservers = [ "8.8.8.8" ];

      networking.firewall.enable = false;

      networking.interfaces.eth0.ipv4.routes = [ { address = "185.195.232.66"; prefixLength = 32; via = "${config.containers.torrent.hostAddress}"; } ];

      networking.wireguard.interfaces = {
        wg0 = {
          ips = [ "10.65.198.147/32" "fc00:bbbb:bbbb:bb01::2:c692/128" ];
          privateKeyFile = "/etc/wireguard/mullvad.key";
          peers = [
            { allowedIPs = [ "0.0.0.0/0" "::/0" ];
              publicKey  = "VZwE8hrpNzg6SMwn9LtEqonXzSWd5dkFk62PrNWFW3Y=";
              endpoint   = "185.195.232.66:51820"; }
          ];
        };
      };

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
        listen = "0.0.0.0";
        hostName = "goddard.9net.org";
        port = 3000;
        auth = "none";
      };

      systemd.services.rtorrent = {
        bindsTo = [ "wireguard-wg0.service" ];
        after = [ "wireguard-wg0.service" ];
      };
    };
  };

  services.nginx.enable = true;
  # Enable + require SSL, and proxy
  services.nginx.virtualHosts."goddard.9net.org" = {
    locations."/".extraConfig =
    ''
      proxy_pass 'http://${config.containers.torrent.localAddress}:${toString config.containers.torrent.config.services.flood.port}';
    '';
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
