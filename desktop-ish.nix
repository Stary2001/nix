{config, pkgs, ...}:
{
   environment.systemPackages = with pkgs; [
     wget
     google-chrome
     autorandr
     git
     yadm
     rofi
     dex
     picom
     feh
     xbindkeys
     pavucontrol
     rxvt-unicode
     polybar
     killall

     slack
     discord
     hexchat
     todoist-electron
     signal-desktop
    
     python3
     rustup

     file
     carla
     jack2
     libvirt
     virt-manager

     sublime4
     maim
     slop
     xclip
     libreoffice

     # https://github.com/NixOS/nixpkgs/issues/2448
     dconf
     kicad

     rustup
     ddcutil
     cron
     direnv
     vlc

     unzip
     unrar
     p7zip

     rink
  ];
}
