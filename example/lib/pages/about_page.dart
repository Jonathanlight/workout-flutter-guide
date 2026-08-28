import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workout_flutter_guide/workout_flutter_guide.dart';

/// The screen that discharges the CC BY-SA 4.0 attribution obligation.
///
/// This is the part most apps forget. Shipping the artwork without crediting
/// its authors, somewhere a user can reach, breaks the licence.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('About & credits')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: <Widget>[
          Text('Illustrations', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: WorkoutGuideAttribution(
                style: theme.textTheme.bodyMedium,
                linkStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
                onLinkTap: (url) {
                  Clipboard.setData(ClipboardData(text: url));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Copied $url')),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Catalog', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            '${WorkoutGuide.exercises.length} exercises, '
            '${WorkoutGuide.exercises.length * 3} frames, from '
            '@bryllim/workout-guide v${WorkoutGuide.catalogVersion}. '
            'Everything is bundled: this app makes no network request.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Text('Licences', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'The Dart code of workout_flutter_guide is MIT licensed. The '
            'artwork is CC BY-SA 4.0: you may reuse and adapt it, including '
            'commercially, as long as you credit the authors, link to the '
            'licence, say what you changed, and license your adaptation the '
            'same way.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            onPressed: () => showLicensePage(
              context: context,
              applicationName: 'Workout Guide example',
              applicationLegalese:
                  '© 2026 Jonathan KABLAN. Artwork © Bryl Lim and '
                  'Everkinetic, CC BY-SA 4.0.',
            ),
            icon: const Icon(Icons.article_outlined),
            label: const Text('Open the full licence list'),
          ),
          const SizedBox(height: 8),
          Text(
            'The entry above is registered by '
            'WorkoutGuide.registerLicenses(), called from main().',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
