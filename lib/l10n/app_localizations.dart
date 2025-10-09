import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  // App Title
  String get appTitle;

  // Bottom Navigation
  String get homeTab;
  String get checkinTab;
  String get remindersTab;
  String get settingsTab;

  // Home Screen
  String get quitTimerTitle;
  String get days;
  String get hours;
  String get minutes;
  String get moneySaved;
  String get cigarettesAvoided;
  String get healthProgress;
  String get nextMilestone;

  // Check-in Screen
  String get dailyCheckin;
  String get howAreYouFeeling;
  String get cravingIntensity;
  String get addNotes;
  String get submitCheckin;
  String get checkinSuccess;

  // Health Milestones
  String get health_20min_title;
  String get health_20min_desc;
  String get health_8hours_title;
  String get health_8hours_desc;
  String get health_24hours_title;
  String get health_24hours_desc;
  String get health_2days_title;
  String get health_2days_desc;
  String get health_3days_title;
  String get health_3days_desc;
  String get health_1week_title;
  String get health_1week_desc;
  String get health_1month_title;
  String get health_1month_desc;
  String get health_3months_title;
  String get health_3months_desc;
  String get health_1year_title;
  String get health_1year_desc;

  // Settings Screen
  String get personalInfo;
  String get nickname;
  String get gender;
  String get age;
  String get smokingInfo;
  String get dailyExpense;
  String get dailyCigarettes;
  String get smokingYears;
  String get quitReason;
  String get notifications;
  String get enableNotifications;
  String get reminderTimes;
  String get language;
  String get theme;
  String get dataManagement;
  String get exportData;
  String get importData;
  String get resetAllData;

  // Feedback
  String get feedbackSectionTitle;
  String get feedbackDescription;
  String get feedbackPlaceholder;
  String get submitFeedback;
  String get feedbackSuccess;
  String get feedbackEmptyError;
  String get feedbackFailure;
  String get feedbackEnable65DialogTitle;
  String get feedbackEnable65DialogMessage;
  String get feedbackEnable65Confirm;

  // Common
  String get save;
  String get cancel;
  String get confirm;
  String get delete;
  String get edit;
  String get done;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }
  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely an issue with the localizations generation tool. Supported locales are: ${AppLocalizations.supportedLocales.join(', ')}',
  );
}
