import 'package:flutter/foundation.dart';
import 'package:weather_app/src/data/models/daily_forecast_model.dart';
import 'package:weather_app/src/data/models/weather_model.dart';
import 'package:weather_app/src/data/repositories/weather_repository.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherRepository _weatherRepository;
  
  DailyForecastResponse? _dailyForecast;
  WeatherModel? _currentWeather;
  bool _isLoading = false;
  String? _error;

  WeatherProvider({required WeatherRepository weatherRepository}) 
      : _weatherRepository = weatherRepository;

  DailyForecastResponse? get dailyForecast => _dailyForecast;
  WeatherModel? get currentWeather => _currentWeather;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchWeather({
    required double? latitude,
    required double? longitude,
    String? locationName,
    bool forceRefresh = false,
    int days = 7,
  }) async {
    if (latitude == null || longitude == null) {
      _error = 'Location not available';
      return;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _dailyForecast = await _weatherRepository.getDailyForecast(
        latitude: latitude,
        longitude: longitude,
        days: days,
      );
      
      // Update current weather with the first day's forecast
      if (_dailyForecast != null && _dailyForecast!.daily.time.isNotEmpty) {
        final weatherList = _dailyForecast!.daily.toWeatherModelList(
          _dailyForecast!.latitude,
          _dailyForecast!.longitude,
        );
        if (weatherList.isNotEmpty) {
          _currentWeather = weatherList.first;
          if (locationName != null) {
            _currentWeather = _currentWeather!.copyWith(locationName: locationName);
          }
        }
      }
    } catch (e) {
      _error = 'Failed to fetch weather: $e';
      debugPrint('Error in fetchWeather: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshWeather() async {
    if (_dailyForecast != null) {
      await fetchWeather(
        latitude: _dailyForecast!.latitude,
        longitude: _dailyForecast!.longitude,
        locationName: _currentWeather?.locationName,
      );
    }
  }
}
