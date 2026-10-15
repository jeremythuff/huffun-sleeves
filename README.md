# huFFuη sleeve repository

This repository supplies sleeves, fact documentation and detectors to huFFuη
through its format-2 repository connection (ADR 0017).

The initial manifest establishes the stable `huffun-sleeves` namespace. Its
sleeve and detector lists are deliberately empty: this bootstrap proves the
connection without activating or migrating any existing member sleeves.
The approved redesign moves the actual sleeves here in Phase 3.

The normative format is maintained in the application repository:
`docs/sleeves/format-2.md` (sleeve graph Phase 2).

Until the owner establishes `main`, the bootstrap is available on
`codex/sleeve-graph-p2-bootstrap`. Configure that branch explicitly in a
connection when testing it. The application's code repository still uses
owner-reviewed pull requests; no agent pushes its `main`.
