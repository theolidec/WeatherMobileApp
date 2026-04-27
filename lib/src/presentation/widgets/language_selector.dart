import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../data/providers/settings_provider.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final currentLocale = context.locale;
    
    return ListTile(
      leading: const Icon(Icons.language),
      title: Text('language'.tr()),
      subtitle: Text(_getLanguageName(currentLocale.languageCode)),
      onTap: () => _showLanguageDialog(context, settingsProvider),
    );
  }

  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'sv':
        return 'Svenska';
      case 'es':
        return 'Español';
      default:
        return 'English';
    }
  }

  Future<void> _showLanguageDialog(
      BuildContext context, SettingsProvider settingsProvider) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('select_language'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption(context, 'en', 'English', settingsProvider),
              _buildLanguageOption(context, 'sv', 'Svenska', settingsProvider),
              _buildLanguageOption(context, 'es', 'Español', settingsProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String languageCode,
    String languageName,
    SettingsProvider settingsProvider,
  ) {
    final isSelected = settingsProvider.language == languageCode;
    return ListTile(
      title: Text(languageName),
      leading: Radio<String>(
        value: languageCode,
        groupValue: settingsProvider.language,
        onChanged: (value) => _changeLanguage(context, value!, settingsProvider),
      ),
      onTap: () => _changeLanguage(context, languageCode, settingsProvider),
    );
  }

  Future<void> _changeLanguage(
    BuildContext context,
    String languageCode,
    SettingsProvider settingsProvider,
  ) async {
    // Update the app's locale
    await context.setLocale(Locale(languageCode));
    
    // Update settings and save preference
    await settingsProvider.setLanguage(languageCode);
    
    // Close the dialog
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}
