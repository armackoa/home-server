# Home-server NixOS configuration
Home-server configured using [NixOS](https://nixos.org/) on the stable branch (currently 25.11) with [flakes](https://wiki.nixos.org/wiki/Flakes). For modularity, the configuration follows the [dendritic pattern](https://dendrix.oeiuwq.com/Dendritic.html) allowed by [flake-parts](https://github.com/hercules-ci/flake-parts) and [import-tree](https://github.com/vic/import-tree), relying on `nixosModules` and `homeModules` for NixOS system wide configuration and [Home-Manager](https://github.com/nix-community/home-manager) user specific options respectively.

## Services
- **Network**: Tailscale, Gluetun (for ProtonVPN) and nginx reverse proxy
- **Storage**: BTRFS with snapper snapshots, Samba shares, ACL-based multi-user access
- **Secrets**: sops-nix with age keys
- **Self-hosted services**: FreshRSS, RSSHub, Matrix Synapse
