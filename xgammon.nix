# NixOS module — the easy way to install xgammon without flakes.
#
# 1. Copy these files into /etc/nixos/:
#      xgammon.nix
#      package.nix
#      xgammon-x86_64.AppImage
#      xgammon.png
# 2. Add the module to your imports in /etc/nixos/configuration.nix:
#      imports = [ ./xgammon.nix ];
# 3. Rebuild:
#      sudo nixos-rebuild switch
{ pkgs, ... }:
{
  environment.systemPackages = [
    (import ./package.nix { inherit pkgs; })
  ];
}
