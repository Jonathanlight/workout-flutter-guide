# CLAUDE.md — workout-flutter-guide

Flutter/Dart port of [@bryllim/workout-guide](https://github.com/bryllim/workout-guide)
(302 exercises × 3 frames = 906 SVG illustrations + typed catalog API), published on pub.dev.

- Repository: `workout-flutter-guide`
- Dart package name: `workout_flutter_guide`
- Author: Jonathan KABLAN
- Upstream: bryllim/workout-guide v1.0.0 (Bryl Lim) — this is an **unaffiliated community port**.

Language rules: talk to me in French; all code, identifiers, comments, commits and docs are in English.

---

## 1. Licensing — READ FIRST, NON-NEGOTIABLE

The upstream project is dual-licensed. The port MUST keep the split intact.

| Scope | License | Our obligation |
|---|---|---|
| Upstream code (`src/index.ts`, `types.ts`, scripts) | MIT | Keep Bryl Lim's copyright notice. Our Dart code may be MIT or BSD-3. |
| 906 SVG assets + `manifest.json` metadata | CC BY-SA 4.0 | Attribution to **Everkinetic** (original poses) and **Bryl Lim** (extra exercises, frames, normalization). ShareAlike: assets and any derivative stay CC BY-SA 4.0. Never relicense them. |

Hard rules:
- `LICENSE` = MIT (our code) + upstream MIT notice appended.
- `LICENSE-ASSETS` = full CC BY-SA 4.0 text.
- `ATTRIBUTION.md` = copy upstream attribution, add "Flutter port by Jonathan KABLAN".
- `LICENSES.md` = human-readable breakdown (mirror upstream).
- README must state clearly, near the top, that assets are CC BY-SA 4.0 and that **consumers must display attribution in their app** (e.g. About/Licenses screen). Provide a ready-to-paste attribution string and a `WorkoutGuideAttribution` widget.
- Never modify SVG content (recolor, retouch) without recording the change; any modified asset is itself CC BY-SA 4.0.
- Keep the per-exercise `attribution` object from the manifest in the Dart model — it carries Everkinetic source URLs and recorded changes for 76 frames.
- Ship SVG only. Do **not** bundle the PNG variants (upstream keeps them for compat; they add ~31 MB).

---

## 2. Upstream API to reproduce (source of truth)

Manifest: `packages/workout-guide/manifest.json` — a JSON array of 302 `Exercise` objects.

```ts
type ExerciseType = 'weight_reps' | 'bodyweight_reps' | 'duration' | 'distance_duration' | 'assisted_bodyweight';

type Exercise = {
  id: string;               // "exercise-bench-press"
  slug: string;             // "bench-press"
  name: string;             // "Bench Press"
  exerciseType: ExerciseType;
  equipment: string;        // 17 values: Barbell, Bench, Bodyweight, Box, Cable, Cardio, Chair, Doorway,
                            //   Dumbbell, Kettlebell, Machine, Plate, Pull-up Bar, Resistance Band,
                            //   Stability Ball, Towel, Wall
  primaryMuscle: string;    // 20 values: Adductors, Back, Biceps, Calves, Chest, Core, Forearms, Glutes,
                            //   Hamstrings, Hips, Lats, Legs, Lower Back, Mobility, Posterior Chain,
                            //   Quads, Rear Delts, Shoulders, Triceps, Upper Back
  secondaryMuscles: string[];
  isStretch: boolean;
  frames: [ExerciseFrame, ExerciseFrame, ExerciseFrame]; // index 1|2|3, path "assets/<slug>/frame-N.svg", 512×512
  attribution: ExerciseAttribution;
};

type ExerciseAttribution = {
  creator: 'Bryl Lim'; creatorUrl; license: 'CC BY-SA 4.0'; licenseUrl;
  source?: { name: 'Everkinetic'; url; license; licenseUrl; changes: string };
};
```

Upstream functions (`src/index.ts`):
- `exercises` — the full list.
- `getExercise(idOrSlug)` — lookup by id first, then slug; `null` if missing.
- `searchExercises(query = '', filters)` — filters: `equipment`, `primaryMuscle`, `exerciseType` (string or list, matched after normalization), `isStretch`. Query is tokenized; every token must appear in the normalized concat of `name + equipment + primaryMuscle + secondaryMuscles`.
- `normalizeSearchText(value)` — lowercase, strip diacritics (NFD), `&` → `and`, non-alphanumerics → single space, trim.
- `getAssetUrl(idOrSlug, frameIndex, { baseUrl?, version? })` — builds a jsDelivr CDN URL. In Flutter we replace this with a **local asset path** helper and keep a CDN variant as an optional secondary.

Reproduce these semantics exactly (same normalization, same filter logic) so results match upstream and its tests can be ported 1:1.

---

## 3. Target Dart API

```dart
import 'package:workout_flutter_guide/workout_flutter_guide.dart';

final pushUp = WorkoutGuide.getExercise('push-up');           // Exercise?
final chest  = WorkoutGuide.search('chest', equipment: 'Bodyweight'); // List<Exercise>
final all    = WorkoutGuide.exercises;                        // List<Exercise> (unmodifiable)

// Local asset path, ready for flutter_svg
final path = WorkoutGuide.assetPath('push-up', 1);
// => 'packages/workout_flutter_guide/assets/exercises/push-up/frame-1.svg'

// Widgets
ExerciseFrameImage(exercise: pushUp!, frame: 1, size: 160);
ExerciseAnimation(exercise: pushUp!, frameDuration: Duration(milliseconds: 400)); // cycles 1→2→3
WorkoutGuideAttribution();                                    // CC BY-SA credit block for About screens
```

Models: `Exercise`, `ExerciseFrame`, `ExerciseAttribution`, `AttributionSource`, enums `ExerciseType`, `Equipment`, `Muscle` (with `fromLabel()` / `label` keeping upstream string values). Use `freezed` + `json_serializable` **only if** the generated code stays readable; otherwise hand-written immutable classes with `==`/`hashCode`. No runtime JSON parsing on every access: the catalog is generated into a Dart constant (`lib/src/generated/catalog.g.dart`) so `exercises` is available synchronously without `rootBundle`.

Search API mirrors upstream but uses named parameters:
```dart
static List<Exercise> search(
  String query, {
  Object? equipment,      // String | Equipment | Iterable of either
  Object? primaryMuscle,  // String | Muscle | Iterable
  Object? exerciseType,   // ExerciseType | Iterable<ExerciseType>
  bool? isStretch,
});
```
Prefer typed overloads if `Object?` feels sloppy — but keep the string form so ports of upstream examples work.

---

## 4. Repository layout

```
workout-flutter-guide/
├── CLAUDE.md
├── README.md                 # pub.dev landing page, licensing block near the top
├── CHANGELOG.md
├── LICENSE                   # MIT (ours + upstream notice)
├── LICENSE-ASSETS            # CC BY-SA 4.0
├── LICENSES.md
├── ATTRIBUTION.md
├── pubspec.yaml
├── analysis_options.yaml     # very_good_analysis or flutter_lints strict
├── assets/
│   ├── manifest.json         # copied verbatim from upstream (source of truth for codegen)
│   └── exercises/<slug>/frame-{1,2,3}.svg   # 906 files, ~26 MB
├── lib/
│   ├── workout_flutter_guide.dart          # barrel export
│   └── src/
│       ├── models/           # exercise.dart, exercise_frame.dart, attribution.dart, enums.dart
│       ├── catalog/          # workout_guide.dart (getExercise/search/assetPath), text_normalizer.dart
│       ├── widgets/          # exercise_frame_image.dart, exercise_animation.dart, attribution_widget.dart
│       └── generated/        # catalog.g.dart (DO NOT EDIT — run tool/generate_catalog.dart)
├── tool/
│   ├── import_upstream.dart  # copies manifest + SVGs from a local upstream checkout
│   ├── generate_catalog.dart # manifest.json → catalog.g.dart
│   └── validate_assets.dart  # 302×3 files exist, every SVG parses with flutter_svg, sizes 512×512
├── test/                     # unit tests ported from upstream packages/workout-guide/test + widget tests
└── example/                  # runnable gallery app (grid, search, filters, detail page with animation)
```

---

## 5. Stack and constraints

- Flutter ≥ 3.24, Dart ≥ 3.5. SDK constraint in pubspec: `sdk: ^3.5.0`.
- Dependencies: `flutter_svg` only (runtime). Dev: `flutter_lints`/`very_good_analysis`, `test`, `path`, optionally `build_runner` if codegen packages are used.
- The `assets:` section in `pubspec.yaml` must list the `assets/exercises/` directory per slug (Flutter does not glob recursively). `tool/generate_catalog.dart` also regenerates that pubspec block — never edit it by hand.
- Vector-traced SVGs can be path-heavy. `validate_assets.dart` must load each SVG through `flutter_svg`'s parser and fail on unsupported elements. If any file fails, fix the SVG in `assets/` and record the change in `ATTRIBUTION.md` (ShareAlike).
- Keep the published archive well under pub.dev's 100 MB limit. Exclude `example/build`, PNGs, and upstream site files via `.pubignore`.
- No network calls in the package. `assetCdnUrl()` (jsDelivr fallback, upstream-compatible) is a pure string builder.
- `web` must work (flutter_svg supports it); no `dart:io` in `lib/`.

---

## 6. Quality gates (must pass before any commit)

```
dart format --set-exit-if-changed .
flutter analyze            # zero warnings, zero infos
flutter test               # unit + widget tests
dart run tool/validate_assets.dart
dart pub publish --dry-run # zero warnings
```

Target pub.dev score: 160/160. That means: documentation on every public symbol (`public_member_api_docs`), example app present, platforms declared, no outdated deps, `CHANGELOG.md` and `README.md` present.

Tests to port from upstream (`packages/workout-guide/test/`): lookup by id and slug, unknown returns null, normalization cases (diacritics, `&`), token search AND semantics, each filter individually and combined, `isStretch`, exact count 302 and 3 frames each, every frame path exists.

---

## 7. Workflow

1. **Spec first.** Before writing code for a new feature, write/update the relevant `docs/specs/*.md` (BMAD style). CLAUDE.md is the contract; specs are the detail.
2. Import upstream: `dart run tool/import_upstream.dart /path/to/bryllim/workout-guide` (copies `manifest.json` + `frame-*.svg` only). Commit assets in a dedicated commit: `chore(assets): import upstream v1.0.0 catalog`.
3. Generate: `dart run tool/generate_catalog.dart`.
4. Implement models → catalog API → widgets → example app, each with tests.
5. Conventional commits (`feat:`, `fix:`, `chore:`, `docs:`, `test:`). Small commits, one concern each.
6. Versioning: start at `0.1.0`; go `1.0.0` when API parity with upstream is complete and the pub score is maxed. Record the upstream catalog version in `CHANGELOG.md` (`Catalog: bryllim/workout-guide 1.0.0`).
7. Before publishing: run all gates, verify the README licensing block, verify `WorkoutGuideAttribution` renders, then `dart pub publish`.

---

## 8. Do / Don't

Do:
- Keep upstream string values (`"Pull-up Bar"`, `"weight_reps"`) untouched in the manifest and enum labels.
- Keep per-frame attribution data queryable (`exercise.frames[0].attribution.source?.url`).
- Document, in the README, the exact attribution consumers must display and link to `LICENSE-ASSETS`.
- Open an issue on the upstream repo once published to announce the port (courtesy, and they may link it in their integration guide).

Don't:
- Don't rename the package to anything implying official status (no `bryllim_*`, no `workout_guide` alone).
- Don't bundle PNGs, upstream Astro site, or upstream scripts.
- Don't add analytics, network fetches, or platform channels.
- Don't hand-edit `lib/src/generated/` or the assets block of `pubspec.yaml`.
- Don't strip or "clean" attribution metadata from the manifest to save bytes.
