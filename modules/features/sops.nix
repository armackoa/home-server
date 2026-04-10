{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.sops = {
    config,
    pkgs,
    ...
  }: {
    imports = [inputs.sops-nix.nixosModules.sops];
    environment.systemPackages = with pkgs; [sops age ssh-to-age];

    sops = {
      age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    };
  };
  flake.homeModules.sops = {
    config,
    pkgs,
    ...
  }: {
    imports = [inputs.sops-nix.homeModules.sops];

    sops = {
      age.sshKeyPaths = ["${config.home.homeDirectory}/.ssh/id_ed25519"];
    };
  };
}
