{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.beets = {
    pkgs,
    config,
    lib,
    ...
  }: {
    sops = {
      secrets = {
        musicbrainz_user = {};
        musicbrainz_pass = {};
      };
      templates = {
        "beets-mb.yaml" = {
          content = ''
            musicbrainz:
              user: ${config.sops.placeholder.musicbrainz_user}
              pass: ${config.sops.placeholder.musicbrainz_pass}
              useragent: "beets/2.6.2 ( mailto:archibaldmak@gmail.com )"
          '';
          owner = "armackoa";
          path = "/run/secrets/beets-mb.yaml";
        };
      };
    };

    home-manager.sharedModules = [
      {
        home.packages = with pkgs; [
          ffmpeg
          chromaprint
        ];

        programs.beets = {
          enable = true;

          settings = {
            plugins = [
              "chroma"
              "fetchart"
              "embedart"
              "lastgenre"
              "mbsync"
              "scrub"
              "replaygain"
              "convert"
              "duplicates"
              "missing"
              "badfiles"
              "edit"
              "web"
            ];

            include = ["/run/secrets/beets-mb.yaml"];

            directory = "/srv/media/music";
            library = "/var/lib/beets/musiclibrary.blb";

            art_filename = "albumart";
            threaded = false;
            original_date = false;
            per_disc_numbering = true;

            musicbrainz = {
              searchlimit = 10;
              https = true;
              ratelimit = 1;
              ratelimit_interval = 1.0;
              data_source_mismatch_penalty = 0.0;
              genres = true;
              extra_tags = [];
            };

            match = {
              strong_rec_thresh = 0.04;
              medium_rec_thresh = 0.25;
              max_rec = {
                missing_tracks = "medium";
                unmatched_tracks = "medium";
              };
              distance_weights = {
                tracks = 0.0;
                missing_tracks = 0.0;
                unmatched_tracks = 0.0;
              };
            };

            raise_on_error = false;
            va_name = "Various Artists";

            convert = {
              auto = false;
              format = "mp3";
              formats.mp3 = {
                command = "ffmpeg -i $source -ab 320k -ac 2 -ar 48000 $dest";
                extension = "mp3";
              };
              max_bitrate = 320;
              threads = 4;
            };

            paths = {
              default = "$albumartist/$album%aunique{}/%if{$multidisc,$disc-}$track - $title";
              singleton = "Non-Album/$artist - $title";
              comp = "Compilations/$album%aunique{}/%if{$multidisc,$disc-}$track - $title";
              "albumtype:soundtrack" = "Soundtracks/$album/$track $title";
            };

            import = {
              write = true;
              copy = false;
              move = true;
              resume = "ask";
              incremental = true;
              quiet_fallback = "skip";
              timid = false;
              log = "/var/lib/beets/beet.log";
              va_cutoff = 1.0;
            };

            lastgenre = {
              auto = true;
              source = "album";
            };

            embedart.auto = true;
            fetchart.auto = true;

            replaygain = {
              auto = false;
              backend = "ffmpeg";
            };

            scrub.auto = true;
            badfiles.check_on_import = false;

            replace = {
              "^\\." = "_";
              "[\\x00-\\x1f]" = "_";
              "[<>:\"?\\*\\|]" = "_";
              "\\.$" = "_";
              "\\s+$" = "";
            };

            web = {
              host = "0.0.0.0";
              port = 8337;
              reverse_proxy = true;
            };
          };
        };
      }
    ];
  };
}
