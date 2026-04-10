{
  inputs,
  self,
  ...
}: {
  flake.homeModules.fonts = {...}: {
    fonts.fontconfig.enable = true;
  };
  flake.nixosModules.fonts = {pkgs, ...}: {
    fonts.fontDir.enable = true;

    environment.systemPackages = with pkgs; [
      freetype
      wqy_zenhei
      lxgw-wenkai-tc
      zpix-pixel-font
    ];

    fonts.packages = with pkgs; [
      nerd-fonts.iosevka
      nerd-fonts.iosevka-term
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.fira-mono
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      font-awesome
      powerline-fonts
      powerline-symbols
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      nerd-fonts.agave
      liberation_ttf
      fira-code
      fira-code-symbols
      font-awesome
      iosevka

      # Japanese
      hachimarupop
      biz-ud-gothic
      ipafont
      ipaexfont
      ipamjfont
      migmix
      takao
      kochi-substitute
      ricty
      koruri
      migu
      jigmo
    ];
  };
}
