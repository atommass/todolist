// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Latvian (`lv`).
class AppLocalizationsLv extends AppLocalizations {
  AppLocalizationsLv([String locale = 'lv']) : super(locale);

  @override
  String get my_title => 'Ielogojies';

  @override
  String task_title(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tev ir $count uzdevumi',
      one: 'Tev ir 1 uzdevums',
      zero: 'Tev nav uzdevumu',
    );
    return '$_temp0';
  }

  @override
  String archived_task_title(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tev ir $count arhivēti uzdevumi',
      one: 'Tev ir 1 arhivēts uzdevums',
      zero: 'Tukšs arhīvs',
    );
    return '$_temp0';
  }
}
