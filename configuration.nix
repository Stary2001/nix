# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.permittedInsecurePackages = [
         "electron-11.5.0"
  ];

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "uk";
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.stary = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  environment.systemPackages = with pkgs; [
     wget
     git
     yadm
     killall
     file
     cron
     rxvt_unicode.terminfo
     htop
     tmux
     lsof
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.cron.enable = true;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCr6tEiHEdt6B1BGmzTbE/huBVUMspm85J85Id1+k5mBfmuxvRfgAqgr/ywgFRTClSRt2x4PwgiRMIsAuHNc9WwkeMVVDHHaY+s1Nvy4QbCCZCyPE3+mNj/H2ImS3WvUDZ+yS5l4Td7Z4+KuadUD7IGMBGCsnTBZJZUutZTY9vZnurqQICi+rmRBLTB+qHXUeP1fMACySaF5bYxg+y7cWBnNMuKXh7UzZM+GJaqJSA+YXYb1ErDiwCa3ytUZH5F8Q6GQXag6+HA2y/7rwtvgS/rTF6coAAle2NUc4KL4ZT2ZqD4iM/eeQVz1AK51fqlz5kG318+5t7GDaUAIDQmvwOfoQCXHxZqWGSHPjpJp6p17syhR4/IItbaLk83togtQfSKMjVSPZnDVyc+NTv71pFG4HTiFY/gs9GY1DU8H5W3aDet8xX8UujbmSVllgDGX8H0RU63rZbxC/dsXSu5BBfzDsjsBbwJu6XMq5+WITT0sGADzbd7I0kRnf17yGQzWys= stary@wheatley"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJjUz1FruDlg5VNmvd4wi7DiXbMJcN4ujr8KtQ6OhlSc stary@pc"
  ];

  users.users.stary.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCr6tEiHEdt6B1BGmzTbE/huBVUMspm85J85Id1+k5mBfmuxvRfgAqgr/ywgFRTClSRt2x4PwgiRMIsAuHNc9WwkeMVVDHHaY+s1Nvy4QbCCZCyPE3+mNj/H2ImS3WvUDZ+yS5l4Td7Z4+KuadUD7IGMBGCsnTBZJZUutZTY9vZnurqQICi+rmRBLTB+qHXUeP1fMACySaF5bYxg+y7cWBnNMuKXh7UzZM+GJaqJSA+YXYb1ErDiwCa3ytUZH5F8Q6GQXag6+HA2y/7rwtvgS/rTF6coAAle2NUc4KL4ZT2ZqD4iM/eeQVz1AK51fqlz5kG318+5t7GDaUAIDQmvwOfoQCXHxZqWGSHPjpJp6p17syhR4/IItbaLk83togtQfSKMjVSPZnDVyc+NTv71pFG4HTiFY/gs9GY1DU8H5W3aDet8xX8UujbmSVllgDGX8H0RU63rZbxC/dsXSu5BBfzDsjsBbwJu6XMq5+WITT0sGADzbd7I0kRnf17yGQzWys= stary@wheatley"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJjUz1FruDlg5VNmvd4wi7DiXbMJcN4ujr8KtQ6OhlSc stary@pc"
  ];
}

