{config, pkgs, ...}:
{
  imports = [ ../9net.nix ];

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
}
