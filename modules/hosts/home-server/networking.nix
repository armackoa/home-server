{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.network = {
    hostName,
    config,
    pkgs,
    ...
  }: let
    commonProxyHeaders = ''
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_set_header X-Forwarded-Host $host;

      # Websocket support
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection $connection_upgrade;
    '';

    domain = "server.ts.net";
  in {
    programs.iftop.enable = true;
    users.users.perihelie.extraGroups = ["networkmanager"];

    boot.initrd.systemd.network.wait-online.enable = false;

    networking = {
      hostName = hostName;

      enableIPv6 = true;
      interfaces.eno1.wakeOnLan.enable = true;
      nftables.enable = true;

      firewall = {
        allowedTCPPorts = [22 80 443];
        allowedUDPPorts = [
          config.services.tailscale.port
          8448
        ];
        trustedInterfaces = ["tailscale0"];
        checkReversePath = "loose";
      };

      networkmanager = {
        enable = true;
        wifi.backend = "iwd";
      };
    };

    services = {
      avahi = {
        enable = true;
        nssmdns4 = true;
        publish = {
          enable = true;
          addresses = true;
          domain = true;
          workstation = true;
        };
      };
      tailscale = {
        enable = true;
        openFirewall = true;
        useRoutingFeatures = "server";
        permitCertUid = "nginx";
      };
      networkd-dispatcher = {
        enable = true;
        rules."50-tailscale-optimizations" = {
          onState = ["routable"];
          script = ''
            ${pkgs.ethtool}/bin/ethtool -K eno1 rx-udp-gro-forwarding on rx-gro-list off
          '';
        };
      };
    };

    systemd = {
      network.wait-online.enable = false;
      services.tailscaled.serviceConfig.Environment = [
        "TS_DEBUG_FIREWALL_MODE=nftables"
      ];

      services.tailscale-cert-renewal = {
        description = "Renew Tailscale TLS certificate";
        after = ["tailscaled.service"];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.tailscale}/bin/tailscale cert periserver.tail0e3fc3.ts.net";
          ExecStartPost = [
            "${pkgs.coreutils}/bin/chown root:nginx /var/lib/tailscale/certs/periserver.tail0e3fc3.ts.net.key"
            "${pkgs.coreutils}/bin/chmod 640 /var/lib/tailscale/certs/periserver.tail0e3fc3.ts.net.key"
          ];
          WorkingDirectory = "/var/lib/tailscale/certs";
        };
      };

      timers.tailscale-cert-renewal = {
        wantedBy = ["timers.target"];
        timerConfig = {
          OnCalendar = "weekly";
          Persistent = true;
        };
      };

      services.tailscaled.serviceConfig.StateDirectoryMode = "0711";
      tmpfiles.rules = [
        "d /var/lib/tailscale 0755 root root -"
        "d /var/lib/tailscale/certs 0755 nginx nginx -"
      ];
    };

    environment.systemPackages = [pkgs.nginx];

    systemd.services.nginx.serviceConfig.ReadOnlyPaths = ["/var/lib/tailscale/certs"];

    services.nginx = {
      enable = true;
      recommendedTlsSettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;

      appendHttpConfig = ''
        server_names_hash_bucket_size 128;
        map $http_upgrade $connection_upgrade {
          default upgrade;
          ""      close;
        }
      '';

      virtualHosts."${domain}" = {
        default = true;
        forceSSL = true;
        sslCertificate = "/var/lib/tailscale/certs/server.ts.net.crt";
        sslCertificateKey = "/var/lib/tailscale/certs/server.ts.net.key";

        extraConfig = ''
          ${commonProxyHeaders}

          # Matrix .well-known delegation
          location = /.well-known/matrix/server {
            default_type application/json;
            add_header Access-Control-Allow-Origin *;
            return 200 '{"m.server": "${domain}:443"}';
          }

          location = /.well-known/matrix/client {
            default_type application/json;
            add_header Access-Control-Allow-Origin *;
            return 200 '{"m.homeserver": {"base_url": "https://${domain}"}, "m.identity_server": {}}';
          }
        '';
      };

      virtualisation.oci-containers.containers = {
        gluetun = {
          image = "qmcgaw/gluetun:latest";
          environment = {
            VPN_SERVICE_PROVIDER = "protonvpn";
            VPN_TYPE = "wireguard";
            DNS_ADDRESS = "1.1.1.1";
            SERVER_COUNTRIES = "Netherlands";
            FIREWALL_OUTBOUND_SUBNETS = "192.168.0.0/16,100.64.0.0/10";
            VPN_PORT_FORWARDING = "on";
            VPN_PORT_FORWARDING_PROVIDER = "protonvpn";
            TZ = "Europe/Paris";
          };
          environmentFiles = [config.sops.templates."gluetun.env".path];
          ports = [
            "127.0.0.1:8084:8084"
            "127.0.0.1:5030:5030"
          ];
          extraOptions = [
            "--cap-add=NET_ADMIN"
            "--device=/dev/net/tun"
            "--dns=1.1.1.1"
          ];
          autoStart = true;
        };

        gluetun-jp = {
          image = "qmcgaw/gluetun:latest";
          environment = {
            VPN_SERVICE_PROVIDER = "protonvpn";
            VPN_TYPE = "wireguard";
            SERVER_COUNTRIES = "Japan";
            DNS_ADDRESS = "1.1.1.1";
            TZ = "Asia/Tokyo";
            HTTPPROXY = "on";
            HTTPPROXY_LISTEN_ADDRESS = ":8888";
          };
          ports = [
            "127.0.0.1:8888:8888"
          ];
          environmentFiles = [config.sops.templates."gluetun.env".path];
          extraOptions = [
            "--cap-add=NET_ADMIN"
            "--device=/dev/net/tun"
          ];
        };
      };
    };
  };
}
