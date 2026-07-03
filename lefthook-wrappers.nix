{
  pkgs,
  sources,
}:
let
  wrap =
    name: src: extra:
    pkgs.writeShellApplication (
      {
        inherit name;
        text = builtins.readFile "${src}/${name}.sh";
      }
      // extra
    );

  runtimeInputsFor = {
    git-conflict-markers = [ pkgs.gnugrep ];
    git-no-local-paths = [ pkgs.gnugrep ];
    statix = [ pkgs.statix ];
    trailing-whitespace = [ pkgs.gnugrep ];
    deadnix = [ pkgs.deadnix ];
    editorconfig-checker = [ pkgs.editorconfig-checker ];
    markdownlint = [ pkgs.markdownlint-cli ];
    nixfmt = [ pkgs.nixfmt ];
    typos = [ pkgs.typos ];
    yamllint = [ pkgs.yamllint ];
  };

  mkWrapper =
    key: src:
    if key == "nix-no-embedded-shell" then
      pkgs.writeShellApplication {
        name = "lefthook-nix-no-embedded-shell";
        text = ''
          SCANNER="${src}/scan-nix-no-embedded-shell.sh"
        ''
        + builtins.readFile "${src}/lefthook-nix-no-embedded-shell.sh";
      }
    else
      wrap "lefthook-${key}" src {
        runtimeInputs = runtimeInputsFor.${key} or [ ];
      };
in
pkgs.lib.mapAttrsToList mkWrapper sources
