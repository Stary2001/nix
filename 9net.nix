{ config, pkgs, ... } : 
{
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
}