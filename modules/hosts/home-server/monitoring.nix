{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.monitoring = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      lm_sensors
      btop-cuda
      iftop
      nvtopPackages.nvidia
      smartmontools
    ];

    imports = with self.nixosModules; [
      # Will do after server hardware upgrade
      # prometheus
      # grafana
    ];
  };
}
