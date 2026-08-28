# workout_flutter_guide example

A gallery for the catalog: search across 302 exercises, filter by equipment or
muscle, open an exercise to watch the three poses loop, and read the credits on
the About screen.

```sh
flutter run
```

What it demonstrates, and why each bit is there:

- `WorkoutGuide.search(query, equipment: ..., primaryMuscle: ..., isStretch: ...)`
  driving a grid that stays responsive because the catalog is in memory.
- `ExerciseFrameImage` with `color:` — the artwork is white, so a light theme
  needs a tint. `Theme.of(context).colorScheme.onSurface` is the usual choice.
- `ExerciseAnimation` with play/pause and an adjustable frame duration.
- `WorkoutGuideAttribution` on the About screen and
  `WorkoutGuide.registerLicenses()` in `main()` — either satisfies the
  CC BY-SA 4.0 attribution requirement; this app does both to show them off.
- `Exercise.attribution.source`, shown on the detail page for the 76 poses
  adapted from Everkinetic artwork.

Links are copied to the clipboard rather than opened: neither the package nor
this example takes a `url_launcher` dependency.
