import 'dart:async';

import 'package:flutter/widgets.dart';

import '../models/exercise.dart';
import 'exercise_frame_image.dart';

/// Animates an [Exercise] by cycling its three frames.
///
/// ```dart
/// ExerciseAnimation(
///   exercise: WorkoutGuide.getExercise('push-up')!,
///   frameDuration: const Duration(milliseconds: 400),
///   size: 200,
///   color: Colors.black87,
/// )
/// ```
///
/// The three frames are all built on the first pass, so the loop does not
/// flicker while an asset decodes. The timer is cancelled as soon as the
/// widget leaves the tree.
class ExerciseAnimation extends StatefulWidget {
  /// Cycles the frames of [exercise] every [frameDuration].
  const ExerciseAnimation({
    required this.exercise,
    super.key,
    this.frameDuration = const Duration(milliseconds: 500),
    this.playing = true,
    this.size,
    this.color,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.semanticLabel,
    this.placeholder,
    this.respectReducedMotion = true,
    this.bundle,
  }) : assert(
          frameDuration > Duration.zero,
          'frameDuration must be positive',
        );

  /// The exercise to animate.
  final Exercise exercise;

  /// How long each frame is held.
  final Duration frameDuration;

  /// Whether the animation runs.
  ///
  /// When false the widget shows the start frame and holds it.
  final bool playing;

  /// The width and height to draw at.
  final double? size;

  /// Tints the artwork with [BlendMode.srcIn].
  ///
  /// See [ExerciseFrameImage.color]: the assets are white.
  final Color? color;

  /// How to inscribe the artwork into [size].
  final BoxFit fit;

  /// How to align the artwork within its box.
  final AlignmentGeometry alignment;

  /// The label read by screen readers.
  ///
  /// Defaults to the exercise name. The individual frames are hidden from
  /// assistive technologies so the label does not change three times a second.
  final String? semanticLabel;

  /// Shown while the SVGs are being decoded.
  final Widget? placeholder;

  /// Whether to hold a still frame when the platform asks for reduced motion.
  ///
  /// Looping artwork is exactly what `MediaQuery.disableAnimations` is meant
  /// to suppress. Set to false only if the movement is the content itself and
  /// there is no other way to convey it.
  final bool respectReducedMotion;

  /// The bundle to load the assets from.
  ///
  /// Defaults to the app's [rootBundle]. Mostly useful in tests.
  final AssetBundle? bundle;

  @override
  State<ExerciseAnimation> createState() => _ExerciseAnimationState();
}

class _ExerciseAnimationState extends State<ExerciseAnimation> {
  static const int _frameCount = 3;

  Timer? _timer;
  int _frameIndex = 0;
  bool _reducedMotion = false;

  @override
  void initState() {
    super.initState();
    _restart();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduced != _reducedMotion) {
      _reducedMotion = reduced;
      _restart();
    }
  }

  @override
  void didUpdateWidget(ExerciseAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercise != widget.exercise ||
        oldWidget.frameDuration != widget.frameDuration ||
        oldWidget.playing != widget.playing ||
        oldWidget.respectReducedMotion != widget.respectReducedMotion) {
      _restart();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _shouldPlay =>
      widget.playing && !(widget.respectReducedMotion && _reducedMotion);

  /// Rewinds to the start frame and, if the animation should run, restarts
  /// the ticker.
  ///
  /// Always rewinding is what makes a change of exercise -- or a pause --
  /// begin the movement again rather than resume it mid-rep.
  void _restart() {
    _timer?.cancel();
    _timer = null;
    if (_frameIndex != 0 && mounted) {
      setState(() => _frameIndex = 0);
    } else {
      _frameIndex = 0;
    }
    if (!_shouldPlay) return;
    _timer = Timer.periodic(widget.frameDuration, (_) {
      setState(() => _frameIndex = (_frameIndex + 1) % _frameCount);
    });
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.semanticLabel ?? widget.exercise.name;
    return Semantics(
      label: label.isEmpty ? null : label,
      image: true,
      child: IndexedStack(
        // Building all three keeps every frame decoded and cached, so the
        // first loop is as smooth as the tenth.
        index: _frameIndex,
        alignment: widget.alignment,
        sizing: StackFit.passthrough,
        children: <Widget>[
          for (var frame = 1; frame <= _frameCount; frame++)
            ExerciseFrameImage(
              exercise: widget.exercise,
              frame: frame,
              size: widget.size,
              color: widget.color,
              fit: widget.fit,
              alignment: widget.alignment,
              semanticLabel: '',
              placeholder: widget.placeholder,
              bundle: widget.bundle,
            ),
        ],
      ),
    );
  }
}
