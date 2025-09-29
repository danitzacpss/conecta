export 'app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_localizations.dart';

final localeProvider = StateProvider<Locale?>((ref) => const Locale('es'));

class L10n {
  static const supportedLocales = [Locale('es'), Locale('en')];
}

extension BuildContextL10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
