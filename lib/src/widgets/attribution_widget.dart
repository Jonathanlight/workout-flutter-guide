import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// The credit block CC BY-SA 4.0 requires you to show.
///
/// The exercise artwork is licensed under CC BY-SA 4.0, which means an app
/// that ships it has to credit the authors, link to the licence, and say that
/// the work was adapted. Drop this widget on your About or Licences screen and
/// that obligation is met:
///
/// ```dart
/// WorkoutGuideAttribution(
///   onLinkTap: (url) => launchUrlString(url),
/// )
/// ```
///
/// [onLinkTap] is optional: this package takes no URL-launching dependency, so
/// you wire it to whatever your app already uses. Without it the names render
/// as plain text, which still satisfies the licence as long as the URLs are
/// visible somewhere — see [plainText].
///
/// The other supported route is `WorkoutGuide.registerLicenses()` plus
/// Flutter's `showLicensePage`.
class WorkoutGuideAttribution extends StatefulWidget {
  /// Creates the credit block.
  const WorkoutGuideAttribution({
    super.key,
    this.onLinkTap,
    this.style,
    this.linkStyle,
    this.textAlign = TextAlign.start,
  });

  /// The URL of the artwork author.
  static const String creatorUrl = 'https://bryllim.com';

  /// The URL of the project the original poses come from.
  static const String sourceUrl = 'https://github.com/everkinetic/data';

  /// The URL of the artwork licence.
  static const String licenseUrl =
      'https://creativecommons.org/licenses/by-sa/4.0/';

  /// The same credit as a plain string, URLs included.
  ///
  /// Use it when you build your own licences screen, write a `NOTICE` file, or
  /// need the text outside a widget tree.
  static const String plainText =
      'Exercise illustrations by Bryl Lim ($creatorUrl), based on artwork by '
      'Everkinetic ($sourceUrl), licensed under CC BY-SA 4.0 ($licenseUrl).';

  /// Called when the reader taps one of the three links.
  ///
  /// When null the links are not tappable and render with [style].
  final ValueChanged<String>? onLinkTap;

  /// The style of the surrounding text. Defaults to the inherited style.
  final TextStyle? style;

  /// The style of the three links.
  ///
  /// Defaults to [style] with an underline. Give it your theme's link colour
  /// if you have one.
  final TextStyle? linkStyle;

  /// How the paragraph is aligned.
  final TextAlign textAlign;

  @override
  State<WorkoutGuideAttribution> createState() =>
      _WorkoutGuideAttributionState();
}

class _WorkoutGuideAttributionState extends State<WorkoutGuideAttribution> {
  final List<TapGestureRecognizer> _recognizers = <TapGestureRecognizer>[];

  @override
  void dispose() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    super.dispose();
  }

  TapGestureRecognizer? _recognizerFor(String url) {
    final onLinkTap = widget.onLinkTap;
    if (onLinkTap == null) return null;
    final recognizer = TapGestureRecognizer()..onTap = () => onLinkTap(url);
    _recognizers.add(recognizer);
    return recognizer;
  }

  TextSpan _link(String label, String url, TextStyle? linkStyle) => TextSpan(
        text: label,
        style: linkStyle,
        recognizer: _recognizerFor(url),
        semanticsLabel: widget.onLinkTap == null ? '$label, $url' : label,
      );

  @override
  Widget build(BuildContext context) {
    // Recognizers are rebuilt on every build; drop the previous batch so they
    // do not leak.
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();

    final linkStyle = widget.linkStyle ??
        (widget.style ?? const TextStyle())
            .copyWith(decoration: TextDecoration.underline);

    return Text.rich(
      TextSpan(
        style: widget.style,
        children: <InlineSpan>[
          const TextSpan(text: 'Exercise illustrations by '),
          _link('Bryl Lim', WorkoutGuideAttribution.creatorUrl, linkStyle),
          const TextSpan(text: ', based on artwork by '),
          _link('Everkinetic', WorkoutGuideAttribution.sourceUrl, linkStyle),
          const TextSpan(text: ', licensed under '),
          _link('CC BY-SA 4.0', WorkoutGuideAttribution.licenseUrl, linkStyle),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: widget.textAlign,
    );
  }
}
