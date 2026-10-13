<p align="center">
  <img src="xgammon.png" width="96" alt="xgammon">
</p>

<h1 align="center">xgammon for NixOS</h1>

<p align="center">
  Classic X11 backgammon — packaged for NixOS and other Nix environments.
  <br>
  <a href="https://github.com/tehnium/xgammon-nix/actions/workflows/build.yml">
    <img src="https://github.com/tehnium/xgammon-nix/actions/workflows/build.yml/badge.svg" alt="Build status">
  </a>
</p>

A ready-to-use packaging of **xgammon** — the classic X11 backgammon game — for
**NixOS** (and any other Nix environment).

The upstream game is ancient (last touched in the 1990s) and depends on legacy
X11 libraries that modern distributions no longer ship by default. This
repository solves that by bundling a **self-contained AppImage** and wiring it
into Nix declaratively, including a fix so it runs on **Wayland** too.

---

## What is xgammon?

`xgammon` is a backgammon game for X11 written in the early 1990s by
**Lambert Klasen** and **Detlef Steuer**. It supports single/duo play, a
computer opponent, match play with the Crawford rule, the doubling cube, and the
classic `.xg` save format.

## What's in the AppImage?

The bundled `xgammon-x86_64.AppImage` contains everything the game needs, so it
does not depend on your system libraries:

| Component | Purpose |
| --- | --- |
| `usr/bin/xgammon` | The original game binary (from Debian `xgammon 0.98-13`) |
| `usr/lib/libXaw.so.7` | Athena widgets toolkit |
| `usr/lib/libXt.so.6`, `libXmu.so.6`, `libXpm.so.4`, `libXext.so.6`, `libfl.so.2`, `libbsd.so.0`, `libmd.so.0` | Remaining X11 / helper libraries |
| `usr/lib/xgammon_fix.so` | `LD_PRELOAD` shim that fixes crashes under Wayland (XWayland) |
| `etc/X11/app-defaults/XGammon` | Widget resource file (colors, fonts, geometry) |

### The Wayland fix

Under XWayland, `xgammon` crashes when it calls `XRecolorCursor` with a null
cursor or when `XCreateFontCursor` fails for certain shapes. The bundled shim
(`xgammon_fix.c`, MIT licensed) intercepts both calls and falls back to sane
values, so the game runs fine on Wayland compositors **and** on plain X11.

---

## Requirements

- **CPU architecture:** `x86_64-linux`
- **NixOS** (or any system with Nix installed) for the Nix install methods
- **Display:** an X11 session, or a Wayland session (via XWayland) — both work
- No root/sudo needed to *run* the AppImage directly

---

## Installation

### Option 1 — Try it without installing

```bash
nix run github:tehnium/xgammon-nix
```

### Option 2 — NixOS with flakes (recommended)

