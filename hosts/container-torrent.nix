{config, pkgs, lib, ...}:
{
  imports = [ ../modules/rtorrent.nix../modules/flood.nix ];

  environment.systemPackages = [ pkgs.rxvt_unicode.terminfo ];

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 3000 ];
  networking.firewall.allowedUDPPorts = [];

  networking.interfaces.eth0.ipv4.routes = [
    { address = "185.195.232.66"; prefixLength = 32; via = "172.30.0.1"; }
    { address = "172.31.0.0"; prefixLength = 16; via = "172.30.0.1"; }
  ];

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
    downloadDir = "/data/rtorrent/";
  };

  services.flood = {
    enable = true;
    listen = "0.0.0.0";
    hostName = "flood.home.9net.org";
    port = 3000;
    auth = "none";
  };

  systemd.services.rtorrent = {
    bindsTo = [ "wireguard-wg0.service" ];
    after = [ "wireguard-wg0.service" ];
  };

  systemd.services.resolvconf.enable = lib.mkForce false;
  systemd.services.hack-container-dns = {
    wantedBy = [ "network-online.target" ];
    description = "hack around container dns being bad";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'sleep 1 && echo \"nameserver 193.138.218.74\" > /etc/resolv.conf'";
      RemainAfterExit = "true";
    };
  };
}
