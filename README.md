# nix-cavemem

[![CI](https://github.com/pr0d1r2/nix-cavemem/actions/workflows/ci.yml/badge.svg)](https://github.com/pr0d1r2/nix-cavemem/actions/workflows/ci.yml)

Nix package for [cavemem](https://github.com/JuliusBrussee/cavemem) — cross-agent persistent memory with compressed storage.

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

## License

MIT
