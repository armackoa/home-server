{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.matrix = {config, ...}: let
    domain = "server.ts.net";
    commonProxyHeaders = ''
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_set_header X-Forwarded-Host $host;
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection $connection_upgrade;
    '';
  in {
    services = {
      matrix-synapse = {
        enable = true;
        settings = {
          server_name = domain;
          public_baseurl = "https://${domain}";
          account_threepid_delegates = {};
          experimental_features = {
            msc3266_enabled = true;
          };

          listeners = [
            {
              port = 8008;
              bind_addresses = ["127.0.0.1"];
              tls = false;
              type = "http";
              x_forwarded = true;
              resources = [
                {
                  names = ["client" "federation"];
                  compress = true;
                }
              ];
            }
          ];

          database = {
            name = "psycopg2";
            allow_unsafe_locale = true;
            args = {
              user = "matrix-synapse";
              database = "matrix-synapse";
              host = "/run/postgresql";
            };
          };

          max_upload_size = "100M";
          url_preview_enabled = true;
          enable_registration = false;
          enable_metrics = false;
          registration_shared_secret_path = "/var/lib/matrix-synapse/registration_secret";

          trusted_key_servers = [
            {
              server_name = "matrix.org";
            }
          ];
        };
      };

      postgresql = {
        enable = true;
        ensureDatabases = ["matrix-synapse"];
        ensureUsers = [
          {
            name = "matrix-synapse";
            ensureDBOwnership = true;
          }
        ];
      };
    };

    services.logrotate.settings.matrix-synapse = {
      frequency = "weekly";
      rotate = 4;
    };

    services.postgresqlBackup = {
      enable = true;
      databases = ["matrix-synapse"];
      location = "/srv/storage/backups/postgresql";
    };

    services.nginx.virtualHosts."${domain}".locations = {
      "/_matrix/" = {
        proxyPass = "http://127.0.0.1:8008";
        extraConfig =
          commonProxyHeaders
          + ''
            client_max_body_size 100M;
          '';
      };

      "/_synapse/" = {
        proxyPass = "http://127.0.0.1:8008";
        extraConfig =
          commonProxyHeaders
          + ''
            client_max_body_size 100M;
          '';
      };
    };
  };
}
