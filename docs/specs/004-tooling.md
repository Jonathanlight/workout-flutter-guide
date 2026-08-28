# 004 — Tooling

Three scripts under `tool/`, all plain Dart (`dart run`), none shipped to
pub.dev (`.pubignore`).

## `import_upstream.dart <path-to-upstream-checkout>`

Copies from a local clone of `bryllim/workout-guide`:

- `packages/workout-guide/manifest.json` → `assets/manifest.json`, verbatim.
- `packages/workout-guide/assets/<slug>/frame-N.svg` →
  `assets/exercises/<slug>/frame-N.svg`, byte-for-byte.

Never copies PNGs, upstream site files or upstream scripts. Refuses to run if
the manifest does not describe exactly 302 exercises × 3 frames, and reports
any file listed in the manifest that is missing on disk. Prints a summary
(files copied, total bytes) so the import commit message can be accurate.

## `generate_catalog.dart`

`assets/manifest.json` → `lib/src/generated/catalog.g.dart`, and rewrites the
assets block of `pubspec.yaml` between the `BEGIN/END GENERATED ASSETS`
markers (one `assets/exercises/<slug>/` entry per exercise, since Flutter does
not glob recursively).

The generated file exposes exactly one public symbol, `kExerciseCatalog`, a
`const List<Exercise>`. Repeated attribution objects are hoisted into private
constants (`_bryl` for the 830 frames with no upstream source, `_srcNNN` for
the 76 that have one) so the file stays readable and the const pool small.

Output is run through `dart format` by the script itself, so the file is
committed in its final form and `dart format --set-exit-if-changed .` passes.

## `validate_assets.dart`

Fails loudly if any of the following is untrue:

- the catalog has 302 exercises, each with 3 frames indexed 1..3;
- each declared asset file exists and is non-empty;
- each file parses as XML, is an `<svg>` root, and declares
  `width="512" height="512"` (or an equivalent `viewBox`);
- `pubspec.yaml` declares every asset directory the catalog references;
- no PNG sneaked into `assets/`.

Widget-level rendering (`flutter_svg` actually decoding all 906 files) is
covered by a test rather than this script, so it runs in the same
`flutter test` gate as everything else.

## `generate_normalizer_table.dart`

Emits `lib/src/catalog/diacritics.g.dart`, the transliteration table described
in spec 002, from the canonical decompositions in `UnicodeData.txt` (fetched
from unicode.org, or read from a local path passed as an argument). Run rarely;
the output is checked in.
