{
  self,
  inputs,
  ...
}: {
  flake.lib = {
    mkHost = {
      hostName,
      hostModule,
      system ? "x86_64-linux",
      useStable ? false,
    }: let
      pkgsChan =
        if useStable
        then inputs.nixpkgs-stable
        else inputs.nixpkgs;
    in
      pkgsChan.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit self inputs hostName;
          pkgs-unstable = import inputs.nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
        };
        modules = [
          inputs.home-manager.nixosModules.home-manager
          self.nixosModules.common
          hostModule
        ];
      };

    mkDarwinHost = {
      hostName,
      hostModule,
      system ? "aarch64-darwin",
    }:
      inputs.nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = {inherit self inputs hostName;};
        modules = [
          inputs.home-manager.darwinModules.home-manager
          inputs.nix-homebrew.darwinModules.nix-homebrew
          self.darwinModules.common
          hostModule
        ];
      };

    primaryUser = config: lib: let
      normalUsers = lib.filterAttrs (n: v: v.isNormalUser) config.users.users;
    in
      if normalUsers != {}
      then builtins.head (builtins.attrNames normalUsers)
      else "root";
  };
}
