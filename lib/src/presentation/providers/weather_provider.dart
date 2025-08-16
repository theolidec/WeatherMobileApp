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
  
  Future<void> fetchWeather({
    double? latitude, 
    double? longitude, 
    String? locationName,
    bool forceRefresh = false,
  }) async {
    debugPrint('WeatherProvider.fetchWeather - Starting... (lat: $latitude, lng: $longitude, name: $locationName)');
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _currentWeather = await _weatherService.getCurrentWeather(
        latitude: latitude,
        longitude: longitude,
        locationName: locationName,
        forceRefresh: forceRefresh,
      );
      
      debugPrint('WeatherProvider.fetchWeather - Received weather data: ${_currentWeather.toString()}');
      
      // Update the location name if provided
      if (locationName != null && _currentWeather != null) {
        _currentWeather!.locationName = locationName;
        debugPrint('WeatherProvider.fetchWeather - Updated location name to: $locationName');
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
    debugPrint('WeatherProvider.refreshWeather - Starting refresh...');
    if (_currentWeather != null) {
      debugPrint('WeatherProvider.refreshWeather - Using existing location (${_currentWeather!.locationName})');
      await fetchWeather(
        latitude: _currentWeather!.latitude,
        longitude: _currentWeather!.longitude,
        forceRefresh: true,  // Force a fresh API call
      );
    } else {
      debugPrint('WeatherProvider.refreshWeather - No current weather, fetching default location');
      await fetchWeather(forceRefresh: true);  // Force a fresh API call
    }
  }
}
