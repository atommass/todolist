// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get my_title => 'Login';

  @override
  String task_title(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You have $count tasks',
      one: 'You have 1 task',
      zero: 'You have no tasks yet',
    );
    return '$_temp0';
  }

  @override
  String archived_task_title(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You have $count tasks archived',
      one: 'You have 1 task archived',
      zero: 'You have no tasks archived',
    );
    return '$_temp0';
  }
}
