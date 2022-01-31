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

  #networking.nat.enable = true;
  #networking.nat.internalInterfaces = ["ve-+"];
  #networking.nat.externalInterface = "ens3";

  #systemd.network.networks."40-veth" = {
  #  name = "ve-*";
  #  # Do nothing, hopefully
  #};

  services.nginx.enable = true;
  # Enable + require SSL, and proxy
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
