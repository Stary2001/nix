{ config, pkgs, ... }:
{
  nixpkgs.overlays = [ (self: super: {
    polybar = super.polybar.override {
      pulseSupport = true;
      i3Support = true;
    };
  })

  (self: super: {
    todoist-electron = super.todoist-electron.override {
      electron = super.electron_15;
    };
  })

  ];
}
