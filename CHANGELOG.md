# Changelog

All notable changes to this project are documented here.

## Unreleased

- Restore `better-sqlite3` to `^13.0.3` (N-API) and raise `engines.node`
  to `>=22.0.0`. The 12.11.1 pin brought back the NAN addon, whose
  `Statement::~Statement()` aborts the `stop` hook on Node 24.19+ with
  `Assertion failed: (env) != nullptr`. Compile the addon explicitly in
  `preInstall`, since npm 11.19 no longer builds it. See SPEC.md items
  14-16.

- Drop better-sqlite3's node-gyp build tree after install, keeping only the
  compiled addons. It referenced python3, npm and the node source, so the
  runtime closure shrinks from 1.6 GiB to 265 MiB.

- Pin `better-sqlite3` to 12.11.1 in the local `package.json` override.
  cavemem 0.2.1 asks for `^11.5.0`, which resolves to a release line
  upstream does not test against Node 24, and the `stop` hook has been
  aborting at teardown inside that addon. The bump moves the build onto
  the supported line; it is not a proven fix for the abort. See SPEC.md
  item 14.
