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

  npmDepsHash = "sha256-c/RhZr6N8DLlSBct7jcQMQO5jaj0PFxi1QlPFq2IBe8=";

  dontNpmBuild = true;

  # better-sqlite3 13 publishes gypfile=false and no install script, so
  # npm rebuild skips it. Compile the N-API addon explicitly.
  preInstall = ''
    npm run build-release --prefix node_modules/better-sqlite3
  '';

  # node-gyp leaves its build tree next to the compiled better-sqlite3
  # addon. Its Makefiles and .d files name python3, npm and the node
  # source, which would otherwise stay in the runtime closure.
  postInstall = ''
    build="$out/lib/node_modules/cavemem/node_modules/better-sqlite3/build"
    find "$build" -type f ! -name '*.node' -delete
    find "$build" -type d -empty -delete
  '';

  # Fail the build if the build tree, or anything else, leaks python3
  # into the runtime closure again.
  disallowedReferences = [ pkgs.python3 ];

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
