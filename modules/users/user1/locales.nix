{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.locales = {pkgs, ...}: {
    i18n.defaultLocale = "en_US.UTF-8";
    time.timeZone = "Europe/Paris";

    i18n.glibcLocales = pkgs.glibcLocales.override {
      allLocales = true;
    };

    i18n.extraLocaleSettings = {
      LANGUAGE = "en_US.UTF-8";
      LC_ADDRESS = "fr_FR.UTF-8";
      LC_IDENTIFICATION = "fr_FR.UTF-8";
      LC_MEASUREMENT = "ja_JP.UTF-8";
      LC_MONETARY = "fr_FR.UTF-8";
      LC_NAME = "fr_FR.UTF-8";
      LC_NUMERIC = "ja_JP.UTF-8";
      LC_PAPER = "ja_JP.UTF-8";
      LC_TELEPHONE = "fr_FR.UTF-8";
      LC_TIME = "ja_JP.UTF-8";
    };
  };
}
