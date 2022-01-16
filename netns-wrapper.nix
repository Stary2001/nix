{ config, pkgs, lib, ... }:
  let wrapper = pkgs.writeScriptBin "run_in_vpn.sh" ''
    systemctl start wg # todo: idk make it not do that every time
    ip netns exec wg sudo -u stary "$@"
  '';
  in {
    environment.systemPackages = [ wrapper ];

    security.sudo.extraRules = [
    {
      users    = [ "stary" ];
      commands = [ {
        command  = "${wrapper}/bin/run_in_vpn.sh";
        options  = [ "NOPASSWD" ];
      } ];
    } ];
  }
