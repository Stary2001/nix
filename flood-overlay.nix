{ config, pkgs, ... }: 
{
  nixpkgs.overlays = [ (self: super: {
    flood = ( super.callPackage ./pkgs/flood/default.nix {} ).flood;
  })
  ];
}
