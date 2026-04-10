{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.containerMachines = {...}: {
    imports = [
      self.nixosModules.containers
      self.nixosModules.virtualMachines
    ];

    security.polkit.enable = true;
  };

  flake.nixosModules.containers = {
    pkgs,
    lib,
    config,
    ...
  }: let
    username = config.my.primaryUser;
  in {
    environment.systemPackages = with pkgs; [
      distrobox
    ];

    virtualisation = {
      docker.enable = true;
      oci-containers.backend = "docker";
    };

    environment.etc."distrobox/distrobox.conf".text = ''
      container_manager="docker"
      container_additional_volumes="/nix/store:/nix/store:ro /etc/profiles/per-user:/etc/profiles/per-user:ro /etc/static/profiles/per-user:/etc/static/profiles/per-user:ro"
    '';
    users.users."${username}".extraGroups = ["docker"];
  };
  flake.nixosModules.virtualMachines = {
    pkgs,
    lib,
    config,
    ...
  }: let
    username = config.my.primaryUser;
  in {
    environment.systemPackages = with pkgs; [
      looking-glass-client
      libguestfs
      swtpm
      virtio-win
      virtiofsd
      scream
    ];

    boot = {
      initrd.kernelModules = [
        "vfio_pci"
        "vfio"
        "vfio_iommu_type1"
      ];
      kernelParams = [
        "amd_iommu=on"
        "iommu=pt"
        "pcie_acs_override=downstream,multifunction"
        "vfio-pci.ids=10de:1f82,10de:10fa"
        "kvm.ignore_msrs=1"
        "kvm.report_ignored_msrs=0"
      ];
    };

    systemd.tmpfiles.rules = [
      "f /dev/shm/looking-glass 0660 ${username} qemu-libvirtd -"
    ];
    systemd.services.libvirtd.environment = {
      PIPEWIRE_RUNTIME_DIR = "/run/user/1000";
      PULSE_SERVER = "unix:/run/user/1000/pulse/native";
      XDG_RUNTIME_DIR = "/run/user/1000";
    };

    programs.virt-manager.enable = true;

    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
        vhostUserPackages = [pkgs.virtiofsd];

        verbatimConfig = ''
          user = "${username}"
          group = "kvm"
        '';
      };
    };

    home-manager.sharedModules = [
      {
        xdg.configFile."looking-glass/client.ini".text = ''
          [app]
          renderer=OpenGL
        '';
      }
    ];
    users.users."${username}".extraGroups = ["libvirtd"];

    systemd.user.services.scream = {
      description = "Scream IVSHMEM audio receiver";
      after = ["pipewire.service"];
      serviceConfig = {
        ExecStart = "${pkgs.scream}/bin/scream -m /dev/shm/scream-ivshmem -o pulse";
        Restart = "on-failure";
      };
    };

    systemd.services.virt-secret-init-encryption.serviceConfig.ExecStart = lib.mkForce [
      ""
      "${pkgs.writeShellScript "virt-secret-init" ''
        umask 0077
        mkdir -p /var/lib/libvirt/secrets
        if [ ! -f /var/lib/libvirt/secrets/secrets-encryption-key ]; then
          ${pkgs.coreutils}/bin/dd if=/dev/random status=none bs=32 count=1 | \
            ${pkgs.systemd}/bin/systemd-creds encrypt --name=secrets-encryption-key - \
            /var/lib/libvirt/secrets/secrets-encryption-key
        fi
      ''}"
    ];

    security.pam.loginLimits = [
      {
        domain = "@kvm";
        type = "hard";
        item = "memlock";
        value = "unlimited";
      }
      {
        domain = "@kvm";
        type = "soft";
        item = "memlock";
        value = "unlimited";
      }
      {
        domain = "@kvm";
        type = "-";
        item = "rtprio";
        value = "99";
      }
      {
        domain = "@kvm";
        type = "-";
        item = "nice";
        value = "-20";
      }
    ];
  };
}
