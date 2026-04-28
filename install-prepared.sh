mkdir -p "$out"
cp -r . "$out/"
cp @packageJson@ "$out/package.json"
cp @packageLockJson@ "$out/package-lock.json"
