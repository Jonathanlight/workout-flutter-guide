# Attribution

The original pose artwork used by Workout Guide comes from
[Everkinetic](https://github.com/everkinetic/data), licensed under
[CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/).

[Bryl Lim](https://bryllim.com) expanded upon that foundation with additional
exercises and animation frames, normalized transparent 512 × 512 assets,
structured metadata, package APIs, and the documentation gallery. Seventy-six
first-pose frames are vector-traced adaptations of rasterized Everkinetic SVGs;
their exact source URLs and recorded changes are retained in
`assets/manifest.json` and are queryable at runtime through
`exercise.attribution.source` and `exercise.frames[i].attribution.source`.

The Flutter port is by [Jonathan KABLAN](https://github.com/Jonathanlight). It
is an unaffiliated community port of
[`@bryllim/workout-guide`](https://github.com/bryllim/workout-guide) v1.0.0.

## Changes made by this port

The SVG assets are redistributed **byte-for-byte identical** to upstream
v1.0.0. No recoloring, retouching, resizing or re-optimization was applied.
The only change to the distributed material is its location on disk:
`assets/<slug>/frame-N.svg` upstream becomes
`assets/exercises/<slug>/frame-N.svg` here, so that Flutter's asset bundler can
declare one directory per exercise.

`assets/manifest.json` is copied verbatim from upstream, including every
`attribution` object. `lib/src/generated/catalog.g.dart` is a mechanical
transcription of that manifest into Dart constants; the attribution data is
carried over in full.

Should a frame ever need to be modified (for example to work around a renderer
limitation), the change must be recorded in this section, and the modified
asset stays under CC BY-SA 4.0.

## Attribution you must display

If you ship this package in an application, you must credit the asset authors
in a place your users can reach (an About or Licenses screen is the usual
place). The `WorkoutGuideAttribution` widget renders a compliant credit block
for you. The equivalent plain text is:

> Exercise illustrations by Bryl Lim (https://bryllim.com), based on artwork by
> Everkinetic (https://github.com/everkinetic/data), licensed under CC BY-SA 4.0
> (https://creativecommons.org/licenses/by-sa/4.0/).
