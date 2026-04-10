{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.serverConfiguration = {
    pkgs,
    lib,
    hostName,
    ...
  }: {
    imports = [
      self.nixosModules.userOneConfiguration
      # self.nixosModules.userTwoConfiguration
      self.nixosModules.serverHardware
      self.nixosModules.sops
      self.nixosModules.storage
      self.nixosModules.network
      self.nixosModules.beets
      self.nixosModules.mediaServers
      self.nixosModules.rss
      self.nixosModules.matrix
      self.nixosModules.homepage
      # TODO: self.nixosModules.icloud | after server hardware upgrade
    ];

    sops.defaultSopsFile = ./server_secrets.yaml;
    nixpkgs.config.allowUnfree = true;
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    boot.loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      grub = {
        enable = true;
        devices = ["nodev"];
        efiSupport = true;
        useOSProber = false;
      };
      systemd-boot.enable = false;
    };

    services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";
    services.upower = {
      enable = true;
      ignoreLid = true;
    };

    environment.sessionVariables = {
      NH_FLAKE = lib.mkDefault "/opt/dotfiles";
    };

    programs.nh = {
      enable = true;
      flake = lib.mkDefault "/opt/dotfiles";
    };

    programs.git = {
      enable = true;
      config = [
        {user.name = "A Macquet Koagné";}
        {user.email = "archibaldmak@gmail.com";}
      ];
    };

    services.xserver = {
      enable = true;
      displayManager.startx.enable = true;
      xkb = {
        layout = "fr";
        variant = "";
      };
    };

    console.keyMap = "fr";

    services.fail2ban = {
      enable = true;
      maxretry = 5;
    };

    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = true;
      };
    };

    services.thermald.enable = true;
    powerManagement.powertop.enable = true;

    environment.systemPackages = with pkgs; [
      htop
      ncdu
      home-manager
      mprocs
    ];

    virtualisation.oci-containers.backend = "docker";
    virtualisation.docker = {
      enable = true;
      storageDriver = "btrfs";
    };

    system.stateVersion = "25.11";
  };
}
