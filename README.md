# huFFuη repository sleeves

Eleven format-2 sleeves cover unwrapping, platform-specific Steamworks emulation,
Wine translation, ScummVM interpretation, the two Fallout CE interpreters and
Windows/macOS offline installer handling. Detection is file-based; there are no
build-title rules. Resolved requirements are dropped; the path records provenance.

Runtime release assets are hosted privately at
`releases/tag/sleeve-runtimes-20261016` and pinned by archive and content-tree
digests. Eight original runtime trees were repackaged without changing their
tree digests. The new Mac extractor uses locked MacPorts packages and includes
license notices and source references. See `resources/` for identities and sources.
No binaries belong in Git. Activation and native launch acceptance belong to
owner-controlled Checkpoint 3; existing sleeves remain active meanwhile.

Run `make test` and `make check` using the sibling application worktree and its
Mac Podman make wrappers. The two migration tests check nine manifests and 20
static state/path/listing fixtures. Fixtures use stand-in runtime programs and do
not execute preinstall or client scripts. A final application `make verify` and
the every-current-build live comparison remain outstanding at the owner's request
to stop further testing and wrap up.

Mac Windows-installers use client innoextract before Wine. They currently require
one primary FileTask with no play arguments and extract the selected base installer;
automatic DLC installation is not implemented. macOS packages use pkgutil expansion
without running package scripts and require exactly one modern application bundle.
These paths require native installation and launch acceptance before activation.

The review base is `codex/sleeve-graph-p2-bootstrap`; the remote has no `main` yet.
The owner merges and activates at Checkpoint 3, compares while legacy packages
remain available, then deactivates the old packages.

To reproduce the new extractor bundle, use `tools/stage.py` then the app's
`make node ARGS='.scratch/sleeves-p35/tools/build-inno.ts'` and
`make node ARGS='.scratch/sleeves-p35/tools/package-inno.ts'` in Mac Podman.
The first uses `resources/innoextract-sources.json` package hashes; the second
adds notices, strips the unused architecture and creates the deterministic ZIP.
Both use the application’s ignored `.scratch/assets` staging directory.

## Windows (2026-10-19)

`huffun-sleeves.json` declares what a Windows PC provides natively
(`clients.windows`): DirectDraw programs and a Windows release's own Fallout
engines run as archived there, so those builds need no sleeve on Windows
(huFFuη format 2, "Client facts"). `gog-inno` (version 2) extracts offline
installers on Windows with a pinned innoextract, as on Mac, instead of running
GOG's setup program, and writes `Play <title>.cmd` for GOG's primary play
task. `retroarch-snes9x-windows` plays Super Nintendo ROMs with RetroArch and
Snes9x on Windows.

Their runtime archives are attached to `releases/tag/sleeve-runtimes-20261019`
and rebuilt reproducibly with `tools/repack-runtime.py` (stored, fixed dates
and modes; it prints the archive and tree digests the pins record):

| Archive | Root | From (official) |
|---|---|---|
| `innoextract-1.9-windows.zip` | `innoextract` | `innoextract-1.9-windows.zip`, SHA-256 `6989342c…3065` |
| `retroarch-1.22.2-windows.zip` | `RetroArch-Win64` | `stable/1.22.2/windows/x86_64/RetroArch.7z`, SHA-256 `b2139b1d…6372` (extract with `7z x` first; pass its `RetroArch-Win64` folder) |
| `core-snes9x-2026.10.18-windows.zip` | `cores` | the 2026-10-18 nightly `snes9x_libretro.dll.zip`, SHA-256 `bb5f135e…2fad` (the nightly URL changes; keep this archive) |
