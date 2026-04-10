{
  self,
  inputs,
  ...
}: let
  commonShared = {
    pkgs,
    lib,
    ...
  }: {
    environment.systemPackages = with pkgs;
      [
        uutils-coreutils-noprefix
        findutils
        ffmpeg-full
        tree
        wget
        ripgrep
        fd
        bat
        eza
        zoxide
        fzf
        file
        dust
        dua
        nh
        nix-tree
        nix-diff
        statix
        deadnix
        rar
        unrar
        unzip
        p7zip
        zip
        xz
      ]
      ++ lib.optionals (!pkgs.stdenv.isDarwin) [
        toybox
        net-tools
        libinput
        wl-clipboard
      ];

    nixpkgs.config.allowBroken = true;
    nixpkgs.config.allowUnfree = true;

    nix.settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["root"];
      auto-optimise-store = false;
      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };
in {
  flake.darwinModules.common = commonShared;

  flake.nixosModules.common = {
    pkgs,
    lib,
    ...
  }: {
    imports = [
      self.nixosModules.commonVim
      self.nixosModules.commonOptions
      commonShared
    ];

    programs.dconf.enable = true;
    programs.direnv.enable = true;

    security.sudo.wheelNeedsPassword = true;
    security.sudo.extraConfig = "Defaults pwfeedback";

    system.autoUpgrade.enable = true;

    services.openssh = {
      enable = true;
      settings.PermitRootLogin = "no";
    };

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 15d";
    };

    nix.optimise.automatic = true;
  };

  flake.nixosModules.commonOptions = {lib, ...}: {
    options.my.primaryUser = lib.mkOption {
      type = lib.types.str;
      default = "root";
    };
  };
}
