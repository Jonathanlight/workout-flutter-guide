# 000 — Overview

`workout_flutter_guide` is a Flutter/Dart port of
[`@bryllim/workout-guide`](https://github.com/bryllim/workout-guide) v1.0.0.
It ships the upstream catalog (302 exercises) and the upstream artwork
(906 SVG frames, 3 per exercise) as a Flutter asset package, plus a typed,
synchronous, offline API that mirrors the upstream JavaScript API.

## Goals

1. **API parity.** `getExercise`, `search`, `normalizeSearchText` and the CDN
   URL builder behave exactly like upstream, so upstream tests port 1:1 and
   upstream documentation examples translate mechanically.
2. **Offline first.** No network, no `rootBundle` JSON decoding, no async
   initialization. The catalog is a Dart constant; `WorkoutGuide.exercises` is
   available synchronously from the first frame.
3. **License-correct.** Code is MIT, artwork stays CC BY-SA 4.0, attribution
   data survives the port intact and is queryable at runtime.
4. **pub.dev 160/160.** Documented public API, example app, declared
   platforms, no analyzer diagnostics.

## Non-goals

- No PNG variants (upstream keeps them for compatibility; +31 MB).
- No workout/session/logging domain model. This package is a *catalog*.
- No analytics, no platform channels, no network calls.
- No re-styling of the artwork inside the assets. Tinting is a render-time
  concern (`ColorFilter`), never an edit to the SVG files.

## Deliverables

| # | Spec | Covers |
| --- | --- | --- |
| 001 | [Data model](./001-models.md) | `Exercise`, `ExerciseFrame`, attribution, enums |
| 002 | [Catalog API](./002-catalog-api.md) | lookup, search, normalization, asset paths |
| 003 | [Widgets](./003-widgets.md) | frame image, animation, attribution block |
| 004 | [Tooling](./004-tooling.md) | import, codegen, validation |

## Vocabulary

- **Frame** — one of the three poses of an exercise, indexed 1, 2, 3.
  Frame 1 is the start pose, 2 the mid pose, 3 the end pose.
- **Slug** — the kebab-case identifier of an exercise (`bench-press`), also
  its asset directory name.
- **Id** — `exercise-<slug>`. Kept for upstream parity.
