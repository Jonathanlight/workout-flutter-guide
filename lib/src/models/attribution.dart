/// The upstream artwork a frame was derived from.
///
/// Present on 76 of the 906 frames: those first poses that are vector-traced
/// adaptations of rasterized [Everkinetic](https://github.com/everkinetic/data)
/// SVGs. CC BY-SA 4.0 requires that this credit travels with the artwork, so
/// it is carried through the port unchanged and is queryable at runtime.
class AttributionSource {
  /// Creates an upstream source record.
  const AttributionSource({
    required this.name,
    required this.url,
    required this.license,
    required this.licenseUrl,
    required this.changes,
  });

  /// Reads an `attribution.source` object out of the catalog manifest.
  factory AttributionSource.fromJson(Map<String, Object?> json) =>
      AttributionSource(
        name: json['name']! as String,
        url: json['url']! as String,
        license: json['license']! as String,
        licenseUrl: json['licenseUrl']! as String,
        changes: json['changes']! as String,
      );

  /// The name of the original project, always `Everkinetic`.
  final String name;

  /// A permalink to the exact original file.
  final String url;

  /// The license of the original artwork, always `CC BY-SA 4.0`.
  final String license;

  /// A link to the full text of [license].
  final String licenseUrl;

  /// A human-readable record of what was changed, as CC BY-SA 4.0 requires.
  final String changes;

  /// Returns this record in the shape used by the catalog manifest.
  Map<String, Object?> toJson() => <String, Object?>{
        'name': name,
        'url': url,
        'license': license,
        'licenseUrl': licenseUrl,
        'changes': changes,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttributionSource &&
          other.name == name &&
          other.url == url &&
          other.license == license &&
          other.licenseUrl == licenseUrl &&
          other.changes == changes;

  @override
  int get hashCode => Object.hash(name, url, license, licenseUrl, changes);

  @override
  String toString() => 'AttributionSource($name, $url)';
}

/// Who made a piece of artwork, under which license, and from what.
///
/// Every exercise and every frame carries one. Removing it, or shipping the
/// artwork without surfacing it to your users, breaks the CC BY-SA 4.0 terms
/// the assets are licensed under.
///
/// See `WorkoutGuideAttribution` for a widget that renders a compliant credit
/// block, and `ATTRIBUTION.md` for the plain-text version.
class ExerciseAttribution {
  /// Creates an attribution record.
  const ExerciseAttribution({
    required this.creator,
    required this.creatorUrl,
    required this.license,
    required this.licenseUrl,
    this.source,
  });

  /// Reads an `attribution` object out of the catalog manifest.
  factory ExerciseAttribution.fromJson(Map<String, Object?> json) {
    final source = json['source'];
    return ExerciseAttribution(
      creator: json['creator']! as String,
      creatorUrl: json['creatorUrl']! as String,
      license: json['license']! as String,
      licenseUrl: json['licenseUrl']! as String,
      source: source == null
          ? null
          : AttributionSource.fromJson(source as Map<String, Object?>),
    );
  }

  /// The author of this artwork, always `Bryl Lim`.
  final String creator;

  /// A link to the author, always `https://bryllim.com`.
  final String creatorUrl;

  /// The license of the artwork, always `CC BY-SA 4.0`.
  final String license;

  /// A link to the full text of [license].
  final String licenseUrl;

  /// The original artwork this was derived from, when there is one.
  ///
  /// `null` for the 830 frames drawn from scratch by [creator].
  final AttributionSource? source;

  /// Returns this record in the shape used by the catalog manifest.
  Map<String, Object?> toJson() => <String, Object?>{
        'creator': creator,
        'creatorUrl': creatorUrl,
        'license': license,
        'licenseUrl': licenseUrl,
        if (source != null) 'source': source!.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseAttribution &&
          other.creator == creator &&
          other.creatorUrl == creatorUrl &&
          other.license == license &&
          other.licenseUrl == licenseUrl &&
          other.source == source;

  @override
  int get hashCode =>
      Object.hash(creator, creatorUrl, license, licenseUrl, source);

  @override
  String toString() => 'ExerciseAttribution($creator, $license)';
}
