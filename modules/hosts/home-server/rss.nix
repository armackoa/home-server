{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.rss = {
    pkgs,
    config,
    ...
  }: let
    freshrssPool = config.services.phpfpm.pools.freshrss;
    freshrssPackage = pkgs.freshrss;
    domain = "server.ts.net";
  in {
    sops.secrets = {
      freshrss_password = {};
    };

    services.freshrss = {
      enable = true;
      baseUrl = "https://server.ts.net/freshrss";
      defaultUser = "user1";
      passwordFile = config.sops.secrets.freshrss_password.path;
      database.type = "sqlite";
    };

    virtualisation.oci-containers.containers = {
      "full-text-rss" = {
        image = "heussd/fivefilters-full-text-rss:latest";
        ports = ["127.0.0.1:8080:80"];
      };

      "rsshub" = {
        image = "diygod/rsshub:latest";
        extraOptions = ["--network=host"];
        environment = {
          CACHE_TYPE = "memory";
          RSSHUB_BASE_URL = "https://server.ts.net/rsshub";
          PORT = "1200";
          UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36";
        };
      };
    };

    services.nginx.virtualHosts."${domain}".locations = {
      "/ft-rss/".proxyPass = "http://127.0.0.1:8080/";

      "/rsshub/" = {
        proxyPass = "http://127.0.0.1:1200/";
        extraConfig = "rewrite ^/rsshub/(.*) /$1 break;";
      };

      "/freshrss/" = {
        alias = "${freshrssPackage}/p/";
        index = "index.php";
        extraConfig = "try_files $uri $uri/ /freshrss/index.php?$query_string;";
      };

      "~ ^/freshrss/.*\\.php(?:/.*)?$" = {
        extraConfig = ''
          root ${freshrssPackage}/p;
          rewrite ^/freshrss(/.*\.php)(.*)$ $1$2 break;
          fastcgi_split_path_info ^(.+?\.php)(/.*)$;
          fastcgi_param SCRIPT_FILENAME ${freshrssPackage}/p$fastcgi_script_name;
          fastcgi_param DATA_PATH /var/lib/freshrss;
          fastcgi_pass unix:${freshrssPool.socket};
          include ${pkgs.nginx}/conf/fastcgi_params;
        '';
      };

      "= /freshrss".return = "301 /freshrss/";
    };
  };
}
