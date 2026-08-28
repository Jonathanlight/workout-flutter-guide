# workout_flutter_guide

302 exercises, 906 illustration frames, and a typed catalog to query them —
all offline, all in your app bundle.

A Flutter port of [`@bryllim/workout-guide`](https://github.com/bryllim/workout-guide)
by Bryl Lim. Unaffiliated community port.

```dart
final pushUp = WorkoutGuide.getExercise('push-up')!;
final chest = WorkoutGuide.search('chest', equipment: Equipment.bodyweight);

ExerciseAnimation(exercise: pushUp, size: 200, color: Colors.black87);
```

---

## ⚖️ Licensing — read this before you ship

This package is **dual-licensed**, and the artwork is the strict half.

| What | License |
| --- | --- |
| The Dart code | [MIT](LICENSE) |
| The 906 SVG frames and their metadata | [CC BY-SA 4.0](LICENSE-ASSETS) |

**CC BY-SA 4.0 means your app must display the attribution.** Put it on an
About or Licenses screen — that is the whole obligation, and it takes one
widget:

```dart
const WorkoutGuideAttribution();
```

or, if your app already has a licenses page:

```dart
void main() {
  WorkoutGuide.registerLicenses(); // shows up in showLicensePage()
  runApp(const MyApp());
}
```

The plain-text version, ready to paste:

> Exercise illustrations by Bryl Lim (https://bryllim.com), based on artwork by
> Everkinetic (https://github.com/everkinetic/data), licensed under CC BY-SA 4.0
> (https://creativecommons.org/licenses/by-sa/4.0/).

ShareAlike also means: if you modify the SVG files, your modified files stay
CC BY-SA 4.0 and you must say what you changed. Tinting them at render time
(the `color` argument below) is *not* a modification — it does not touch the
files. See [LICENSES.md](LICENSES.md) and [ATTRIBUTION.md](ATTRIBUTION.md).

---

## Install

```yaml
dependencies:
  workout_flutter_guide: ^0.1.0
```

No setup, no initialization, no asset declarations of your own. The catalog is
compiled in as Dart constants, so it is there synchronously on the first frame.

## The catalog

```dart
import 'package:workout_flutter_guide/workout_flutter_guide.dart';

WorkoutGuide.exercises;                       // all 302, unmodifiable
WorkoutGuide.getExercise('push-up');          // by slug
WorkoutGuide.getExercise('exercise-push-up'); // or by id -- null if unknown
WorkoutGuide.stretches;                       // the 14 stretches
```

### Search

Every token of the query must appear somewhere in the exercise's name,
equipment, primary muscle or secondary muscles. Matching ignores case,
punctuation and accents.

```dart
WorkoutGuide.search('incline dumbbell');
WorkoutGuide.search('press', equipment: Equipment.dumbbell);
WorkoutGuide.search('', primaryMuscle: [Muscle.lats, Muscle.upperBack]);
WorkoutGuide.search('', isStretch: true);

// String labels work too, so upstream JavaScript examples port as-is:
WorkoutGuide.search('press', equipment: 'Dumbbell', primaryMuscle: 'Shoulders');
```

Values inside one filter are ORed; different filters are ANDed. Results keep
catalog order. Shorthands: `byEquipment`, `byPrimaryMuscle`, `byExerciseType`.

### An exercise

```dart
final e = WorkoutGuide.getExercise('bench-press')!;

e.name;              // 'Bench Press'
e.equipment;         // Equipment.barbell      -> .label == 'Barbell'
e.primaryMuscle;     // Muscle.chest
e.secondaryMuscles;  // [Muscle.triceps, Muscle.shoulders]
e.exerciseType;      // ExerciseType.weightReps -> .label == 'weight_reps'
e.isStretch;         // false
e.frames;            // 3 frames: start, mid, end
e.assetPath(1);      // packages/workout_flutter_guide/assets/.../frame-1.svg
```

The enums keep the upstream strings in `.label`, and `Equipment.fromLabel`,
`Muscle.fromLabel` and `ExerciseType.fromLabel` read them back.

## The widgets

```dart
// One pose.
ExerciseFrameImage(exercise: e, frame: 1, size: 160, color: Colors.black87);

// The movement, cycling 1 -> 2 -> 3.
ExerciseAnimation(
  exercise: e,
  frameDuration: const Duration(milliseconds: 400),
  size: 200,
  color: Colors.black87,
);

// The credit block you owe the artists.
WorkoutGuideAttribution(onLinkTap: (url) => launchUrlString(url));
```

**About `color`:** the artwork is drawn in **white** on a transparent
background, because upstream targets dark surfaces. On a light background it is
invisible unless you pass a colour — `Theme.of(context).colorScheme.onSurface`
is usually the right one. The widgets will not pick one for you, because a
widget that silently recolours artwork is a surprise you would rather not
debug.

`ExerciseAnimation` mounts all three frames up front (no flicker on the first
loop), cancels its timer when it leaves the tree, and holds a still frame when
the platform asks for reduced motion.

## Serving the artwork from a CDN

The bundled assets are the offline default, but the upstream jsDelivr URLs are
one call away — a pure string builder, no network access from this package:

```dart
WorkoutGuide.assetCdnUrl('push-up', 2);
// https://cdn.jsdelivr.net/npm/@bryllim/workout-guide@1.0.0/assets/push-up/frame-2.svg
```

Be aware of the trade-off: the SVGs are declared in this package's
`pubspec.yaml`, so they ship with your app whether or not you use the CDN.
Flutter gives a consumer no way to opt out of a dependency's assets. Use the
CDN when you want the artwork cached and shared across clients, not to shrink
your bundle.

## Attribution metadata is queryable

The per-frame provenance survives the port, because CC BY-SA requires it to:

```dart
final source = e.frames.first.attribution.source;
source?.name;    // 'Everkinetic'
source?.url;     // the exact upstream file
source?.changes; // what was changed, in words
```

76 of the 906 frames are vector-traced adaptations of Everkinetic drawings and
carry a `source`; the other 830 were drawn from scratch by Bryl Lim.

## Parity with upstream

The upstream test suite is ported 1:1, and the generated catalog is compared
entry-by-entry against `manifest.json` in both directions. Search normalization
matches the JavaScript exactly — including its rough edges, verified against
524 golden cases generated by running the original code.

| Upstream | Here |
| --- | --- |
| `exercises` | `WorkoutGuide.exercises` |
| `getExercise(idOrSlug)` | `WorkoutGuide.getExercise(idOrSlug)` |
| `searchExercises(query, filters)` | `WorkoutGuide.search(query, ...)` |
| `normalizeSearchText(value)` | `normalizeSearchText(value)` |
| `getAssetUrl(id, frame, opts)` | `WorkoutGuide.assetCdnUrl(id, frame, ...)` |
| — | `WorkoutGuide.assetPath(id, frame)` (local asset) |

## Example

`example/` is a runnable gallery: searchable grid, equipment and muscle
filters, a detail page with the animation, and an About screen showing the
attribution done properly.

```sh
cd example && flutter run
```

## Credits

Artwork by [Everkinetic](https://github.com/everkinetic/data) and
[Bryl Lim](https://bryllim.com), CC BY-SA 4.0. Catalog from
[`@bryllim/workout-guide`](https://github.com/bryllim/workout-guide) v1.0.0.
Flutter port by [Jonathan KABLAN](https://github.com/Jonathanlight).
