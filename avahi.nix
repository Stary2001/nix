{config, pkgs, ...}:
{
  services.avahi = {
    enable = true;
    publish = {
      enable = true;
      addresses = true;
    };
  };
}