Add this repository as an input and expose the package. In your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    xgammon.url = "github:tehnium/xgammon-nix";
  };

  outputs = { self, nixpkgs, xgammon, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ pkgs, ... }: {
          environment.systemPackages = [
            xgammon.packages.${pkgs.system}.default
          ];
        })
      ];
    };
  };
}
```

Or, more concisely, use the provided NixOS module:

```nix
{
  inputs.xgammon.url = "github:tehnium/xgammon-nix";

  outputs = { nixpkgs, xgammon, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        xgammon.nixosModules.default
      ];
    };
  };
}
```

Then rebuild:

```bash
sudo nixos-rebuild switch
```

> **Note:** flakes only see files tracked by Git. If you clone this repo
> yourself, make sure the AppImage is committed
> (`git add xgammon-x86_64.AppImage`).

### Option 3 — NixOS without flakes (copy the files)

If you manage NixOS the classic way (`/etc/nixos/configuration.nix`), copy four
files next to your configuration:

```bash
sudo cp xgammon.nix package.nix xgammon-x86_64.AppImage xgammon.png /etc/nixos/
```

Add the module to your imports in `/etc/nixos/configuration.nix`:

```nix
{
  imports = [
    ./hardware-configuration.nix
    ./xgammon.nix          # <-- add this
  ];
}
```

Then rebuild:

```bash
sudo nixos-rebuild switch
```

### Option 4 — Install into your Nix profile

```bash
nix profile install github:tehnium/xgammon-nix
xgammon
```

### Option 5 — On non-NixOS Linux (plain AppImage)

Download `xgammon-x86_64.AppImage`, then:

```bash
chmod +x xgammon-x86_64.AppImage
./xgammon-x86_64.AppImage
```

(Some distributions require FUSE; if mounting fails, run it with
`APPIMAGE_EXTRACT_AND_RUN=1 ./xgammon-x86_64.AppImage`.)

---

## Usage

- **Applications menu:** *Games → xgammon*
- **Terminal:**

  ```bash
  xgammon
  ```

Command-line options of the original game still apply, e.g.:

```bash
xgammon -geometry 900x700     # set the window size
xgammon -help
```

> If a freshly installed entry does not show up in the menu, log out and back in
> (or restart the panel: `mate-panel --replace &`). The desktop shell builds its
> application menu at login.

---

## Verify the AppImage

The committed AppImage is a fixed artifact. You can check it after download:

```bash
sha256sum xgammon-x86_64.AppImage
# fa5eec9bce5538b0273397869a409b4dcbdb64816d8f16eb7af11b43c43affbb  xgammon-x86_64.AppImage
```

Size: **2 320 888 bytes (2.3 MB)**.

---

## Repository contents

| File | Description |
| --- | --- |
| `README.md` | This file |
| `LICENSE` | GNU GPL v2 (covers xgammon) |
| `package.nix` | Nix package: wraps the AppImage + desktop entry + icon |
| `xgammon.nix` | NixOS module for the no-flakes workflow |
| `flake.nix` | Flake exposing `packages`, `apps`, `nixosModules` and `overlays` |
| `flake.lock` | Pinned flake inputs |
| `xgammon-x86_64.AppImage` | The self-contained game (all deps bundled) |
| `xgammon.png` | Application icon |
| `xgammon_fix.c` | Source of the Wayland `LD_PRELOAD` shim (MIT) |
| `scripts/build-appimage.sh` | Rebuild the AppImage from the original Debian package |
| `.github/workflows/build.yml` | CI: builds the package on every push / PR |
| `CHANGELOG.md` | Release history |
| `CONTRIBUTING.md` | How to contribute and test changes |
| `.editorconfig` | Editor / formatting defaults |

## Build it yourself (from this repo)

```bash
nix-build ./package.nix -o result
./result/bin/xgammon
```

Or with flakes:

```bash
nix build            # or: nix build .#xgammon
nix flake check
./result/bin/xgammon
```

## Rebuilding the AppImage from scratch

If you ever need to regenerate the AppImage:

```bash
./scripts/build-appimage.sh /path/to/xgammon_0.98-13_amd64.deb
```

The original Debian package is available from the
[Debian snapshot archive](https://snapshot.debian.org/package/xgammon/).
After rebuilding, update the checksum in the section above.

## Known limitations

| Issue | Status | Workaround |
| --- | --- | --- |
| No native Wayland support | Won't fix (upstream dead) | Runs fine via XWayland |
| No HiDPI scaling | Won't fix | Launch with `GDK_SCALE=2` |
| Window not resizable | Original design | Use `-geometry` |
| Sound not bundled | Optional | Not required to play |

## License

- **xgammon** — GNU GPL v2 or later, © 1994 Lambert Klasen & Detlef Steuer.
  See [`LICENSE`](LICENSE).
- **Bundled libraries** — LGPL-2.1+ (glibc, libX11, libXt, libXaw, …).
- **`xgammon_fix.so` (Wayland shim)** — MIT, part of this packaging effort.

## Credits

- **Original authors:** Detlef Steuer, Lambert Klasen
- **Debian maintainers:** Joe Nahmias, Luis Francisco Gonzalez
- **AppImage packaging, Wayland shim & NixOS packaging:** this project

## Related projects

- [gnubg — GNU Backgammon](https://www.gnubg.org/) — a modern, actively
  maintained backgammon engine (also available in nixpkgs as `gnubg`)
- [AppImage](https://appimage.org/) — the portable application format

---

**Enjoy classic backgammon on modern Linux!** 🎲
