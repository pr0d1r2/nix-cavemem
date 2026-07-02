# CLAUDE.md

## Project

Nix flake packaging [cavemem](https://github.com/JuliusBrussee/cavemem) v0.1.3 — a cross-agent persistent memory tool with compressed storage. Pre-built binaries via `pr0d1r2.cachix.org`.

## Build

```bash
nix build            # build the cavemem package
nix flake check      # validate the flake (runs on all supported systems)
```

## Development

```bash
nix develop          # enter dev shell (auto-installs lefthook hooks)
```

The dev shell provides: cavemem, nixfmt, statix, deadnix, yamllint, typos, editorconfig-checker, lefthook, and all lefthook wrapper scripts.

## Lint / Pre-commit

Pre-commit hooks run automatically via lefthook on every commit. To run manually:

```bash
lefthook run pre-commit
```

Hooks enforced:

- **nixfmt** — Nix formatting
- **statix** — Nix linting
- **deadnix** — unused Nix code detection
- **nix-no-embedded-shell** — no inline shell scripts in `.nix` files
- **nix-flake-check** — `nix flake check` must pass
- **editorconfig-checker** — `.editorconfig` compliance
- **yamllint** — YAML linting
- **typos** — spell checking
- **trailing-whitespace** — no trailing whitespace
- **missing-final-newline** — files must end with a newline
- **git-conflict-markers** — no unresolved conflict markers
- **git-no-local-paths** — no local Nix paths

## Test

There is no dedicated test suite. Validation is done through:

```bash
nix flake check      # flake validity
lefthook run pre-commit  # all lint checks
```

## Conventions

- UTF-8 encoding, LF line endings, 2-space indentation, trimmed trailing whitespace, final newline (see `.editorconfig`)
- Nix files formatted with `nixfmt`
- No embedded shell scripts in `.nix` files — use `builtins.readFile` to load external `.sh` files
- Markdown line length is unrestricted (`MD013: false`)
- YAML: truthy key checks disabled, line-length rules off (`.yamllint.yml`)
- `package.json` and `package-lock.json` must stay in sync with upstream cavemem v0.1.3; any `package-lock.json` change requires updating `npmDepsHash` in `cavemem.nix`
- Supported systems: `aarch64-darwin`, `x86_64-darwin`, `x86_64-linux`, `aarch64-linux`
- Never use `git commit --no-verify` — fix the hook failure instead

## Architecture

| File | Purpose |
|---|---|
| `flake.nix` | Flake definition, inputs, outputs, dev shell, lefthook wrappers |
| `cavemem.nix` | `buildNpmPackage` derivation for cavemem |
| `package.json` | npm metadata overlaid onto upstream tarball |
| `package-lock.json` | Locked npm dependency tree (drives `npmDepsHash`) |
| `lefthook.yml` | Pre-commit hook configuration (12 remote hooks) |
| `dev.sh` | Dev shell hook: sets `NIX_CONFIG`, auto-installs lefthook |
| `scripts/update-upstream.sh` | Upstream version bump: updates hashes and package files |

## CI

GitHub Actions (`ci.yml`): builds on `ubuntu-latest` (x86_64), `ubuntu-24.04-arm` (aarch64), and `macos-latest`. ARM and macOS jobs run only on push/dispatch, not on PRs. Builds are pushed to cachix.

A daily cron workflow (`update-upstream.yml`, 04:30 UTC) checks the npm registry for new cavemem releases and opens a PR to bump `version`, `src.hash`, and `npmDepsHash` in `cavemem.nix` (plus synced `package.json` and `package-lock.json`). The bump logic lives in `scripts/update-upstream.sh`.
