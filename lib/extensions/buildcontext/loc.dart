import 'package:flutter/material.dart' show BuildContext;
import '/l10n/app_localizations.dart' show AppLocalizations;

extension Localization on BuildContext {
  AppLocalizations get loc {
    return AppLocalizations.of(this)!;
  }
}