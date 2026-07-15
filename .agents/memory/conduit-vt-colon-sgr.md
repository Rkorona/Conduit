---
name: conduit_vt colon-delimited SGR parsing
description: Why fzf-style extended terminal colors (256-color/truecolor) rendered invisibly in Conduit's terminal.
---

`conduit_vt` (the forked xterm.dart terminal emulator this app uses,
`lib/src/core/escape/parser.dart`, `_consumeCsi()`) split CSI escape
parameters only on `;` (semicolon). It had no branch for `:` (colon,
ASCII 58): the byte matched none of the parsing conditions, so it was
consumed silently without resetting the digit accumulator or terminating
the current parameter — digits before and after a colon got concatenated
into one garbage integer.

Many terminal apps (fzf in particular) emit extended SGR color sequences
using the ITU-T T.416 colon sub-parameter syntax, e.g. `ESC[48:5:196m`
(256-color) or `ESC[38:2::r:g:bm` (truecolor). With colons corrupting the
parameter stream, those colors silently failed to apply — while plain
ANSI 16-color codes (`ls --color`, prompt colors) still worked fine since
they don't need sub-parameters. Symptom: fzf's current-line highlight (or
any `--color=bg+:<n>`) was invisible in Conduit's terminal even though the
same session looked normal otherwise, and the 256-color palette itself
(`lib/src/ui/palette_builder.dart`) and SGR-inverse rendering
(`lib/src/ui/painter.dart`) were both already correct — the bug was purely
in colon handling during parameter tokenization.

**Fix applied:** treat `:` the same as `;` in `_consumeCsi()`'s parameter
loop (push the accumulated param, reset to 0, continue). Patched via the
`vendor/conduit_vt` override — see
[vendored-git-deps.md](vendored-git-deps.md).

**Not fully solved:** truecolor colon syntax with an explicit color-space
sub-param (`38:2:<colorspace>:r:g:b`, 4 slots vs the semicolon form's 3)
still misaligns by one slot, since distinguishing colon-grouped vs
semicolon-grouped sub-params would need real ITU-T T.416 grouping support.
Only the 256-color case (`38:5:n` / `48:5:n`, no extra slot) and the
no-colorspace truecolor form were fixed/verified by reasoning; if a future
bug report involves truecolor login shells with colon syntax specifically,
revisit this.
