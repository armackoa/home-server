{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.inputMethods = {
    pkgs,
    lib,
    config,
    ...
  }: {
    # imports = [self.nixosModules.qwertyFR];

    options.inputMethod = {
      type = lib.mkOption {
        type = lib.types.enum ["ibus" "fcitx5"];
        default = "ibus";
        description = "Which input method framework to use";
      };

      useMozcUT = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Use Mozc-UT instead of vanilla Mozc";
      };
    };

    config = let
      imType = config.inputMethod.type;
      useMozcUT = config.inputMethod.useMozcUT;
      isIbus = imType == "ibus";
      isFcitx5 = imType == "fcitx5";
    in {
      environment.systemPackages = with pkgs; [
        mecab
        mozcdic-ut-neologd
        python313Packages.mecab-python3
      ];

      i18n.inputMethod = {
        enable = true;
        type = imType;

        # ibus configuration
        ibus.engines = lib.mkIf isIbus (with pkgs.ibus-engines; [
          (
            if useMozcUT
            then mozc-ut
            else mozc
          )
          m17n # Multi-lingual support
        ]);

        # fcitx5 configuration
        fcitx5.addons = lib.mkIf isFcitx5 (with pkgs; [
          (
            if useMozcUT
            then fcitx5-mozc-ut
            else fcitx5-mozc
          )
          fcitx5-gtk
          qt6Packages.fcitx5-configtool
        ]);

        fcitx5.waylandFrontend = isFcitx5;
      };

      environment.sessionVariables = lib.mkMerge [
        (lib.mkIf isIbus {
          GTK_IM_MODULE = "ibus";
          QT_IM_MODULE = "ibus";
          XMODIFIERS = "@im=ibus";
          IBUS_USE_SYSTEM_KEYBOARD_LAYOUT = "1";
        })
        (lib.mkIf isFcitx5 {
          # GTK_IM_MODULE = "fcitx";
          QT_IM_MODULE = "fcitx";
          XMODIFIERS = "@im=fcitx";
        })
      ];
    };
  };
  flake.nixosModules.qwertyFR = {pkgs, ...}: {
    environment.systemPackages = [pkgs.qwerty-fr];
    environment.sessionVariables.XKB_DEFAULT_LAYOUT = "qwerty-fr";

    services.xserver.xkb = {
      extraLayouts.qwerty-fr = {
        description = "QWERTY-FR layout";
        languages = ["fr"];
        # symbolsFile = ./symbols/us_qwerty-fr;
      };

      layout = "qwerty-fr";
      variant = "";
    };

    systemd.services.display-manager = {
      environment = {
        XKB_DEFAULT_LAYOUT = "qwerty-fr";
      };
    };
  };
}
