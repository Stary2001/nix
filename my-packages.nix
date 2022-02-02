{ config, pkgs, ... }:
{
  nixpkgs.overlays = [

  (self: super: {
    pinned-geant4 = ( super.callPackage ./pkgs/geant4/default.nix { qtbase = super.qtbase; wrapQtAppsHook = super.wrapQtAppsHook; } );
    pinned-root =  ( super.callPackage ./pkgs/root/default.nix { Cocoa = null; CoreSymbolication = null; OpenGL = null; } );
  })

  ( self: super: {
    flashplayer = ( super.callPackage ./pkgs/flashplayer.nix {} );
  })

  ( self: super: {
    aarch64-none-gcc = ( super.callPackage ./pkgs/aarch64-none-gcc.nix {} );
  })

  ( self: super: {
    light_to_influx = ( super.callPackage ./pkgs/light_sensor {} );
  })

  ];
}
