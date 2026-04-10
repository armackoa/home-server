{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.userOneConfiguration = {
    pkgs,
    config,
    hostName,
    ...
  }: {
    imports = [
      inputs.home-manager.nixosModules.home-manager
      self.nixosModules.locales
      self.nixosModules.fonts
    ];

    environment.systemPackages = [pkgs.home-manager];

    users.users.userOne = {
      isNormalUser = true;
      shell = pkgs.fish;
      ignoreShellProgramCheck = true;

      extraGroups = [
        "networkmanager"
        "wheel"
        "video"
        "input"
        "users"
      ];
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = {
        inherit inputs hostName;
        pkgs-stable = import inputs.nixpkgs-stable {
          system = pkgs.stdenv.hostPlatform.system;
          config.allowUnFree = true;
        };
      };

      backupFileExtension = "backup";

      users.userOne = {
        imports = [
          self.homeModules.userOneHome
        ];
      };
    };
  };

  flake.homeModules.userOneHome = {
    config,
    pkgs,
    ...
  }: {
    home.username = "user1";
    home.homeDirectory = "/home/${config.home.username}";
    home.stateVersion = "24.05";
    programs.home-manager.enable = true;

    imports = [
      inputs.zen-browser.homeModules.beta
      self.homeModules.sops
      self.homeModules.defaultShell
      self.homeModules.cliTextEditors
      self.homeModules.fonts
    ];

    sops.defaultSopsFile = ./user1_secrets.yaml;

    programs.git = {
      enable = true;
      settings.user = {
        name = "A Macquet Koagné";
        email = "archibaldmak@gmail.com";
      };
    };

    programs.zen-browser = {
      enable = true;
      extraPrefs = ''
        user_pref("widget.use-xdg-desktop-portal.file-picker", 2);
      '';
    };
  };
}
