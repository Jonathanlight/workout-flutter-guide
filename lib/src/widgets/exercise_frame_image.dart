import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/exercise.dart';

/// Draws one frame of an [Exercise].
///
/// ```dart
/// ExerciseFrameImage(
///   exercise: WorkoutGuide.getExercise('push-up')!,
///   frame: 1,
///   size: 160,
///   color: Colors.black87,
/// )
/// ```
///
/// The artwork is white on a transparent background, because upstream draws
/// it for dark surfaces. On a light surface pass a [color]: it is applied as a
/// render-time [ColorFilter] and never touches the asset itself.
class ExerciseFrameImage extends StatelessWidget {
  /// Draws frame [frame] of [exercise].
  const ExerciseFrameImage({
    required this.exercise,
    super.key,
    this.frame = 1,
    this.size,
    this.color,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.semanticLabel,
    this.placeholder,
    this.bundle,
  }) : assert(
          frame >= 1 && frame <= 3,
          'frame must be 1, 2 or 3, got $frame',
        );

  /// The exercise to draw.
  final Exercise exercise;

  /// Which of the three poses to draw: 1 (start), 2 (mid) or 3 (end).
  final int frame;

  /// The width and height to draw at.
  ///
  /// The artwork is square. When null, the widget fills the space its parent
  /// gives it.
  final double? size;

  /// Tints the artwork with [BlendMode.srcIn].
  ///
  /// The assets are white; without a colour they are invisible on a light
  /// background. `Theme.of(context).colorScheme.onSurface` is a good default
  /// for an app, but this widget will not pick one for you.
  final Color? color;

  /// How to inscribe the artwork into [size].
  final BoxFit fit;

  /// How to align the artwork within its box.
  final AlignmentGeometry alignment;

  /// The label read by screen readers.
  ///
  /// Defaults to the exercise name. Pass an empty string to hide the image
  /// from assistive technologies, for instance when a caption already names
  /// the exercise.
  final String? semanticLabel;

  /// Shown while the SVG is being decoded.
  ///
  /// Decoding a bundled asset takes a frame or two; without a placeholder the
  /// space is simply empty until then.
  final Widget? placeholder;

  /// The bundle to load the asset from.
  ///
  /// Defaults to the app's [rootBundle]. Mostly useful in tests.
  final AssetBundle? bundle;

  @override
  Widget build(BuildContext context) {
    final label = semanticLabel ?? exercise.name;
    final placeholderWidget = placeholder;
    return SvgPicture.asset(
      exercise.assetPath(frame),
      bundle: bundle,
      width: size,
      height: size,
      fit: fit,
      alignment: alignment,
      colorFilter:
          color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
      semanticsLabel: label.isEmpty ? null : label,
      excludeFromSemantics: label.isEmpty,
      placeholderBuilder:
          placeholderWidget == null ? null : (_) => placeholderWidget,
    );
  }
}
