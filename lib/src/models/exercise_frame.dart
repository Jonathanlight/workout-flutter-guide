import 'attribution.dart';

/// The asset key prefix Flutter uses for assets shipped inside this package.
const String _packageAssetPrefix = 'packages/workout_flutter_guide/';

/// The `assets/` prefix used by the upstream manifest paths.
const String _upstreamAssetPrefix = 'assets/';

/// The directory this port stores exercise artwork under.
const String _portAssetPrefix = 'assets/exercises/';

/// One of the three poses of an exercise.
///
/// Frames are ordered: [index] 1 is the start pose, 2 the mid pose, 3 the end
/// pose. Playing them in order animates the movement; see `ExerciseAnimation`.
///
/// Every frame is a 512 × 512 SVG with a transparent background, drawn in
/// white, so it is meant to be tinted at render time rather than used as-is on
/// a light surface.
class ExerciseFrame {
  /// Creates a frame.
  const ExerciseFrame({
    required this.index,
    required this.path,
    required this.width,
    required this.height,
    required this.format,
    required this.attribution,
  });

  /// Reads a `frames[]` entry out of the catalog manifest.
  factory ExerciseFrame.fromJson(Map<String, Object?> json) => ExerciseFrame(
        index: json['index']! as int,
        path: json['path']! as String,
        width: json['width']! as int,
        height: json['height']! as int,
        format: json['format']! as String,
        attribution: ExerciseAttribution.fromJson(
          json['attribution']! as Map<String, Object?>,
        ),
      );

  /// The position of this frame in the movement: 1, 2 or 3.
  final int index;

  /// The upstream-relative path, e.g. `assets/push-up/frame-1.svg`.
  ///
  /// This is the value the upstream manifest ships and the one
  /// `WorkoutGuide.assetCdnUrl` builds on. To load the bundled copy, use
  /// [assetPath] instead — this package stores its artwork one directory
  /// deeper.
  final String path;

  /// The intrinsic width in pixels, always 512.
  final int width;

  /// The intrinsic height in pixels, always 512.
  final int height;

  /// The asset format, always `svg`.
  final String format;

  /// Who made this frame and under which license.
  final ExerciseAttribution attribution;

  /// The Flutter asset key of the bundled SVG.
  ///
  /// ```dart
  /// SvgPicture.asset(exercise.frames.first.assetPath);
  /// // packages/workout_flutter_guide/assets/exercises/push-up/frame-1.svg
  /// ```
  ///
  /// The `packages/<name>/` prefix is what Flutter requires for an asset that
  /// a package ships on behalf of the app; you do not need to declare
  /// anything in your own `pubspec.yaml`.
  String get assetPath => '$_packageAssetPrefix$_portAssetPrefix'
      '${path.substring(_upstreamAssetPrefix.length)}';

  /// Returns this frame in the shape used by the catalog manifest.
  Map<String, Object?> toJson() => <String, Object?>{
        'index': index,
        'path': path,
        'width': width,
        'height': height,
        'format': format,
        'attribution': attribution.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseFrame &&
          other.index == index &&
          other.path == path &&
          other.width == width &&
          other.height == height &&
          other.format == format &&
          other.attribution == attribution;

  @override
  int get hashCode =>
      Object.hash(index, path, width, height, format, attribution);

  @override
  String toString() => 'ExerciseFrame($path)';
}
