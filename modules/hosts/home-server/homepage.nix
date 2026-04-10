{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.homepage = {...}: let
    domain = "periserver.tail0e3fc3.ts.net";
  in {
    services.nginx.virtualHosts."${domain}" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:8082";
      };
    };
    services.homepage-dashboard = {
      enable = true;
      allowedHosts = "periserver.tail0e3fc3.ts.net,127.0.0.1:8082,localhost:8082";
      settings = {
        base = "https://periserver.tail0e3fc3.ts.net/";
      };
      services = [
        {
          "Media" = [
            {
              "Jellyfin" = {
                icon = "jellyfin.png";
                href = "https://periserver.tail0e3fc3.ts.net/jellyfin";
                description = "Media server";
              };
            }
            {
              "Seerr" = {
                icon = "seerr.png";
                href = "https://periserver.tail0e3fc3.ts.net/seerr";
                description = "Frères Lumières request management";
              };
            }
            {
              "Navidrome" = {
                icon = "navidrome.png";
                href = "https://periserver.tail0e3fc3.ts.net/navidrome";
                description = "Beeps and boops management";
              };
            }
            # {
            #   "Paperless" = {
            #     icon = "paperless.png";
            #     href = "https://periserver.tail0e3fc3.ts.net/paperless";
            #     description = "Not Zotero";
            #   };
            # }
          ];
        }
        {
          "RSS feeds" = [
            {
              "FreshRSS" = {
                icon = "freshrss.png";
                href = "https://periserver.tail0e3fc3.ts.net/freshrss";
                description = "RSS reader";
                widget = {
                  type = "freshrss";
                  url = "https://periserver.tail0e3fc3.ts.net/freshrss";
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
                href = "https://periserver.tail0e3fc3.ts.net/ft-rss";
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
        {
          "Arrrrrrrrrrrrrrrrrrrrrrrrr" = [
            {
              "Prowlarr" = {
                icon = "prowlarr.png";
                href = "/prowlarr/";
                description = "Indexer manager";
              };
            }
            {
              "Sonarr" = {
                icon = "sonarr.png";
                href = "/sonarr/";
                description = "TV show management";
              };
            }
            {
              "Radarr" = {
                icon = "radarr.png";
                href = "/radarr/";
                description = "Movie management";
              };
            }
            {
              "Lidarr" = {
                icon = "lidarr.png";
                href = "/lidarr/";
                description = "Music management";
              };
            }
            {
              "Whisparr" = {
                icon = "Whisparr.png";
                href = "/whisparr/";
                description = "Seggs management";
              };
            }
            {
              "Bazarr" = {
                icon = "bazarr.png";
                href = "/bazarr/";
                description = "Subtitles management";
              };
            }
            {
              "Qbittorrent" = {
                icon = "qbittorrent.png";
                href = "/qbt/";
                description = "Torrent client";
              };
            }
          ];
        }
      ];
    };
  };
}
