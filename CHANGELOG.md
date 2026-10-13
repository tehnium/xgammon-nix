# Changelog

All notable changes to this project are documented here.

## [0.98-1] — 2026-10-13

Initial release.

- Package the self-contained `xgammon` AppImage for NixOS via
  `appimageTools.wrapType2` (no FUSE required).
- Ship a desktop entry and icon so the game appears under *Games*.
- Support multiple install paths:
  - `nix run github:tehnium/xgammon-nix`
  - NixOS flake (`packages`, `apps`, `nixosModules`, `overlays`)
  - NixOS module for the classic `/etc/nixos` workflow
  - `nix profile install`
  - plain AppImage on any Linux distribution
- Bundle the Wayland compatibility shim (`xgammon_fix.so`, MIT).
