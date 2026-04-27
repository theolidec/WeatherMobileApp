import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'src/theme/theme_provider.dart';
import 'src/presentation/pages/home_page.dart';
import 'src/theme/app_theme.dart';
import 'src/presentation/providers/weather_provider.dart';
import 'src/data/providers/settings_provider.dart';
import 'src/localization/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize shared preferences
  final prefs = await SharedPreferences.getInstance();
  
  // Get saved language or use device locale
  final savedLanguage = prefs.getString('language') ?? 'en';
  
  // Initialize EasyLocalization
  await EasyLocalization.ensureInitialized();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: EasyLocalization(
        supportedLocales: const [
          Locale('en'),
          Locale('sv'),
          Locale('es'),
        ],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: Locale(savedLanguage),
        saveLocale: true,
        useOnlyLangCode: true,
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Weather App',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeProvider.themeMode,
          home: const HomePage(),
          debugShowCheckedModeBanner: false,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
        );
      },
    );
  }
}
