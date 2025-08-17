import 'package:weather_app/src/data/providers/weather_provider.dart';
import 'package:weather_app/src/data/repositories/weather_repository.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

List<SingleChildWidget> getProviders() {
  final weatherRepository = WeatherRepository();
  
  return [
    ChangeNotifierProvider<WeatherProvider>(
      create: (_) => WeatherProvider(weatherRepository: weatherRepository),
    ),
  ];
}
