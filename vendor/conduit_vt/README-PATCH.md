# Local patch: colon-delimited SGR parameters

This is a vendored copy of [`conduit_vt`](https://github.com/gwitko/conduit_vt)
pinned at commit `b486b894ea12b18b2ad76339ccd8c6ae3c12416f` (the same ref used
by the `conduit_vt` git dependency in the app's `pubspec.yaml`), with one bug
fix applied locally. It's wired in via `dependency_overrides` in the app's
`pubspec.yaml` so `flutter pub get` uses this copy instead of fetching the
git dependency.

## The bug

`lib/src/core/escape/parser.dart`'s `_consumeCsi()` parses CSI escape
sequence parameters by splitting on `;` (semicolon, ASCII 59). It did not
handle `:` (colon, ASCII 58) at all — the byte matched none of the parsing
branches, so it was silently consumed without resetting the digit
accumulator or terminating the current parameter.

Many terminal apps (fzf among them) emit extended SGR color sequences using
the ITU-T T.416 colon sub-parameter syntax, e.g. `ESC[48:5:196m` (256-color
background) or `ESC[38:2::255:0:0m` (truecolor). With the colon silently
dropped, the digits on either side of it got concatenated into one garbage
integer instead of being split into separate parameters, so the intended
color was never applied. Basic ANSI codes (30-37/40-47, used by things like
`ls --color`) were unaffected since they don't need extended-color
sub-parameters — only colon-delimited 256-color/truecolor sequences broke,
which is why the symptom only showed up with tools like fzf that rely on
those and not with everyday shell/tool output.

## The fix

Treat `:` the same as `;` when splitting CSI parameters, so colon-delimited
sequences parse into the same parameter list a semicolon-delimited one
would.

## Removing this override

Once this fix (or an equivalent one) lands in the upstream `conduit_vt`
repository at a new commit, bump the `ref` on the `conduit_vt` git
dependency in the app's `pubspec.yaml` to that commit and delete the
`dependency_overrides` entry and this `vendor/conduit_vt` directory.
