# 002 — Catalog API

Upstream reference: `packages/workout-guide/src/index.ts`. Behaviour must be
identical; only the surface syntax is idiomatic Dart.

## Entry point

`WorkoutGuide` is an abstract final class holding static members. There is no
instance to construct and no initialization step.

```dart
static List<Exercise> get exercises;                    // unmodifiable, 302 entries
static Exercise? getExercise(String idOrSlug);
static List<Exercise> search(String query, {...});
static String? assetPath(String idOrSlug, int frameIndex);
static String? assetCdnUrl(String idOrSlug, int frameIndex, {String? baseUrl, String version});
static const String catalogVersion = '1.0.0';           // upstream catalog version
```

## Lookup

`getExercise` checks the id map first, then the slug map, then returns `null` —
same order as upstream. Both maps are built lazily on first access and cached,
so start-up cost is not paid by apps that never look anything up.

## Normalization

`normalizeSearchText` must be a faithful port of:

```js
value.toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '')
     .replace(/&/g, ' and ').replace(/[^a-z0-9]+/g, ' ').trim().replace(/\s+/g, ' ')
```

Dart's core library has no Unicode normalization and the package takes no
runtime dependency beyond `flutter_svg`. The port therefore uses a **generated
transliteration table**: for every code point whose canonical decomposition
(applied recursively) is `<ASCII alphanumeric> + combining marks
(U+0300–U+036F)`, the table maps it to that base character, lower-cased. 490
code points qualify, all of them Latin. Everything else is left alone and, being
outside `[a-z0-9]`, collapses to a space — which is exactly what the JavaScript
does for `ß`, `æ`, `ø`, `ł` and friends.

The table is produced by `tool/generate_normalizer_table.dart` from the
official `UnicodeData.txt` and checked in, so the behaviour is reviewable and
does not drift with SDK versions. Combining marks that appear on their own are
dropped rather than turned into a separator, matching the JavaScript.

Parity is verified, not assumed: `test/golden/normalizer_parity.json` holds 524
input/output pairs produced by running the upstream JavaScript.

Order of operations is load-bearing: `&` becomes ` and ` **after** diacritics
are stripped and **before** the non-alphanumeric collapse.

## Search

```dart
static List<Exercise> search(
  String query, {
  Object? equipment,      // String | Equipment | Iterable<String|Equipment>
  Object? primaryMuscle,  // String | Muscle   | Iterable<String|Muscle>
  Object? exerciseType,   // String | ExerciseType | Iterable<...>
  bool? isStretch,
});
```

`Object?` is deliberate: it keeps upstream examples (`equipment: 'Dumbbell'`)
working while allowing the typed form (`equipment: Equipment.dumbbell`) and
either as a list. Anything else throws `ArgumentError` immediately, with the
offending value in the message. Filters compare **normalized** labels, matching
upstream `matchesFilter`, so `'pull up bar'` matches `'Pull-up Bar'`.

Semantics, in order:

1. Apply `equipment`, `primaryMuscle`, `exerciseType`, `isStretch`. A filter
   with several values is an OR within that filter; different filters are AND.
2. Tokenize the normalized query on spaces. Empty query ⇒ no token filtering.
3. Keep an exercise when **every** token is a substring of
   `normalize(name + ' ' + equipment + ' ' + primaryMuscle + ' ' + secondaryMuscles.join(' '))`.

Substring, not prefix, not fuzzy — `'ench'` matches `'Bench Press'` upstream and
must keep matching here. Result order is manifest order and must stay stable.

Convenience wrappers, all built on `search`: `byEquipment`, `byPrimaryMuscle`,
`byExerciseType`, `stretches`.

## Asset paths

Assets are bundled under `assets/exercises/<slug>/frame-N.svg` and are reached
from a consumer app with the package-qualified key Flutter uses for assets
shipped by a package:

```
packages/workout_flutter_guide/assets/exercises/<slug>/frame-N.svg
```

- `ExerciseFrame.assetPath` — the key above, non-null, no lookup needed.
- `WorkoutGuide.assetPath(idOrSlug, frameIndex)` — same value; `null` when the
  exercise or the frame index is unknown. Mirrors upstream `getAssetUrl`'s
  null-on-miss contract.
- `WorkoutGuide.assetCdnUrl(idOrSlug, frameIndex, {baseUrl, version})` — pure
  string builder over the **upstream** `frame.path`, producing exactly what
  `getAssetUrl` produces, e.g.
  `https://cdn.jsdelivr.net/npm/@bryllim/workout-guide@1.0.0/assets/push-up/frame-2.svg`.
  No request is ever made by this package.
