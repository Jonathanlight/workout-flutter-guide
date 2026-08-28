# Licensing

`workout_flutter_guide` uses separate licenses for software and visual assets.
Both apply to every copy you redistribute.

| Scope | License | File |
| --- | --- | --- |
| Dart/Flutter source code, tooling and documentation | MIT | [LICENSE](./LICENSE) |
| The 906 SVG exercise frames in `assets/exercises/` and the metadata in `assets/manifest.json` | CC BY-SA 4.0 | [LICENSE-ASSETS](./LICENSE-ASSETS) |

The Dart code is a community port of [`@bryllim/workout-guide`](https://github.com/bryllim/workout-guide)
(MIT, Copyright (c) 2026 Bryl Lim). The upstream copyright notice is retained in
[LICENSE](./LICENSE).

The visual assets are redistributed unmodified from upstream. They remain under
CC BY-SA 4.0: if you ship them, you must credit the creators, link to the
license, indicate changes, and license any adaptation under the same terms.
Upstream attribution for the 76 derived first-pose frames is recorded in
[ATTRIBUTION.md](./ATTRIBUTION.md) and, per frame, in `assets/manifest.json`
(reachable at runtime through `exercise.frames[i].attribution.source`).

This package is an **unaffiliated community port**. It is not endorsed by
Bryl Lim or Everkinetic.
