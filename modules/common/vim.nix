{
  self,
  inputs,
  ...
}: let
  commonVim = {
    pkgs,
    lib,
    ...
  }: let
    vimConfigDir = ./vim/.;
  in {
    environment.systemPackages = with pkgs; [vim-full fzf];

    environment.etc = {
      "xdg/vim/vimrc".source = "${vimConfigDir}/vimrc";
      "xdg/vim/options.vim".source = "${vimConfigDir}/options.vim";
      "xdg/vim/keybinds.vim".source = "${vimConfigDir}/keybinds.vim";
      "xdg/vim/plugins.vim".source = "${vimConfigDir}/plugins.vim";
      "xdg/vim/colors.vim".source = "${vimConfigDir}/colors.vim";
      "xdg/vim/fzf.vim".source = "${vimConfigDir}/fzf.vim";
      "xdg/vim/lsp.vim".source = "${vimConfigDir}/lsp.vim";
    };

    environment.variables = {
      EDITOR = "vim";
      VISUAL = "vim";
    };
  };

  vimActivationNixos = {...}: {
    system.userActivationScripts.vimConfig = ''
      mkdir -p "$HOME/.vim" "$HOME/.vim/plugged"
      ln -sf /etc/xdg/vim/vimrc "$HOME/.vimrc"
      ln -sf /etc/xdg/vim/options.vim "$HOME/.vim/options.vim"
      ln -sf /etc/xdg/vim/keybinds.vim "$HOME/.vim/keybinds.vim"
      ln -sf /etc/xdg/vim/plugins.vim "$HOME/.vim/plugins.vim"
      ln -sf /etc/xdg/vim/colors.vim "$HOME/.vim/colors.vim"
      ln -sf /etc/xdg/vim/fzf.vim "$HOME/.vim/fzf.vim"
      ln -sf /etc/xdg/vim/lsp.vim "$HOME/.vim/lsp.vim"
    '';
  };
in {
  flake.darwinModules.commonVim = commonVim;

  flake.nixosModules.commonVim = {imports = [commonVim vimActivationNixos];};
}
