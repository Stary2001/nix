{ config, pkgs, ... }: 
{
  disabledModules = [ "services/torrent/rtorrent.nix" ];
  imports = [ modules/rtorrent.nix modules/rutorrent.nix ];

  nixpkgs.overlays = [ (self: super: {
    rutorrent = ( super.callPackage ./pkgs/rutorrent.nix {} );
  })
  ];
}
