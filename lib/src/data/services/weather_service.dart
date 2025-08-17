import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

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
      
      // Construct the URL with all parameters
      final uri = Uri.parse('$_baseUrl?latitude=$lat&longitude=$lon&current_weather=true&hourly=temperature_2m,apparent_temperature,precipitation,rain,showers,snowfall,weathercode,cloudcover,windspeed_10m,winddirection_10m,windgusts_10m,relativehumidity_2m,uv_index&timezone=auto&forecast_days=2');
      
      debugPrint('Fetching weather from: ${uri.toString()}');
      
      // Request current weather and forecast for the next 24 hours
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Parse the current weather data
        final current = data['current_weather'];
        final hourly = data['hourly'];
        
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
        final uvIndex = hourlyUvIndex?.round() ?? 0;
        
        final weather = WeatherModel.fromJson(hourly, timeIndex, uvIndex: uvIndex);
        
        // Set the location name if provided or available from the API
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
}
