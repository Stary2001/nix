{config, pkgs, ...}:
{
  imports = [ ../rutorrent-overlay.nix ../flood-overlay.nix ../modules/flood.nix ];

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 3000 ];
  networking.firewall.allowedUDPPorts = [];

  networking.interfaces.eth0.ipv4.routes = [ { address = "185.195.232.66"; prefixLength = 32; via = "172.30.0.1"; } ];

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
    dataDir = "/data/rtorrent";
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
}