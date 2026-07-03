# nix-cavemem

## §D — Description

nix-cavemem is a Nix flake that packages [cavemem](https://github.com/JuliusBrussee/cavemem) (v0.1.3), a cross-agent persistent memory tool with compressed storage designed for AI coding assistants (Claude Code, Gemini CLI, OpenCode, Codex, Cursor). The flake fetches the npm tarball, builds it with `buildNpmPackage`, and serves pre-built binaries via a cachix binary cache (`pr0d1r2.cachix.org`). It targets NixOS and macOS users who want a reproducible, declarative way to install cavemem as a flake input or via `nix run`, without compiling native SQLite bindings from source.

## §V — Invariants

1. `nix flake check` must pass — enforced by CI and the `nix-lefthook-nix-flake-check` pre-commit hook.
2. The package must build on all four supported systems: `aarch64-darwin`, `x86_64-darwin`, `x86_64-linux`, `aarch64-linux`.
3. CI builds run on `ubuntu-latest` (x86_64), `ubuntu-24.04-arm` (aarch64), and `macos-latest` (aarch64-darwin) — ARM and macOS jobs run only on push/dispatch, not on PRs.
4. Pre-commit hooks (via lefthook) enforce: nixfmt formatting, statix linting, deadnix unused-code detection, no embedded shell scripts in Nix files, editorconfig compliance, markdownlint, yamllint, typos, trailing whitespace removal, final newline presence, no git conflict markers, and no local Nix paths.
5. `package.json` and `package-lock.json` are locally maintained and copied over the upstream npm tarball sources during the `prepared` derivation phase — they must stay in sync with upstream cavemem v0.1.3.
6. The `npmDepsHash` in `cavemem.nix` must match the locked dependency tree; any `package-lock.json` change requires updating this hash.
7. All files use UTF-8 encoding, LF line endings, 2-space indentation, trimmed trailing whitespace, and a final newline (`.editorconfig`).
8. Markdown line length is unrestricted (`MD013: false`); YAML truthy key checks are disabled and line-length rules are off.
9. The flake pins nixpkgs via `pr0d1r2/nixpkgs-lock` (currently `nixos-25.11`); the pin is updated manually via `nix flake update`.
10. The cachix substituter and public key are declared in `nixConfig` so users get pre-built binaries by default.

## §I — Interfaces

### Flake outputs

```nix
packages.${system}.default  # cavemem binary (Node.js CLI)
devShells.${system}.default  # development shell with all tools
devShells.${system}.ci       # alias for default (used in CI)
```

### CLI (provided by upstream cavemem)

```text
cavemem            # entry point: dist/index.js
```

The binary is an MCP server and CLI for cross-agent persistent memory backed by SQLite with compressed storage. Depends on Node.js >= 20.0.0.

### Nix derivation interface (`cavemem.nix`)

```nix
import ./cavemem.nix { pkgs }: derivation
```

Single argument `pkgs` (a nixpkgs package set). Returns a `buildNpmPackage` derivation. Native build inputs: `python3`, `pkg-config`. Runtime inputs: `nodejs`, `sqlite`.

### Configuration files

| File | Format | Purpose |
| --- | --- | --- |
| `flake.nix` | Nix | Flake definition, inputs, outputs, dev shell |
| `flake.lock` | JSON | Pinned input revisions |
| `cavemem.nix` | Nix | Package derivation for cavemem |
| `lefthook-wrappers.nix` | Nix | Shared utility for creating lefthook wrapper scripts |
| `package.json` | JSON | npm metadata overlaid onto upstream tarball |
| `package-lock.json` | JSON | Locked npm dependency tree for `npmDepsHash` |
| `lefthook.yml` | YAML | Pre-commit hook configuration (13 remote hooks) |
| `.editorconfig` | INI | Editor formatting rules |
| `.envrc` | Shell | direnv integration (`use flake`) |
| `dev.sh` | Shell | Dev shell hook: sets `NIX_CONFIG`, auto-installs lefthook |
| `scripts/update-upstream.sh` | Shell | Upstream version bump script: updates hashes, `package.json`, `package-lock.json` |

### Environment variables

| Variable | Set by | Purpose |
| --- | --- | --- |
| `NIX_CONFIG` | `dev.sh` | Enables `nix-command flakes` experimental features |

### GitHub Actions workflows

| Workflow | Trigger | Purpose |
| --- | --- | --- |
| `ci.yml` | push/PR to main, dispatch | Build on Linux x86_64, Linux ARM, macOS; push to cachix |
| `update-upstream.yml` | daily cron (04:30 UTC), dispatch | Detect new cavemem npm version and open a PR to bump `version`, `src.hash`, `npmDepsHash` |

## §T — Tasks

| status | id | goal |
| --- | --- | --- |
| `x` | T1 | Add a `CLAUDE.md` with build/lint/test commands and project conventions |
| `x` | T2 | Add `nix build` / `nix flake check` smoke test to CI that validates the built binary runs (`cavemem --help`) |
| `x` | T3 | Add a `deadnix` lefthook wrapper to `flake.nix` (deadnix is in devShell packages and lefthook remotes, but missing from the `lefthookWrappersFor` list) |
| `x` | T4 | Use the full 40-char commit SHA for `nix-lefthook-ci-action` in `ci.yml` (no tagged releases exist on the action repo) |
| `x` | T5 | Add `yamllint` lefthook wrapper to `flake.nix` (yamllint is in devShell packages and lefthook remotes, but missing from `lefthookWrappersFor`) |
| `x` | T6 | Add automated upstream version tracking — detect when cavemem publishes a new npm version and open a PR to bump `version`, `src.hash`, and `npmDepsHash` |
| `x` | T7 | Add `markdownlint` to the lefthook pre-commit checks (config exists in `.markdownlint.yml` but no hook is wired) |
| `x` | T8 | Add macOS ARM (`macos-latest-xlarge` or similar) CI job for full `aarch64-darwin` coverage |
| `x` | T9 | Add `git-no-local-paths` lefthook wrapper to `flake.nix` (in lefthook remotes and devShell but missing from `lefthookWrappersFor`) |
| `x` | T10 | Consider extracting the `lefthookWrappersFor` pattern into a shared flake utility since it is repeated across multiple `pr0d1r2/nix-*` projects |

## §B — Bugs / Known Issues

1. ~~**Missing lefthook wrappers**~~: Fixed by T3, T5, and T9 — `deadnix`, `yamllint`, and `git-no-local-paths` now all have wrappers in `lefthookWrappersFor`.
2. ~~**No `markdownlint` hook or package**~~: Fixed by T7 — markdownlint is now in devShell packages, wired as a lefthook remote hook, and has a wrapper in `lefthookWrappersFor`.
3. **Hardcoded upstream version**: The cavemem version (`0.1.3`) is specified in three places — `cavemem.nix`, `package.json`, and `package-lock.json` — with no single source of truth or automated update mechanism. A version bump requires coordinated edits plus hash recalculation.
4. ~~**`ci.yml` uses `actions/checkout@v6`; `update-pins.yml` uses `actions/checkout@v4`**~~: The `update-pins.yml` workflow does not exist in the repo (§I referenced it, now corrected). GitHub Actions in `ci.yml` and `update-upstream.yml` updated to latest versions (checkout v7, install-nix-action v31, setup-node v6).
5. ~~**No runtime test**~~: Fixed — `ci.yml` now includes a smoke test (`nix build && ./result/bin/cavemem --help`) on all three platforms.
6. **`devShells.ci` is just an alias**: `ci = default` means the CI shell pulls in developer-only tools (lefthook wrappers, editorconfig-checker, etc.) that are unused in the CI build job. A leaner CI-specific shell would reduce closure size and build time.
7. ~~**`ci.yml` referenced non-existent `@v1` tag on `nix-lefthook-ci-action`**~~: Fixed by pinning to the latest commit SHA `ce9a118b05e90e186dba48a82067adeed185f7d4` (2026-07-02).
8. ~~**`ci.yml` used shortened commit SHA for `nix-lefthook-ci-action`**~~: Fixed by using the full SHA `ce9a118b05e90e186dba48a82067adeed185f7d4` (2026-07-02).
9. **No `update-pins.yml` workflow**: §V item 9 and §I reference a daily cron job to auto-update the `nixpkgs-lock` pin, but no such workflow exists. The `flake.lock` entry for `nixpkgs-lock` is only updated manually via `nix flake update`.
10. ~~**`update-upstream.sh` lacked input validation**~~: The script did not check for a missing version argument or report tarball download failures. Fixed — the script now validates its argument and reports curl errors.
