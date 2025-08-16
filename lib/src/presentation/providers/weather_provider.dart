import 'package:flutter/material.dart';
import 'package:weather_app/src/data/models/weather_model.dart';
import 'package:weather_app/src/data/services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  
  WeatherModel? _currentWeather;
  bool _isLoading = false;
  String? _error;
  
  WeatherModel? get currentWeather => _currentWeather;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> fetchWeather({double? latitude, double? longitude, String? locationName}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _currentWeather = await _weatherService.getCurrentWeather(
        latitude: latitude,
        longitude: longitude,
        locationName: locationName,
      );
      
      // Update the location name if provided
      if (locationName != null && _currentWeather != null) {
        _currentWeather!.locationName = locationName;
      }
      
      _error = null;
    } catch (e) {
      _error = 'Failed to fetch weather data. Please try again later.';
      debugPrint('Error fetching weather: $e');
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _isLoading = false;
        notifyListeners();
      });
    }
  }
  
  Future<void> refreshWeather() async {
    if (_currentWeather != null) {
      await fetchWeather(
        latitude: _currentWeather!.latitude,
        longitude: _currentWeather!.longitude,
      );
    } else {
      await fetchWeather();
    }
  }
}
