# huFFuη sleeve migration — work in progress

Nine format-2 sleeves cover unwrapping, platform-specific Steamworks emulation,
Wine translation, ScummVM interpretation, the two Fallout CE interpreters and
Windows/macOS offline installer handling. Detection is file-based; there are no
build-title rules. Resolved requirements are dropped; the path records provenance.

**Do not activate this branch yet.** Runtime release URLs in manifests are not
published. Eight original runtime trees were repackaged without changing their
tree digests; the new Mac extractor uses locked MacPorts packages but packaging,
license notices and native execution still need review. See `resources/` for
identities and sources. No binaries belong in Git.

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
