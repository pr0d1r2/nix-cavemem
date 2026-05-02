# nix-cavemem

[![CI](https://github.com/pr0d1r2/nix-cavemem/actions/workflows/ci.yml/badge.svg)](https://github.com/pr0d1r2/nix-cavemem/actions/workflows/ci.yml)

Nix package for [cavemem](https://github.com/JuliusBrussee/cavemem) — cross-agent persistent memory with compressed storage. Pre-built binaries served via [cachix](https://pr0d1r2.cachix.org).

## Usage

### As a flake input

```nix
{
  inputs.nix-cavemem = {
    url = "github:pr0d1r2/nix-cavemem";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # In devShell packages:
  nix-cavemem.packages.${system}.default
}
```

### Direct run

```bash
nix run github:pr0d1r2/nix-cavemem
```

## Binary cache

Cavemem is cached via [cachix](https://pr0d1r2.cachix.org). The flake includes `nixConfig` with the substituter, so `nix build` pulls pre-built binaries instead of compiling.

To accept the cache without prompts, add to `~/.config/nix/nix.conf`:

```ini
trusted-substituters = https://pr0d1r2.cachix.org
trusted-public-keys = pr0d1r2.cachix.org-1:NfWjbhgAj41byXhCKiaE+av3Vnphm1fTezHXEGsiQIM=
```

## License

MIT
