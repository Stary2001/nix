( self: super: {
  flashplayer = ( super.callPackage ../pkgs/flashplayer.nix {} );
  aarch64-none-gcc = ( super.callPackage ../pkgs/aarch64-none-gcc.nix {} );
  light_to_influx = ( super.callPackage ../pkgs/light_sensor {} );
})