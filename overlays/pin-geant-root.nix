(self: super: {
  pinned-geant4 = ( super.callPackage ../pkgs/geant4/default.nix { qtbase = super.qtbase; wrapQtAppsHook = super.wrapQtAppsHook; } );
  pinned-root =  ( super.callPackage ../pkgs/root/default.nix { Cocoa = null; CoreSymbolication = null; OpenGL = null; } );
})