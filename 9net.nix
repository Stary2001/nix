{ config, pkgs, lib, ... } :
with lib;
{
   options.nine_net = {
     enable = mkEnableOption "nine_net";
     node_name = mkOption {
       type = types.str;
       description = ''
         Node name to use for tinc.
       '';
     };
     ipv4_address = mkOption {
       type = types.str;
       description = ''
         IPv4 address to use for tinc.
       '';
     };
   };

   config = mkIf config.nine_net.enable {
    networking.bridges."9net-bridge" = { interfaces = []; };
    networking.interfaces."9net-bridge" = {
      ipv4 = {
        addresses = [ { address = "${config.nine_net.ipv4_address}"; prefixLength = 16; } ];
      };
    };

    services.tinc.networks."9net"= {
      name = "${config.nine_net.node_name}";
      debugLevel = 0;
      chroot = false;
      interfaceType = "tap";
      settings = {
        mode = "Switch";
      };
    };

    # https://github.com/NixOS/nixpkgs/issues/30904
    systemd.services.systemd-networkd-wait-online.serviceConfig.ExecStart = [
      "" # clear old command
      "${config.systemd.package}/lib/systemd/systemd-networkd-wait-online --any --ignore 9net-bridge"
    ];

    environment.systemPackages = [ pkgs.tinc_pre pkgs.bridge-utils ];
    
    environment.etc = {
    "tinc/9net/tinc-up".source = pkgs.writeScript "tinc-up" ''
        #!${pkgs.stdenv.shell}
        ${pkgs.iproute2}/bin/ip link set dev $INTERFACE master 9net-bridge
        ${pkgs.iproute2}/bin/ip link set $INTERFACE up
        ${pkgs.iproute2}/bin/ip link set 9net-bridge up
    '';
    "tinc/9net/tinc-down".source = pkgs.writeScript "tinc-down" ''
        #!${pkgs.stdenv.shell}
  	    /run/wrappers/bin/sudo ${pkgs.iproute2}/bin/ip link set dev $INTERFACE nomaster
      '';
  };

  # from https://nixos.wiki/wiki/Tinc, i dislike this a lot
   security.sudo.extraRules = [
    {
      users    = [ "tinc.9net" ];
      commands = [
        {
          command  = "${pkgs.iproute2}/bin/ip";
          options  = [ "NOPASSWD" ];
        }
      ];
    }
  ];
  };
}
