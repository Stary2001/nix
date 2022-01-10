# https://mth.st/blog/nixos-wireguard-netns/

{ config, lib, pkgs, ... }: {
  config.systemd.services.wg-veth = {
    description = "wg veth pair";
    bindsTo = [ "netns@wg.service" ];
    requires = [ "network-online.target" ];
    after = [ "netns@wg.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writers.writeDash "wg-veth-up" ''
	${pkgs.iproute}/bin/ip link add wg_left type veth peer wg_right

        ${pkgs.iproute}/bin/ip link set wg_left up
        ${pkgs.iproute}/bin/ip addr add 10.0.0.1/24 dev wg_left

	${pkgs.iproute}/bin/ip link set dev wg_right netns wg
        ${pkgs.iproute}/bin/ip -n wg link set wg_right up
        ${pkgs.iproute}/bin/ip -n wg addr add 10.0.0.2/24 dev wg_right
      '';

      ExecStop =  pkgs.writers.writeDash "wg-veth-down" ''
        ${pkgs.iproute}/bin/ip link del wg_left
        ${pkgs.iproute}/bin/ip -n wg link del wg_right
      '';
    };
  };
}
