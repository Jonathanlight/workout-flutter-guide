# 003 — Widgets

Three widgets, all `const`-constructible, all pure Flutter + `flutter_svg`.

## `ExerciseFrameImage`

Renders one frame.

```dart
ExerciseFrameImage(
  exercise: pushUp,
  frame: 1,                    // 1..3, asserted
  size: 160,                   // shorthand for width == height
  color: Colors.black87,       // optional tint
  fit: BoxFit.contain,
  semanticLabel: null,         // defaults to '<name>, frame N of 3'
  placeholder: ...,            // shown while the SVG decodes
)
```

The artwork is drawn with `fill="#fff"`, i.e. **white**, because upstream
targets dark surfaces. On a light background it would be invisible, so `color`
applies `ColorFilter.mode(color, BlendMode.srcIn)` at render time. This tints
the rendered pixels only; the asset files are never modified, so no ShareAlike
obligation is triggered. When `color` is null the artwork is drawn as-is.

`Theme.of(context).colorScheme.onSurface` is *not* used as an implicit default:
a widget that silently recolours artwork is surprising. Callers opt in.

## `ExerciseAnimation`

Cycles frames 1 → 2 → 3 → 1 with a `Timer.periodic`.

```dart
ExerciseAnimation(
  exercise: pushUp,
  frameDuration: Duration(milliseconds: 400),
  playing: true,
  size: 200,
  color: null,
)
```

Requirements:

- All three frames are precached on the first build so the loop does not
  flicker on its first pass.
- The timer is cancelled in `dispose`, and restarted in `didUpdateWidget` when
  `frameDuration`, `playing` or `exercise` changes.
- `playing: false` freezes on frame 1.
- Honours `MediaQuery.disableAnimations` (accessibility): when the platform
  asks for reduced motion, the widget shows a still frame 1 unless the caller
  passes `respectReducedMotion: false`.

## `WorkoutGuideAttribution`

The credit block consumers must display to satisfy CC BY-SA 4.0. Renders the
creators, the licence, and the "based on Everkinetic" line, with tappable
links routed through an optional `onLinkTap` callback (the package takes no
`url_launcher` dependency; if `onLinkTap` is null, links render as plain text).

`WorkoutGuideAttribution.plainText` exposes the same credit as a `String`, for
apps that build their own licences screen or need it in a `LicenseRegistry`
entry.

The package also registers its licences with `LicenseRegistry` through
`WorkoutGuide.registerLicenses()`, so `showLicensePage` surfaces both the MIT
and the CC BY-SA 4.0 notices. Calling it is optional and idempotent.
