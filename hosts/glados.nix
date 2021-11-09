{config, ...}: 
{
  imports = [ ../9net.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" ];
  
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
}