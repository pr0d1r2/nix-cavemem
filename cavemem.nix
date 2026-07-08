{ pkgs }:
let
  version = "0.2.1";

  src = pkgs.fetchurl {
    url = "https://registry.npmjs.org/cavemem/-/cavemem-${version}.tgz";
    hash = "sha256-3l9XfsEs2gwQ4lyyv0dgFV8CILmrQBupTh5wSWLa4y0=";
  };

  prepared = pkgs.stdenvNoCC.mkDerivation {
    name = "cavemem-src-prepared";
    inherit src;
    sourceRoot = "package";
    dontBuild = true;
    localPackageJson = ./package.json;
    localPackageLockJson = ./package-lock.json;
    installPhase = ''
      mkdir -p "$out"
      cp -r . "$out/"
      cp "$localPackageJson" "$out/package.json"
      cp "$localPackageLockJson" "$out/package-lock.json"
    '';
  };
in
pkgs.buildNpmPackage {
  pname = "cavemem";
  inherit version;

  src = prepared;

  npmDepsHash = "sha256-HbL4HaDwe6RqZY8puhWmvq9dIAsK0HimwvjLzq2bByY=";

  dontNpmBuild = true;

  nativeBuildInputs = with pkgs; [
    python3
    pkg-config
  ];

  buildInputs = with pkgs; [
    nodejs
    sqlite
  ];

  meta = with pkgs.lib; {
    description = "Cross-agent persistent memory with compressed storage";
    homepage = "https://github.com/JuliusBrussee/cavemem";
    license = licenses.mit;
    mainProgram = "cavemem";
  };
}
