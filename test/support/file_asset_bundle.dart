import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Serves the package's own assets from disk during tests.
///
/// `flutter test` builds its asset manifest from this package's
/// `pubspec.yaml`, so the assets are registered under `assets/exercises/...`.
/// At run time in a consumer app the very same files are registered under
/// `packages/workout_flutter_guide/assets/exercises/...`, which is the key the
/// widgets ask for. This bundle bridges the two so widget tests exercise the
/// real SVG files rather than a stub.
class FileAssetBundle extends CachingAssetBundle {
  /// The prefix Flutter adds to assets a package ships for an app.
  static const String packagePrefix = 'packages/workout_flutter_guide/';

  @override
  Future<ByteData> load(String key) async {
    final path = key.startsWith(packagePrefix)
        ? key.substring(packagePrefix.length)
        : key;
    final file = File(path);
    if (!file.existsSync()) {
      throw FlutterError('FileAssetBundle: no file at $path (key: $key)');
    }
    // Read synchronously: `flutter test` drives a fake async zone, and a
    // real disk read would never complete under `pump`.
    return ByteData.sublistView(Uint8List.fromList(file.readAsBytesSync()));
  }
}
