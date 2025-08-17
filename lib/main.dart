import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/src/theme/theme_provider.dart';
import 'package:weather_app/src/presentation/pages/home_page.dart';
import 'package:weather_app/src/theme/app_theme.dart';
import 'package:weather_app/src/data/providers/weather_provider.dart';
import 'package:weather_app/src/data/providers/settings_provider.dart';
import 'package:weather_app/src/data/repositories/weather_repository.dart';

void main() {
  // Initialize dependencies
  final weatherRepository = WeatherRepository();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => WeatherProvider(weatherRepository: weatherRepository),
        ),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const MyApp(),
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
        );
      },
    );
  }
}
