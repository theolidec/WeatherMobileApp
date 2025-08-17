import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:weather_app/src/data/models/daily_forecast_model.dart';

class WeatherRepository {
  final Dio _dio;
  static const String _baseUrl = 'https://api.open-meteo.com/v1/';
  
  WeatherRepository({Dio? dio}) : _dio = dio ?? Dio();

  Future<DailyForecastResponse> getDailyForecast({
    required double latitude,
    required double longitude,
    int days = 7,
  }) async {
    try {
      log('Fetching daily forecast for latitude: $latitude, longitude: $longitude');
      
      final response = await _dio.get<Map<String, dynamic>>(
        '${_baseUrl}forecast',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'daily': [
            'weathercode',
            'temperature_2m_max',
            'temperature_2m_min',
            'apparent_temperature_max',
            'apparent_temperature_min',
            'sunrise',
            'sunset',
            'precipitation_sum',
            'precipitation_hours',
            'windspeed_10m_max',
            'windgusts_10m_max',
            'winddirection_10m_dominant',
          ],
          'timezone': 'auto',
          'forecast_days': days,
        },
      );

      log('Forecast data received: ${response.data?.keys.toList()}');
      
      if (response.statusCode == 200 && response.data != null) {
        return DailyForecastResponse.fromJson(response.data!);
      } else {
        log('Failed to load forecast: ${response.statusCode} - ${response.statusMessage}');
        throw Exception('Failed to load forecast data');
      }
    } catch (e, stackTrace) {
      log('Error fetching forecast', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
