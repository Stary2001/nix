{config, pkgs, ...}:
{
  imports = [ ];

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

  # https://github.com/NixOS/nixpkgs/issues/30904
  #systemd.services.systemd-networkd-wait-online.serviceConfig.ExecStart = [
  #  "" # clear old command
  #  "${config.systemd.package}/lib/systemd/systemd-networkd-wait-online --ignore 9net-bridge"
  #];

  # Set your time zone.
  time.timeZone = "Europe/London";

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
