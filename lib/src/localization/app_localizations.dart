import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  static const String defaultLanguage = 'en';
  static const List<String> supportedLanguages = ['en', 'sv'];
  static const String translationsPath = 'assets/translations';

  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'sv':
        return 'Svenska';
      default:
        return 'English';
    }
  }

  static Future<void> setLanguage(BuildContext context, String languageCode) async {
    if (context.mounted) {
      await context.setLocale(Locale(languageCode));
    }
  }

  static String? getCurrentLanguageCode(BuildContext context) {
    return context.locale.languageCode;
  }
}

// Extension to make it easier to call translations
extension LocalizationExtension on String {
  String trWithContext(BuildContext context, {List<String>? args}) {
    if (args != null) {
      return context.tr(this, args: args);
    }
    return context.tr(this);
  }
}
