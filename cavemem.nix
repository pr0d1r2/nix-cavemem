{ pkgs }:
let
  version = "0.1.3";

  src = pkgs.fetchurl {
    url = "https://registry.npmjs.org/cavemem/-/cavemem-${version}.tgz";
    hash = "sha256-Lg3jslcOak/WDBLhseZ64x5/IlKvzsAKsNYHgB+Vwd4=";
  };

  prepared = pkgs.stdenvNoCC.mkDerivation {
    name = "cavemem-src-prepared";
    inherit src;
    sourceRoot = "package";
    dontBuild = true;
    installPhase = builtins.readFile (
      pkgs.replaceVars ./install-prepared.sh {
        packageJson = ./package.json;
        packageLockJson = ./package-lock.json;
      }
    );
  };
in
pkgs.buildNpmPackage {
  pname = "cavemem";
  inherit version;

  src = prepared;

  npmDepsHash = "sha256-ZS6r5xGhn7wLFakMp8k81GzReUEE6XSRSskiyPFm6gA=";

  dontNpmBuild = true;

  nativeBuildInputs = with pkgs; [
    python3
    pkg-config
  ];

  buildInputs = with pkgs; [
    sqlite
  ];

  meta = with pkgs.lib; {
    description = "Cross-agent persistent memory with compressed storage";
    homepage = "https://github.com/JuliusBrussee/cavemem";
    license = licenses.mit;
    mainProgram = "cavemem";
  };
}
