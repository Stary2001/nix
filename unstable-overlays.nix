let unstable = import <nixos-unstable> {
  config = config.nixpkgs.config;
}; in 
  (self: super: {
    libvirt = unstable.libvirt;
    virt-manager = unstable.virt-manager;
    qemu = unstable.qemu;
    kicad = unstable.kicad;
  })