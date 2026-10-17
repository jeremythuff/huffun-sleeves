# huFFuη repository sleeves

Nine format-2 sleeves cover unwrapping, platform-specific Steamworks emulation,
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
