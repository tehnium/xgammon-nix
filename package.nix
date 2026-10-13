# Package definition for xgammon, built from the bundled self-contained AppImage.
#
# It wraps the AppImage with `appimageTools.wrapType2` (FHS environment +
# extraction, no FUSE needed) and also ships a desktop entry and icon so the
# game shows up in the applications menu.
#
# Usage:
#   nix-build ./package.nix
#   nix-build ./package.nix -o result && ./result/bin/xgammon
{ pkgs ? import <nixpkgs> { } }:
let
  appimage = pkgs.appimageTools.wrapType2 {
    pname = "xgammon";
    version = "0.98";
    src = ./xgammon-x86_64.AppImage;
  };

  desktopItem = pkgs.makeDesktopItem {
    name = "xgammon";
    desktopName = "xgammon";
    exec = "xgammon";
    icon = "xgammon";
    comment = "Backgammon game for X11";
    categories = [ "Game" "BoardGame" ];
  };

  icon = pkgs.runCommand "xgammon-icon" { } ''
    install -Dm644 ${./xgammon.png} \
      $out/share/icons/hicolor/48x48/apps/xgammon.png
  '';
in
pkgs.symlinkJoin {
  name = "xgammon-0.98";
  paths = [
    appimage
    desktopItem
    icon
  ];
  meta = {
    description = "Classic X11 backgammon game (packaged from a self-contained AppImage)";
    homepage = "https://github.com/tehnium/xgammon-nix";
    license = pkgs.lib.licenses.gpl2Plus;
    platforms = [ "x86_64-linux" ];
    mainProgram = "xgammon";
  };
}
