{ config, pkgs, ... }: 
{
  disabledModules = [ "services/torrent/rtorrent.nix" ];

  nixpkgs.overlays = [ (self: super: {
    flood = ( super.callPackage ./pkgs/flood/ {} );
  })
  ];
}
