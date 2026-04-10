{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.filebrowser = {pkgs, ...}: let
    domain = "periserver.tail0e3fc3.ts.net";
  in {
    environment.systemPackages = with pkgs; [
      unzip
      unrar
      p7zip
    ];

    virtualisation.oci-containers.containers = {
      filebrowser = {
        image = "filebrowser/filebrowser:v2-alpine";
        ports = ["127.0.0.1:8083:80"];
        volumes = [
          "/srv:/srv"
          "/var/lib/filebrowser/database/filebrowser.db:/database/filebrowser.db"
          "/var/lib/filebrowser/config/settings.json:/config/settings.json"
          "${pkgs.unzip}/bin/unzip:/usr/bin/unzip"
          "${pkgs.p7zip}/bin/7z:/usr/bin/7z"
        ];
        environment = {
          PUID = "0";
          PGID = "0";
          FB_BASEURL = "/filebrowser";
        };
        autoStart = true;
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/filebrowser 0750 root root -"
      "d /var/lib/filebrowser/config 0750 root root -"
      "d /var/lib/filebrowser/database 0750 root root -"
    ];

    systemd.services.init-filebrowser-config = {
      description = "Initialize filebrowser configuration files";
      wantedBy = ["docker-filebrowser.service"];
      before = ["docker-filebrowser.service"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        if [ ! -f /var/lib/filebrowser/config/settings.json ]; then
          cat > /var/lib/filebrowser/config/settings.json << 'EOF'
        {
          "port": 80,
          "baseURL": "/filebrowser",
          "address": "",
          "log": "stdout",
          "database": "/database/filebrowser.db",
          "root": "/srv",
          "shell": "sh -c"
        }
        EOF
          echo "Created settings.json"
        fi

        if [ ! -f /var/lib/filebrowser/database/filebrowser.db ]; then
          touch /var/lib/filebrowser/database/filebrowser.db
          echo "Created filebrowser.db"
        fi
      '';
    };

    services.nginx.virtualHosts."${domain}".locations = {
      "/filebrowser/" = {
        proxyPass = "http://127.0.0.1:8083/";
        extraConfig = ''
          client_max_body_size 10G;
          proxy_request_buffering off;
        '';
      };
      "= /filebrowser".return = "301 /filebrowser/";
    };
  };
}
