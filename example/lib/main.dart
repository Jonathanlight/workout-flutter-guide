import 'package:flutter/material.dart';
import 'package:workout_flutter_guide/workout_flutter_guide.dart';

import 'pages/gallery_page.dart';

void main() {
  // Makes the CC BY-SA credit show up in showLicensePage(). The About screen
  // of this app renders WorkoutGuideAttribution as well; either one satisfies
  // the licence, and doing both is not overkill for a demo whose job is to
  // show how it should be done.
  WorkoutGuide.registerLicenses();
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout Guide',
      debugShowCheckedModeBanner: false,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      home: const GalleryPage(),
    );
  }

  ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF3D5AFE),
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      chipTheme: const ChipThemeData(showCheckmark: false),
    );
  }
}
