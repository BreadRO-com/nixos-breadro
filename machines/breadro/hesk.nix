{
  lib,
  pkgs,
  inputs,
  system,
  config,
  ...
}:
{
  services.phpfpm.pools = {
    hesk = {
      user = config.services.nginx.user;
      group = config.services.nginx.group;
      settings = {
        "listen.owner" = config.services.nginx.user;
        "listen.group" = config.services.nginx.group;
        "pm" = "dynamic";
        "pm.max_children" = 32;
        "pm.start_servers" = 2;
        "pm.min_spare_servers" = 2;
        "pm.max_spare_servers" = 4;
        "pm.max_requests" = 500;
      };
    };
  };

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    ensureDatabases = [ "hesk" ];
    ensureUsers = [
      {
        name = "nginx";
        ensurePermissions = {
          "hesk.*" = "ALL PRIVILEGES";
        };
      }
      { 
        name = "excalibur";
        ensurePermissions = {
          "*.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  systemd.tmpfiles.rules = [
    "d '/var/lib/hesk/attachments' 0750 ${config.services.nginx.user} ${config.services.nginx.group} - -"
    "d '/var/lib/hesk/cache' 0750 ${config.services.nginx.user} ${config.services.nginx.group} - -"
    "C '/var/lib/hesk/hesk_settings.inc.php' - - - - ${inputs.self.packages.${system}.hesk}/share/hesk/hesk_settings.inc.php"
    "Z '/var/lib/hesk/hesk_settings.inc.php' 0640 ${config.services.nginx.user} ${config.services.nginx.group} - -"
  ];

  services.nginx.virtualHosts = let
    ssl = {
      enableACME = true;
      kTLS = true;
    };
    https = host: host // ssl // {
      forceSSL = true;
    };
    http = host: host // ssl // {
      rejectSSL = true;
    };
    http_https = host: host // ssl // {
      addSSL = true;
    }; in {
    "breadro.com" = https { locations = {
      "/".return = "301 https://cs.breadro.com";
    };};
    "www.breadro.com" = https { locations = {
      "/".return = "301 https://cs.breadro.com";
    };};
    "cs.breadro.com" = https {
      extraConfig = ''
        index index.php;
      '';
      root = "${inputs.self.packages.${system}.hesk.override {
        stateDir = "/var/lib/hesk";
        langPack = inputs.self.packages.${system}.hesk-zh_cmn_hans;
        # removeInstall = false;
      }}/share/hesk/";
      locations = {
        "/" = {
          priority = 200;
          extraConfig = ''
            try_files $uri $uri/ /index.php$is_args$args;
          '';
        };
        "~ \\.php$" = {
          priority = 500;
          extraConfig = ''
            fastcgi_pass unix:${config.services.phpfpm.pools.hesk.socket};
            try_files $uri =404;
            fastcgi_index index.php;

            include ${config.services.nginx.package}/conf/fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $request_filename;
            fastcgi_param HTTP_PROXY "";
          '';
        };
        "~* \\.(js|css|png|jpg|jpeg|gif|ico|svg|eot|ttf|woff|woff2)$" = {
          priority = 1000;
          extraConfig = ''
            expires max;
            log_not_found off;
          '';
        };
      };
    };
  };
}