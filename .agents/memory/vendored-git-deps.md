---
name: Patching pinned git dependencies in this Flutter app
description: How to fix a bug inside conduit_vt/dartssh2 (git-pinned forks the app depends on) without upstream push access.
---

`conduit_vt` and `dartssh2` are git dependencies in `pubspec.yaml`, pinned to a
commit under `gwitko/*` on GitHub. This workspace has no push access to those
repos, and `flutter`/`dart pub` isn't installed here, so nothing can be
verified by actually running the app.

**How to apply a fix anyway:** download the pinned-ref source as a tarball
(`https://codeload.github.com/<owner>/<repo>/tar.gz/<ref>`), extract it under
`vendor/<pkg>/`, trim non-essential dirs (example/, test/, script/, bin/,
media/, .github/) to keep the repo lean, edit the source, and add a
`dependency_overrides: <pkg>: { path: vendor/<pkg> }` entry in `pubspec.yaml`
with a comment explaining the bug and linking to a README-PATCH.md in the
vendor dir. Leave the original git dependency entry in place (untouched) so
it's obvious what upstream ref this is patching and the override can be
dropped later once fixed upstream.

**Why:** the app can't be run/tested in this workspace (Flutter SDK isn't
installed, it's a mobile app built via GitHub Actions CI), and there's no
credentialed access to push a fix to the forked dependency repos. Vendoring +
`dependency_overrides` is the standard Dart/Flutter way to patch a third-party
package without needing upstream write access, and it's fully committed to
this repo so CI picks it up automatically.

**How to apply:** whenever a bug is traced into `conduit_vt` or `dartssh2`
source (not the app's own `lib/` code) and needs a real code fix rather than
a workaround from the app side.

**Verifying without Flutter installed:** `dart-3.10` can be installed via
package-management and used for `dart format --output=none <file>` to catch
syntax errors in the edited file (it parses successfully even without full
package resolution). Full semantic analysis needs `flutter pub get`, which
isn't available here — `dart analyze` on a lone file inside a Flutter package
will report spurious "undefined name" errors for every sibling-file symbol;
that's expected and not a sign of a real problem.
