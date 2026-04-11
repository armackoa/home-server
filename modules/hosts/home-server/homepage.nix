{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.homepage = {...}: let
    domain = "server.ts.net";
  in {
    services.nginx.virtualHosts."${domain}" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:8082";
      };
    };
    services.homepage-dashboard = {
      enable = true;
      allowedHosts = "server.ts.net,127.0.0.1:8082,localhost:8082";
      settings = {
        base = "https://server.ts.net/";
      };
      services = [
        {
          "Media" = [
            {
              "Navidrome" = {
                icon = "navidrome.png";
                href = "https://periserver.tail0e3fc3.ts.net/navidrome";
                description = "Beeps and boops management";
              };
            }
          ];
        }
        {
          "RSS feeds" = [
            {
              "FreshRSS" = {
                icon = "freshrss.png";
                href = "https://server.ts.net/freshrss";
                description = "RSS reader";
                widget = {
                  type = "freshrss";
                  url = "https://server.ts.net/freshrss";
                };
              };
            }
            {
              "RSSHub" = {
                icon = "rsshub.png";
                href = "https://periserver.tail0e3fc3.ts.net/rsshub";
                description = "RSS feed generator";
              };
            }
            {
              "Full Text to Rss" = {
                icon = "rsshub.png";
                href = "https://server.ts.net/ft-rss";
                description = "Get full text in RSS";
              };
            }
          ];
        }
        {
          "Storage" = [
            {
              "Files" = {
                icon = "mdi-folder";
                href = "/filebrowser/";
                description = "File browser";
              };
            }
          ];
        }
      ];
    };
  };
}
