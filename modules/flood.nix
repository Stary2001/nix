{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.flood;
in {
  options = {
    services.flood = {
      enable = mkEnableOption "flood";

      hostName = mkOption {
        type = types.str;
        description = "FQDN for the Flood instance.";
      };

      port = mkOption {
        type = types.port;
        description = "Port to bind Flood to.";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.flood;
        defaultText = literalExpression "pkgs.flood";
        description = ''
          The Flood package to use.
        '';
      };

      user = mkOption {
        type = types.str;
        default = "flood";
        description = ''
          User which runs the flood service.
        '';
      };

      group = mkOption {
        type = types.str;
        default = "flood";
        description = ''
          Group which runs the flood service.
        '';
      };

      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/flood";
        description = "Storage path of flood.";
      };

      rpcSocket = mkOption {
        type = types.str;
        default = config.services.rtorrent.rpcSocket;
        defaultText = "config.services.rtorrent.rpcSocket";
        description = ''
          Path to rtorrent rpc socket.
        '';
      };

      nginx = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Whether to enable nginx virtual host management.
            Further nginx configuration can be done by adapting <literal>services.nginx.virtualHosts.&lt;name&gt;</literal>.
            See <xref linkend="opt-services.nginx.virtualHosts"/> for further information.
          '';
        };
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      systemd = {
        services.flood = {
          description = "Flood system service";
          after = [ "network.target" ];
          path = [ cfg.package ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            User = cfg.user;
            Group = cfg.group;
            Type = "simple";
            Restart = "on-failure";
            WorkingDirectory = cfg.dataDir;
            ExecStart="${cfg.package}/bin/flood";
            RuntimeDirectory = "flood";
            RuntimeDirectoryMode = 755;
          };
        };
        tmpfiles.rules = [ "d '${cfg.dataDir}' 0775 ${cfg.user} ${cfg.group} -" ];
      };

      users.groups."${cfg.group}" = {};

      users.users = {
        "${cfg.user}" = {
          home = cfg.dataDir;
          group = cfg.group;
          extraGroups = [ config.services.flood.group ];
          description = "Flood Daemon user";
          isSystemUser = true;
        };
      };
    }

    (mkIf cfg.nginx.enable {
      services = {
          nginx = {
            enable = true;
            virtualHosts = {
              ${cfg.hostName} = {
                locations = {
                  "/" = {
                    extraConfig = ''
                      proxy_pass 'http://localhost:${cfg.port}';
                    '';
                  };
                };
              };
            };
          };
        };
      })
    ]);
}
