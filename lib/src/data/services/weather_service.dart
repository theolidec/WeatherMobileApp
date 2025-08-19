import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../models/hourly_forecast_model.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';
  
  // Default coordinates (you can make these configurable)
  static const double _defaultLatitude = 51.5074; // London
  static const double _defaultLongitude = -0.1278;
  
  // Cache the last response to avoid unnecessary API calls
  static WeatherModel? _cachedWeather;
  static DateTime? _lastFetchTime;
  
  Future<WeatherModel> getCurrentWeather({
    double? latitude,
    double? longitude,
    String? locationName,
    bool forceRefresh = false,
  }) async {
    // Return cached data if it's fresh (less than 10 minutes old) and not forcing refresh
    if (!forceRefresh && 
        _cachedWeather != null && 
        _lastFetchTime != null && 
        DateTime.now().difference(_lastFetchTime!) < const Duration(minutes: 10)) {
      return _cachedWeather!;
    }
    
    try {
      final double lat = latitude ?? _defaultLatitude;
      final double lon = longitude ?? _defaultLongitude;
      
      // Construct the URL with all parameters including daily forecast
      final uri = Uri.parse(
        '$_baseUrl?'
        'latitude=$lat&'
        'longitude=$lon&'
        'current_weather=true&'
        'hourly=temperature_2m,apparent_temperature,precipitation,rain,showers,snowfall,weathercode,cloudcover,windspeed_10m,winddirection_10m,windgusts_10m,relativehumidity_2m,uv_index&'
        'daily=weathercode,temperature_2m_max,temperature_2m_min,precipitation_sum,precipitation_hours,windspeed_10m_max,winddirection_10m_dominant&'
        'timezone=auto&'
        'forecast_days=7'  // Get 7-day forecast
      );
      
      debugPrint('Fetching weather from: ${uri.toString()}');
      
      // Request current weather and forecast for the next 24 hours
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Log hourly forecast data summary
        if (data['hourly'] != null) {
          final hourly = data['hourly'];
          final times = List<String>.from(hourly['time'] ?? []);
          final temps = List<dynamic>.from(hourly['temperature_2m'] ?? []);
          final weatherCodes = List<dynamic>.from(hourly['weathercode'] ?? []);
          
          debugPrint('Hourly Forecast Data Summary:');
          debugPrint('- Time range: ${times.isNotEmpty ? '${times.first} to ${times.last}' : 'No data'}');
          debugPrint('- Total hours: ${times.length}');
          debugPrint('- Temperature range: ${_findMinMax(temps)}°C');
          debugPrint('- Weather conditions: ${_summarizeWeatherCodes(weatherCodes)}');
          
          // Log first 10 hours of data for verification
          final count = times.length > 10 ? 10 : times.length;
          for (int i = 0; i < count; i++) {
            final condition = _getWeatherCondition(weatherCodes[i]);
            debugPrint('  ${times[i]}: ${temps[i]}°C, $condition (code: ${weatherCodes[i]})');
          }
        } else {
          debugPrint('No hourly forecast data in response');
        }
        
        // Parse the current weather data
        final current = data['current_weather'];
        final hourly = data['hourly'];
        
        // Parse hourly forecast data
        List<HourlyForecast> hourlyForecasts = [];
        if (hourly != null) {
          final times = List<String>.from(hourly['time'] ?? []);
          final temperatures = List<dynamic>.from(hourly['temperature_2m'] ?? []);
          final apparentTemperatures = List<dynamic>.from(hourly['apparent_temperature'] ?? temperatures);
          final weatherCodes = List<dynamic>.from(hourly['weathercode'] ?? []);
          final windSpeeds = List<dynamic>.from(hourly['windspeed_10m'] ?? []);
          final windDirections = List<dynamic>.from(hourly['winddirection_10m'] ?? []);
          final humidity = List<dynamic>.from(hourly['relativehumidity_2m'] ?? []);
          final precipitation = List<dynamic>.from(hourly['precipitation'] ?? List.filled(times.length, 0.0));
          final surfacePressure = List<dynamic>.from(hourly['surface_pressure'] ?? List.filled(times.length, 1013.0));
          
          // Get current time and find the current hour in the forecast
          final now = DateTime.now();
          int startIndex = 0;
          
          // Find the index of the current hour in the forecast
          for (int i = 0; i < times.length; i++) {
            final forecastTime = DateTime.parse(times[i]);
            if (forecastTime.isAfter(now.subtract(const Duration(hours: 1)))) {
              startIndex = i;
              break;
            }
          }
          
          // Limit to current hour + next 9 hours (10 hours total)
          final endIndex = startIndex + 10 < times.length ? startIndex + 10 : times.length;
          
          debugPrint('Displaying hourly forecast from index $startIndex to $endIndex');
          
          for (int i = startIndex; i < endIndex; i++) {
            try {
              final forecastTime = DateTime.parse(times[i]);
              final isDay = forecastTime.hour >= 6 && forecastTime.hour < 18; // Simple day/night check
              
              final forecast = HourlyForecast(
                time: forecastTime,
                temperature: (temperatures[i] as num).toDouble(),
                apparentTemperature: (apparentTemperatures[i] as num).toDouble(),
                precipitation: (precipitation[i] as num).toDouble(),
                weatherCode: weatherCodes[i] as int,
                windSpeed: (windSpeeds[i] as num).toDouble(),
                windDirection: windDirections[i] as int,
                relativeHumidity: humidity[i] as int,
                surfacePressure: (surfacePressure[i] as num).toDouble(),
                isDay: isDay,
              );
              hourlyForecasts.add(forecast);
            } catch (e) {
              debugPrint('Error parsing hourly forecast at index $i: $e');
            }
          }
        }
        
        // Parse the current time from the API response
        final currentTime = DateTime.parse(current['time']);
        final hourlyTimes = (data['hourly']['time'] as List).cast<String>();
        
        // Find the closest time in the hourly data to the current time
        int timeIndex = 0;
        Duration minDifference = const Duration(days: 365); // Initialize with a large duration
        
        for (int i = 0; i < hourlyTimes.length; i++) {
          final hourlyTime = DateTime.parse(hourlyTimes[i]);
          final difference = hourlyTime.difference(currentTime).abs();
          
          if (difference < minDifference) {
            minDifference = difference;
            timeIndex = i;
          }
          
          // If we find an exact match, use it immediately
          if (difference == Duration.zero) {
            break;
          }
        }
        
        // Log if we're using a non-exact match
        if (minDifference > const Duration(minutes: 30)) {
          debugPrint('Using nearest hourly data point (${minDifference.inMinutes}m difference)');
        }
        
        // Create weather model from the current hour's data
        final currentData = data['current_weather'];
        final index = 0; // Since we're only getting current weather, index is 0
        
        // Get UV index from hourly data (it's not in current_weather)
        final hourlyUvIndex = (hourly['uv_index'] as List<dynamic>?)?[timeIndex] as num?;
        // Combine hourly and daily data for the model
        final weatherData = Map<String, dynamic>.from(hourly);
        if (data['daily'] != null) {
          weatherData['daily'] = data['daily'];
        }
        
        // Create the weather model with the current weather data and hourly forecast
        final weather = WeatherModel.fromJson(
          data,
          timeIndex,
          uvIndex: current['uv_index']?.toInt() ?? 0,
          hourlyForecast: hourlyForecasts,
        );
        
        // Set the location name if provided
        if (locationName != null) {
          weather.locationName = locationName;
        } else if (data['location'] is Map) {
          final location = data['location'] as Map<String, dynamic>;
          final name = location['name']?.toString();
          if (name != null) {
            weather.locationName = name;
          }
        }
        
        // Cache the result
        _cachedWeather = weather;
        _lastFetchTime = DateTime.now();
        
        return weather;
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      // If there's an error but we have cached data, return that
      if (_cachedWeather != null) {
        return _cachedWeather!;
      }
      rethrow;
    }
  }
  
  // Helper method to get weather for a specific location
  Future<WeatherModel> getWeatherForLocation(double latitude, double longitude) {
    return getCurrentWeather(
      latitude: latitude,
      longitude: longitude,
      forceRefresh: true,
    );
  }
  
  // Helper method to find min and max values in a list
  static String _findMinMax(List<dynamic> values) {
    if (values.isEmpty) return 'N/A';
    double min = double.infinity;
    double max = -double.infinity;
    
    for (var value in values) {
      if (value == null) continue;
      final numValue = (value is num) ? value.toDouble() : double.tryParse(value.toString());
      if (numValue == null) continue;
      
      if (numValue < min) min = numValue;
      if (numValue > max) max = numValue;
    }
    
    return min == double.infinity ? 'N/A' : '${min.toStringAsFixed(1)}°C to ${max.toStringAsFixed(1)}°C';
  }
  
  // Helper method to summarize weather codes
  static String _summarizeWeatherCodes(List<dynamic> codes) {
    if (codes.isEmpty) return 'No data';
    
    final codeCount = <int, int>{};
    for (var code in codes) {
      if (code is int) {
        codeCount[code] = (codeCount[code] ?? 0) + 1;
      }
    }
    
    if (codeCount.isEmpty) return 'No valid weather codes';
    
    return codeCount.entries
        .map((e) => '${_getWeatherCondition(e.key)} (${e.value}x)')
        .join(', ');
  }
  
  // Convert weather code to condition text
  static String _getWeatherCondition(int code) {
    switch (code) {
      case 0: return 'Clear';
      case 1: case 2: case 3: return 'Cloudy';
      case 45: case 48: return 'Fog';
      case 51: case 53: case 55: return 'Drizzle';
      case 56: case 57: return 'Freezing Drizzle';
      case 61: case 63: case 65: return 'Rain';
      case 66: case 67: return 'Freezing Rain';
      case 71: case 73: case 75: return 'Snow';
      case 77: return 'Snow Grains';
      case 80: case 81: case 82: return 'Rain Showers';
      case 85: case 86: return 'Snow Showers';
      case 95: return 'Thunderstorm';
      case 96: case 99: return 'Thunderstorm with Hail';
      default: return 'Unknown ($code)';
    }
  }
}
