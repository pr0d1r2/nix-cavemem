# Changelog

All notable changes to this project are documented here.

## Unreleased

- Pin `better-sqlite3` to 12.11.1 in the local `package.json` override.
  cavemem 0.2.1 asks for `^11.5.0`, which resolves to a release line
  upstream does not test against Node 24, and the `stop` hook has been
  aborting at teardown inside that addon. The bump moves the build onto
  the supported line; it is not a proven fix for the abort. See SPEC.md
  item 14.
