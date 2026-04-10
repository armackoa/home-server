{
  self,
  inputs,
  ...
}: {
  flake.homeModules.defaultShell = {pkgs, ...}: {
    imports = with self.homeModules; [
      fish
      nushell
      fastfetch
      yazi
      tmux
    ];

    programs.oh-my-posh = {
      enable = true;
      useTheme = "hul10";
    };
  };
  flake.homeModules.yazi = {...}: {
    programs.yazi = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;

      shellWrapperName = "y";

      settings = {
        manager = {
          show_hidden = true;
          sort_by = "mtime";
          sort_dir_first = false;
          sort_reverse = false;
        };
      };
    };
  };
  flake.homeModules.fish = {
    hostName,
    lib,
    pkgs,
    config,
    ...
  }: let
    isLinux = pkgs.stdenv.isLinux;
    dotfilesPath =
      if hostName == "home-server"
      then "/opt/dotfiles"
      else "${config.home.homeDirectory}/dotfiles";
    aliases = import "${self}/modules/common/_aliases.nix" {
      inherit dotfilesPath hostName;
      isDarwin = pkgs.stdenv.isDarwin;
    };
  in {
    home.packages = with pkgs;
      [
        fish
        fishPlugins.tide
        fishPlugins.autopair
        fishPlugins.bass
      ]
      ++ lib.optionals isLinux [
        fishPlugins.fzf-fish
      ];
    programs.fish = {
      enable = true;
      shellAliases = aliases;

      shellInit = lib.mkIf (hostName != "home-server") ''
        fastfetch
      '';
      plugins =
        [
          {
            name = "bang-bang";
            src = pkgs.fishPlugins.bang-bang.src;
          }
        ]
        ++ lib.optionals isLinux [
          {
            name = "fzf-fish";
            src = pkgs.fishPlugins.fzf-fish.src;
          }
        ];

      interactiveShellInit = ''
        set -gx GTK_USE_PORTAL 1
        set fish_greeting
        set fish_handle_reflow 0
        set -e fish_command_not_found_handler

        # Tide configuration logic
        if not test -f ~/.config/fish/tide_configured
            tide configure --auto --style=Lean --prompt_colors='True color' --show_time='24-hour format' --lean_prompt_height='Two lines' --prompt_connection=Disconnected --prompt_spacing=Compact --icons='Many icons' --transient=No
            touch ~/.config/fish/tide_configured
        end

        # Zoxide (Note: ensure zoxide is in your home.packages or enabled via programs.zoxide)
        if command -v zoxide >/dev/null
          zoxide init fish | source
        end
      '';
    };
    programs.kitty.enableFishIntegration = true;
  };

  flake.homeModules.nushell = {
    hostName,
    config,
    pkgs,
    ...
  }: {
    home.packages = with pkgs; [
      carapace
    ];

    programs.nushell = {
      enable = true;

      # Shell aliases

      extraConfig = ''
        fastfetch

        # Core environment settings
        $env.config = {
          show_banner: false
          completions: {
            algorithm: "fuzzy"
            case_sensitive: false
            quick: true
            partial: true
          }
        edit_mode: "vi"
        }
      '';
    };
    programs.eza.enableNushellIntegration = true;
    programs.carapace.enableNushellIntegration = true;
  };

  flake.homeModules.fastfetch = {config, ...}: {
    home.file."${config.home.homeDirectory}/.config/fastfetch/logos/cirno.png".source = ./images/cirno.png;
    programs.fastfetch = {
      enable = true;
      settings = {
        logo = {
          source = "${config.home.homeDirectory}/.config/fastfetch/logos/cirno.png";
          type = "kitty-direct";
          height = 20;
          width = 40;

          padding = {right = 2;};
        };

        modules = [
          "title"
          "separator"
          "shell"
          "uptime"
          "packages"
          "kernel"
          "os"
          "cpu"
          "gpu"
          "display"
          "memory"
          "swap"
          "disk"
        ];
      };
    };
  };

  flake.homeModules.tmux = {...}: {
    programs.tmux = {
      # ======================================================== #
      # config from: https://www.youtube.com/watch?v=XivdyrFCV4M #
      # ======================================================== #
      enable = true;

      prefix = "C-a";

      mouse = true;

      baseIndex = 1;

      historyLimit = 10000;

      terminal = "tmux-256color";

      extraConfig = ''
        set -sa terminal-features ",foot*:sixel"
        set -ga terminal-overrides ",*:RGB"
        set -g set-clipboard on
        set-option -g renumber-windows on

        # Split windows
        unbind %
        unbind '"'
        bind | split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"
        bind v split-window -h -c "#{pane_current_path}"
        bind c split-window -v -c "#{pane_current_path}"

        # Vim pane navigation
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R

        # Move without C-a (alt + hjkl)
        bind -n M-h select-pane -L
        bind -n M-j select-pane -D
        bind -n M-k select-pane -U
        bind -n M-l select-pane -R

        # Shift + arrows to shift windows
        bind -n S-Left previous-window
        bind -n S-Right next-window

        # Alt + numbers to select windows
        bind -n M-1 select-window -t 1
        bind -n M-2 select-window -t 2
        bind -n M-3 select-window -t 3
        bind -n M-4 select-window -t 4
        bind -n M-5 select-window -t 5
        bind -n M-6 select-window -t 6
        bind -n M-7 select-window -t 7
        bind -n M-8 select-window -t 8
        bind -n M-9 select-window -t 9

        # Vim style copying
        set-window-option -g mode-keys vi
        bind-key -T copy-mode-vi v send -X begin-selection
        bind-key -T copy-mode-vi C-v send -X rectangle-toggle
        bind-key -T copy-mode-vi y send -X copy-selection-and-cancel
        unbind -T copy-mode-vi MouseDragEnd1Pane
      '';
    };
  };
}
