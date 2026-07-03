{
  description = "Nix package for cavemem — cross-agent persistent memory";

  nixConfig = {
    extra-substituters = [ "https://pr0d1r2.cachix.org" ];
    extra-trusted-public-keys = [ "pr0d1r2.cachix.org-1:NfWjbhgAj41byXhCKiaE+av3Vnphm1fTezHXEGsiQIM=" ];
  };

  inputs = {
    nixpkgs-lock.url = "github:pr0d1r2/nixpkgs-lock";
    nixpkgs.follows = "nixpkgs-lock/nixpkgs";
    nix-lefthook-git-conflict-markers-src = {
      url = "github:pr0d1r2/nix-lefthook-git-conflict-markers";
      flake = false;
    };
    nix-lefthook-git-no-local-paths-src = {
      url = "github:pr0d1r2/nix-lefthook-git-no-local-paths";
      flake = false;
    };
    nix-lefthook-missing-final-newline-src = {
      url = "github:pr0d1r2/nix-lefthook-missing-final-newline";
      flake = false;
    };
    nix-lefthook-nix-no-embedded-shell-src = {
      url = "github:pr0d1r2/nix-lefthook-nix-no-embedded-shell";
      flake = false;
    };
    nix-lefthook-trailing-whitespace-src = {
      url = "github:pr0d1r2/nix-lefthook-trailing-whitespace";
      flake = false;
    };
    nix-lefthook-statix-src = {
      url = "github:pr0d1r2/nix-lefthook-statix";
      flake = false;
    };
    nix-lefthook-deadnix-src = {
      url = "github:pr0d1r2/nix-lefthook-deadnix";
      flake = false;
    };
    nix-lefthook-editorconfig-checker-src = {
      url = "github:pr0d1r2/nix-lefthook-editorconfig-checker";
      flake = false;
    };
    nix-lefthook-nixfmt-src = {
      url = "github:pr0d1r2/nix-lefthook-nixfmt";
      flake = false;
    };
    nix-lefthook-typos-src = {
      url = "github:pr0d1r2/nix-lefthook-typos";
      flake = false;
    };
    nix-lefthook-markdownlint-src = {
      url = "github:pr0d1r2/nix-lefthook-markdownlint";
      flake = false;
    };
    nix-lefthook-yamllint-src = {
      url = "github:pr0d1r2/nix-lefthook-yamllint";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      nix-lefthook-git-conflict-markers-src,
      nix-lefthook-git-no-local-paths-src,
      nix-lefthook-missing-final-newline-src,
      nix-lefthook-nix-no-embedded-shell-src,
      nix-lefthook-trailing-whitespace-src,
      nix-lefthook-statix-src,
      nix-lefthook-deadnix-src,
      nix-lefthook-editorconfig-checker-src,
      nix-lefthook-markdownlint-src,
      nix-lefthook-nixfmt-src,
      nix-lefthook-typos-src,
      nix-lefthook-yamllint-src,
      ...
    }:
    let
      supportedSystems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems =
        f: nixpkgs.lib.genAttrs supportedSystems (system: f nixpkgs.legacyPackages.${system});

      lefthookWrappersFor =
        pkgs:
        import ./lefthook-wrappers.nix {
          inherit pkgs;
          sources = {
            git-conflict-markers = nix-lefthook-git-conflict-markers-src;
            git-no-local-paths = nix-lefthook-git-no-local-paths-src;
            missing-final-newline = nix-lefthook-missing-final-newline-src;
            nix-no-embedded-shell = nix-lefthook-nix-no-embedded-shell-src;
            statix = nix-lefthook-statix-src;
            trailing-whitespace = nix-lefthook-trailing-whitespace-src;
            deadnix = nix-lefthook-deadnix-src;
            editorconfig-checker = nix-lefthook-editorconfig-checker-src;
            markdownlint = nix-lefthook-markdownlint-src;
            nixfmt = nix-lefthook-nixfmt-src;
            typos = nix-lefthook-typos-src;
            yamllint = nix-lefthook-yamllint-src;
          };
        };
    in
    {
      packages = forAllSystems (pkgs: {
        default = import ./cavemem.nix { inherit pkgs; };
      });

      devShells = forAllSystems (pkgs: rec {
        default = pkgs.mkShell {
          packages = [
            (import ./cavemem.nix { inherit pkgs; })
            pkgs.coreutils
            pkgs.deadnix
            pkgs.editorconfig-checker
            pkgs.git
            pkgs.lefthook
            pkgs.markdownlint-cli
            pkgs.nix
            pkgs.nixfmt
            pkgs.statix
            pkgs.typos
            pkgs.yamllint
          ]
          ++ (lefthookWrappersFor pkgs);
          shellHook = builtins.readFile ./dev.sh;
        };
        ci = default;
      });
    };
}
