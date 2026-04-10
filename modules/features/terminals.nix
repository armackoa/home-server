{
  self,
  inputs,
  ...
}: {
  flake.homeModules.alacritty = {pkgs, ...}: {
    programs.alacritty = {
      enable = true;
      settings = {
        window = {
          startup_mode = "Windowed";
          opacity = 0.9;
          dynamic_padding = true;
        };

        font = {
          size = 14;
          normal = {
            family = "Iosevka Nerd Font";
            style = "Regular";
          };
          bold = {
            family = "Iosevka Nerd Font";
            style = "Bold";
          };
          italic = {
            family = "Iosevka Nerd Font";
            style = "Italic";
          };
          bold_italic = {
            family = "Iosevka Nerd Font";
            style = "Bold Italic";
          };
        };
      };
    };
  };

  flake.homeModules.kitty = {...}: {
    programs.kitty = {
      enable = true;
      font = {
        name = "Iosevka Nerd Font Mono";
        size = 14;
      };
      settings = {
        enable_audio_bell = false;
        scrollback_lines = 10000;
        update_check_interval = 0;

        # Window
        background_opacity = 0.9;
      };

      enableGitIntegration = true;

      shellIntegration = {
        enableGitIntegration = true;
        enableBashIntegration = true;
      };

      extraConfig = ''term xterm-kitty'';
    };
  };
  flake.homeModules.foot = {pkgs, ...}: {
    home.packages = with pkgs; [
      viu
      libsixel
      lsix
    ];
    programs.foot = {
      enable = true;
      settings = {
        main = {
          font = "Iosevka Nerd Font Mono:size=14";
          dpi-aware = "no";
        };
        scrollback = {
          lines = 10000;
          multiplier = 3;
        };

        cursor = {
          style = "beam";
          blink = "yes";
        };

        mouse = {
          hide-when-typing = "yes";
        };

        url = {
          launch = "xdg-open \${url}";
          osc8-underline = "always";
        };

        colors-dark = {
          alpha = "0.95";
        };
        security.osc52 = "enabled";
      };
    };
  };
}
