# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses
[semantic versioning](https://semver.org/spec/v2.0.0.html).

## 0.1.1

No user-facing change. Catalog: bryllim/workout-guide 1.0.0.

The published archive is identical to 0.1.0: the only change since that
release is the GitHub Actions publishing workflow, which `.pubignore` keeps
out of the package. This version exists to exercise the automated release
pipeline end to end.

## 0.1.0

First release. Catalog: bryllim/workout-guide 1.0.0.

### Added

- **Catalog API.** `WorkoutGuide.exercises`, `getExercise`, `search` with
  equipment / primary muscle / exercise type / stretch filters, plus the
  `byEquipment`, `byPrimaryMuscle`, `byExerciseType` and `stretches`
  shorthands. Everything is static, synchronous and offline: the 302 exercises
  are compiled in as Dart constants, so there is no `rootBundle` read and
  nothing to await.
- **Assets.** All 906 SVG frames (302 exercises × 3 poses, 512 × 512),
  redistributed unmodified from upstream and reachable through
  `Exercise.assetPath(index)` or `ExerciseFrame.assetPath`. PNG variants are
  not bundled.
- **Widgets.** `ExerciseFrameImage` for a single pose, `ExerciseAnimation` for
  the 1 → 2 → 3 loop (reduced-motion aware), and `WorkoutGuideAttribution` for
  the CC BY-SA credit block.
- **Models.** `Exercise`, `ExerciseFrame`, `ExerciseAttribution`,
  `AttributionSource`, and the `ExerciseType`, `Equipment` and `Muscle` enums,
  all immutable, all keeping the upstream string labels.
- **Upstream parity.** `normalizeSearchText` reproduces the upstream
  JavaScript exactly, `WorkoutGuide.assetCdnUrl` builds the same jsDelivr URLs
  as `getAssetUrl`, and the upstream test suite is ported 1:1.
- **Licensing.** MIT for the code, CC BY-SA 4.0 for the artwork, with the
  per-frame Everkinetic provenance kept queryable at run time and
  `WorkoutGuide.registerLicenses()` to surface the credit in
  `showLicensePage`.
- **Example.** A gallery app with search, filters, a detail page and an About
  screen.
