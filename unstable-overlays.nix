{ config, pkgs, ... }:
let unstable = import <nixos-unstable> {
  config = config.nixpkgs.config;
}; in {
  nixpkgs.overlays = [ (self: super: {
    polybar = super.polybar.override {
      pulseSupport = true;
      i3Support = true;
    };
  })

  (self: super: {
    libvirt = unstable.libvirt;
    virt-manager = unstable.virt-manager;
    qemu = unstable.qemu;
  })

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

  (self: super: {
    todoist-electron = super.todoist-electron.override {
      electron = super.electron_15;
    };
  })

  ];
}
