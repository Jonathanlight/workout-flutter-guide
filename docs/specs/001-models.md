# 001 — Data model

Source of truth: `assets/manifest.json`, copied verbatim from upstream
`packages/workout-guide/manifest.json` (302 entries, 553 KB).

## Decisions

- **Hand-written immutable classes**, not `freezed`. The catalog is generated
  as `const` data; `freezed` would add a `build_runner` dependency, generated
  files we do not need, and would not make the constants any more readable.
  Every model therefore has: `const` constructor, `final` fields, `==`,
  `hashCode`, `toString`, and `fromJson`/`toJson`.
- **Enums keep upstream labels.** `ExerciseType.weightReps.label == 'weight_reps'`,
  `Equipment.pullUpBar.label == 'Pull-up Bar'`. Never normalize, never rename.
- **Unknown labels do not crash.** `fromLabel` throws `ArgumentError` (loud,
  for codegen), `tryFromLabel` returns `null` (lenient, for user input).
  Lookup is done on the normalized label, so `'pull up bar'` and `'Pull-up Bar'`
  both resolve.

## `ExerciseType`

Five values, from upstream `type ExerciseType`:

| Dart | label |
| --- | --- |
| `weightReps` | `weight_reps` |
| `bodyweightReps` | `bodyweight_reps` |
| `duration` | `duration` |
| `distanceDuration` | `distance_duration` |
| `assistedBodyweight` | `assisted_bodyweight` |

## `Equipment`

17 values observed in the manifest: Barbell, Bench, Bodyweight, Box, Cable,
Cardio, Chair, Doorway, Dumbbell, Kettlebell, Machine, Plate, Pull-up Bar,
Resistance Band, Stability Ball, Towel, Wall.

## `Muscle`

23 values. 20 appear as `primaryMuscle`: Adductors, Back, Biceps, Calves,
Chest, Core, Forearms, Glutes, Hamstrings, Hips, Lats, Legs, Lower Back,
Mobility, Posterior Chain, Quads, Rear Delts, Shoulders, Triceps, Upper Back.

Three more appear **only** in `secondaryMuscles` and must be part of the enum:
**Cardio**, **Grip**, **Groin**. (`Posterior Chain` is the mirror case: primary
only.) `Muscle.primaryValues` exposes the 20-value subset for filter UIs.

## `AttributionSource`

```dart
final String name;        // always 'Everkinetic'
final String url;         // e.g. .../dist/svg/0042-tension.svg
final String license;     // 'CC BY-SA 4.0'
final String licenseUrl;
final String changes;     // human-readable record of the modification
```

## `ExerciseAttribution`

```dart
final String creator;      // 'Bryl Lim'
final String creatorUrl;   // 'https://bryllim.com'
final String license;      // 'CC BY-SA 4.0'
final String licenseUrl;
final AttributionSource? source; // present on 76 of 906 frames
```

`source` is non-null exactly when the frame is a vector-traced adaptation of an
Everkinetic original. Stripping it is a licence violation; see
[ATTRIBUTION.md](../../ATTRIBUTION.md).

## `ExerciseFrame`

```dart
final int index;                     // 1 | 2 | 3
final String path;                   // upstream path: 'assets/<slug>/frame-N.svg'
final int width;                     // 512
final int height;                    // 512
final String format;                 // 'svg'
final ExerciseAttribution attribution;
```

`path` keeps the **upstream** value so the CDN URL builder stays byte-compatible
with `getAssetUrl`. The Flutter asset key is a separate, derived value
(`ExerciseFrame.assetPath`, see spec 002) because assets live under
`assets/exercises/<slug>/` here.

## `Exercise`

```dart
final String id;                   // 'exercise-<slug>'
final String slug;
final String name;
final ExerciseType exerciseType;
final Equipment equipment;
final Muscle primaryMuscle;
final List<Muscle> secondaryMuscles;  // unmodifiable
final bool isStretch;                 // true for 14 of 302
final List<ExerciseFrame> frames;     // exactly 3, ordered 1,2,3, unmodifiable
final ExerciseAttribution attribution;
```

Invariants, enforced by tests:

- `id == 'exercise-$slug'` for all 302 entries.
- `frames.length == 3` and `frames[i].index == i + 1`.
- `attribution == frames.first.attribution` (verified true across the manifest).
- ids and slugs are unique.

Convenience accessors: `startFrame`, `midFrame`, `endFrame`, and
`frame(int index)` which throws `RangeError` outside 1..3.
