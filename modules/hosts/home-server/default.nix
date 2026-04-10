{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.periserver = self.lib.mkHost {
    hostName = "server";
    hostModule = self.nixosModules.serverConfiguration;
  };
}
