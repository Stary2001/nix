{config, pkgs, ...}:
{
  systemd.services.libvirtd.preStart = ''
    mkdir -p /var/lib/libvirt/hooks
    chmod 755 /var/lib/libvirt/hooks

    # Copy hook files
    cp -f /etc/libvirt/hooks/qemu /var/lib/libvirt/hooks/qemu

    # Make them executable
    chmod +x /var/lib/libvirt/hooks/qemu
  '';

  environment.etc = {
    "libvirt/hooks/qemu".source = pkgs.writeScript "tinc-up" ''
        #!${pkgs.stdenv.shell}
        if [ "$1" == "win10" ] || [ "$1" == "a" ]; then
          if [ "$2" == "started" ]; then
            echo -n '1' > /dev/serial/by-id/usb-Raspberry_Pi_Pico_E66038B7136D282F-if00
          elif [ "$2" == "release" ]; then
            echo -n '2' > /dev/serial/by-id/usb-Raspberry_Pi_Pico_E66038B7136D282F-if00
          fi
        fi
    '';
  };
}