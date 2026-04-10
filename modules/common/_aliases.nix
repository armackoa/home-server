{
  dotfilesPath,
  hostName,
  isDarwin,
  ...
}: let
  rebuildCmd =
    if isDarwin
    then "nh darwin switch path:'${dotfilesPath}' -H ${hostName} --ask --diff always"
    else "nh os switch 'path:${dotfilesPath}' -H ${hostName} --ask --diff always";
  rebuild-nixCmd =
    if isDarwin
    then "sudo darwin-rebuild switch --flake  'path:${dotfilesPath}#${hostName}'"
    else "sudo nixos-rebuild switch --flake  'path:${dotfilesPath}#${hostName}'";
in {
  kumit = "bash ${dotfilesPath}/scripts/kumit.sh";
  rebuild = rebuildCmd;
  rebuild-nix = rebuild-nixCmd;
  update-flakes = "cd ${dotfilesPath} && nix flake update && kumit 'update flakes.lock'";
  maj = "cd ${dotfilesPath} && git pull && git submodule update --recursive && nix flake update && rebuild";

  dot = "cd ${dotfilesPath} && tmux";

  g = "git";
  ga = "git add .";
  gc = "git commit -am";
  gco = "git checkout";
  gd = "git diff";
  gl = "git log";
  gp = "git push";
  gpl = "git pull";
  gs = "git status";
  gb = "git branch";

  ls = "eza";
  ll = "eza -la";
  la = "eza -la";
  l = "eza -l";
  ".." = "z ..";
  "..." = "z ../..";
}
