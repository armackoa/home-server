{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.tailscaleClient = {...}: {
    networking = {
      networkmanager.enable = true;
      firewall = {
        enable = true;
        extraCommands = ''iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns'';
      };
    };

    services.tailscale = {
      enable = true;
      useRoutingFeatures = "client";
      extraUpFlags = [
        "--accept-routes=false"
        "--advertise-exit-node=false"
        "--accept-dns=false"
        "--netfilter-mode=off"
      ];
    };

    systemd.services.tailscaled = {
      after = ["NetworkManager-wait-online.service"];
      wants = ["NetworkManager-wait-online.service"];
    };
  };
}
