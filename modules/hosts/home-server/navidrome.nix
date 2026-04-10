{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.mediaServers = {...}: let
    domain = "periserver.tail0e3fc3.ts.net";

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
    imports = with self.nixosModules; [
      navidrome
      hardwareAcceleration
    ];
    services.nginx.virtualHosts."${domain}".locations = {
      "/navidrome" = {
        proxyPass = "http://127.0.0.1:4533";
        extraConfig = commonProxyHeaders;
      };

      "/beets" = {
        proxyPass = "http://127.0.0.1:8337";
        extraConfig =
          commonProxyHeaders
          + ''
            proxy_set_header X-Script-Name /beets;
            proxy_set_header X-Scheme $scheme;
          '';
      };
      "= /navidrome".return = "301 /navidrome/";
      "= /beets".return = "301 /beets/";
    };
  };

  flake.nixosModules.navidrome = {
    config,
    pkgs,
    ...
  }: {
    sops.secrets = {
      lastfm_api_key = {};
      lastfm_api_secret = {};
    };

    sops.templates."navidrome.env" = {
      content = ''
        ND_LASTFM_APIKEY=${config.sops.placeholder.lastfm_api_key}
        ND_LASTFM_SECRET=${config.sops.placeholder.lastfm_api_secret}
      '';
      mode = "0400";
      owner = "navidrome";
    };

    services.navidrome = {
      enable = true;
      openFirewall = false;
      environmentFile = config.sops.templates."navidrome.env".path;

      settings = {
        Address = "127.0.0.1";
        Port = 4533;

        BaseURL = "/navidrome";

        ReverseProxyWhitelist = "127.0.0.1/32";

        MusicFolder = "/srv/media/music";
        ScanSchedule = "@every 1h";

        "LastFM.Enabled" = true;
        "LastFM.Language" = "fr";

        EnableSharing = false;
        EnableUserEditing = true;
        CoverJpegQuality = 90;
        EnableCoverArtAnimation = false;
        TranscodingCacheSize = "1GB";
        AutoImportPlaylists = true;

        CoverArtPriority = "embedded, cover.*, folder.*, front.*";

        "Plugins.Enabled" = true;
        "Plugins.Folder" = "/var/lib/navidrome/plugins";
        "Plugins.AutoReload" = false;
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/navidrome/plugins 0750 navidrome navidrome -"
      "d /srv/media       0755 root     root  -"
      "d /srv/media/music 2775 user1 users -"
      "d /var/lib/beets   0755 user1 users -"
    ];
  };

  flake.nixosModules.hardwareAcceleration = {
    pkgs,
    config,
    ...
  }: {
    services.xserver.videoDrivers = ["nvidia"];
    hardware.graphics.enable = true;
    hardware.graphics.extraPackages = with pkgs; [libva-vdpau-driver libvdpau-va-gl];
    hardware.nvidia = {
      open = false;
      nvidiaPersistenced = false;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      prime = {
        offload.enable = true;
        offload.enableOffloadCmd = true;
        nvidiaBusId = "PCI:1:0:0";
        intelBusId = "PCI:0:2:0";
      };
    };

    systemd.services.jellyfin.environment = {
      LD_LIBRARY_PATH = "${config.hardware.nvidia.package}/lib";
      __NV_PRIME_RENDER_OFFLOAD = "1";
      __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      __VK_LAYER_NV_optimus = "NVIDIA_only";
    };

    nix.settings = {
      substituters = ["https://cache.nixos-cuda.org"];
      trusted-public-keys = ["cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="];
    };
  };
}
