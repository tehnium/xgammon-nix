# Contributing

Thanks for your interest in improving xgammon for NixOS!

## What lives here

- `package.nix` — the Nix package. It wraps the bundled `xgammon-x86_64.AppImage`
  with `appimageTools.wrapType2` and adds a desktop entry + icon.
- `xgammon.nix` — the NixOS module (import it from `configuration.nix`).
- `flake.nix` — exposes `packages`, `apps`, `nixosModules` and `overlays`.
- `xgammon_fix.c` — the Wayland `LD_PRELOAD` shim (MIT).
- `xgammon-x86_64.AppImage` — the self-contained game. **Must stay committed**
  (flakes only see Git-tracked files).

The original game is ancient and unmaintained upstream, so most changes here are
about packaging, portability and the Wayland fix — not gameplay.

## Testing your changes

```bash
nix build .#default        # build with the flake
./result/bin/xgammon       # run it (needs a display)
nix flake check            # run the flake checks
```

Every push and pull request is built by GitHub Actions
(`.github/workflows/build.yml`).

## Rebuilding the AppImage

If you change `xgammon_fix.c` or want to regenerate the AppImage from the
original Debian package, use the helper script. See
[`scripts/build-appimage.sh`](scripts/build-appimage.sh) and the "Rebuilding the
AppImage from scratch" section of the README.

After rebuilding, **update the SHA-256 and size in the README** (there is a
"Verify the AppImage" section) and add a `CHANGELOG.md` entry.

## Style

- Nix code follows [nixfmt](https://github.com/NixOS/nixfmt) (see `.editorconfig`).
- Keep the README accurate: if you change behaviour, update it in the same PR.

## License

By contributing you agree that your changes are released under the project's
licenses: GPL-2.0-or-later for the game packaging, MIT for `xgammon_fix.c`.
