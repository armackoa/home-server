{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.storage = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      smartmontools
      hdparm
      parted
      ntfs3g
      acl
    ];

    boot.supportedFilesystems = ["btrfs"];

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/13883aa2-cf83-43bf-939a-d15bcd0cfe68";
      fsType = "btrfs";
      options = ["subvol=@" "compress=zstd:3" "noatime" "space_cache=v2"];
    };

    fileSystems."/home" = {
      device = "/dev/disk/by-uuid/13883aa2-cf83-43bf-939a-d15bcd0cfe68";
      fsType = "btrfs";
      options = ["subvol=@home" "compress=zstd:3" "noatime" "space_cache=v2"];
    };

    fileSystems."/nix" = {
      device = "/dev/disk/by-uuid/13883aa2-cf83-43bf-939a-d15bcd0cfe68";
      fsType = "btrfs";
      options = ["subvol=@nix" "noatime" "compress=zstd"];
    };

    fileSystems."/srv" = {
      device = "/dev/disk/by-uuid/13883aa2-cf83-43bf-939a-d15bcd0cfe68";
      fsType = "btrfs";
      options = ["subvol=@srv" "compress=zstd:3" "noatime" "space_cache=v2"];
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/C725-F8C0";
      fsType = "vfat";
      options = ["fmask=0022" "dmask=0022"];
    };

    swapDevices = [
      {device = "/dev/disk/by-uuid/8d676b0c-3001-4ba5-81d9-13effc8d3ed4";}
    ];

    fileSystems."/srv/media" = {
      device = "/dev/disk/by-uuid/13883aa2-cf83-43bf-939a-d15bcd0cfe68";
      fsType = "btrfs";
      options = [
        "subvol=@media"
        "compress=zstd:3"
        "noatime"
        "space_cache=v2"
      ];
    };

    fileSystems."/srv/storage" = {
      device = "/dev/disk/by-uuid/13883aa2-cf83-43bf-939a-d15bcd0cfe68";
      fsType = "btrfs";
      options = [
        "subvol=@storage"
        "compress=zstd:3"
        "noatime"
        "space_cache=v2"
      ];
    };

    services.btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
      fileSystems = ["/srv/media"];
    };

    services.snapper = {
      snapshotInterval = "hourly";
      cleanupInterval = "1d";
      configs = {
        media = {
          SUBVOLUME = "/srv/media";
          ALLOW_USERS = ["user1" "user2"];
          TIMELINE_CREATE = true;
          TIMELINE_CLEANUP = true;
          TIMELINE_LIMIT_HOURLY = 12;
          TIMELINE_LIMIT_DAILY = 7;
          TIMELINE_LIMIT_WEEKLY = 4;
          TIMELINE_LIMIT_MONTHLY = 6;
        };
        storage = {
          SUBVOLUME = "/srv/storage";
          ALLOW_USERS = ["user1" "user2"];
          TIMELINE_CREATE = true;
          TIMELINE_CLEANUP = true;
          TIMELINE_LIMIT_HOURLY = 24;
          TIMELINE_LIMIT_DAILY = 7;
          TIMELINE_LIMIT_WEEKLY = 4;
          TIMELINE_LIMIT_MONTHLY = 12;
        };
      };
    };

    # Samba
    users.users.perihelie.extraGroups = ["samba"];
    users.users.miyuyu.extraGroups = ["samba"];

    services.samba = {
      enable = true;
      package = pkgs.samba;
      openFirewall = true;
      settings = {
        global = {
          "workgroup" = "WORKGROUP";
          "server string" = "server";
          "netbios name" = "server";
          "security" = "user";
          "guest account" = "nobody";
          "map to guest" = "Bad User";
          # MacOS compat
          "fruit:aapl" = "yes";
          "fruit:time machine" = "yes";
          "vfs objects" = "catia fruit streams_xattr";
          # Copy settings
          "socket options" = "TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=131072 SO_SNDBUF=131072";
          "read raw" = "yes";
          "write raw" = "yes";
          "min receivefile size" = 16384;
          "use sendfile" = "yes";
          "aio read size" = 16384;
          "aio write size" = 16384;
        };

        "media" = {
          "path" = "/srv/media";
          "force group" = "users";
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "valid users" = "user1 user2";
          "create mask" = "0664";
          "directory mask" = "0775";
        };

        "shared" = {
          "path" = "/srv/storage/shared";
          "force group" = "users";
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "valid users" = "user1 user2";
          "create mask" = "0644";
          "directory mask" = "0755";
        };

        "user1" = {
          "path" = "/srv/storage/user1";
          "valid users" = "user1";
          "force user" = "user1";
          "force group" = "users";
          "public" = "no";
          "writeable" = "yes";
          "create mask" = "0664";
          "directory mask" = "0775";
        };

        "user2" = {
          "path" = "/srv/storage/user2";
          "valid users" = "user2";
          "force user" = "user2";
          "force group" = "users";
          "public" = "no";
          "writeable" = "yes";
          "create mask" = "0664";
          "directory mask" = "0775";
        };
      };
    };

    systemd.tmpfiles.rules = [
      "d /srv/storage/shared 0775 root users - -"
      "d /srv/media 0775 root users - -"
      "d /srv/storage/perihelie 0755 user1 users - -"
      "d /srv/storage/miyuyu 0755 user2 users - -"
      "d /srv/media/movies 0775 root users - -"
      "d /srv/media/anime 0775 root users - -"
      "d /srv/media/anime-movies 0775 root users - -"
      "d /srv/media/live-actions 0775 root users - -"
      "d /srv/media/tv 0775 root users - -"
      "d /srv/media/music 0775 root users - -"
      "d /srv/media/seggs 0775 root users - -"
    ];
    systemd.services.fix-media-acls = {
      description = "Fix ACLs for Samba media shares";
      wantedBy = ["multi-user.target"];
      after = ["local-fs.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        ${pkgs.acl}/bin/setfacl -R -m g::rwx /srv/media
        ${pkgs.acl}/bin/setfacl -R -d -m g::rwx /srv/media
        ${pkgs.acl}/bin/setfacl -R -m g::rwx /srv/storage/shared
        ${pkgs.acl}/bin/setfacl -R -d -m g::rwx /srv/storage/shared
      '';
    };
  };
}
