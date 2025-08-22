import 'package:flutter/foundation.dart';
import 'hourly_forecast_model.dart';

class DailyForecast {
  final DateTime date;
  final double maxTemperature;
  final double minTemperature;
  final int weatherCode;
  final double precipitationSum;
  final double precipitationHours;
  final double windSpeedMax;
  final int windDirectionDominant;
  final DateTime? sunrise;
  final DateTime? sunset;

  const DailyForecast({
    required this.date,
    required this.maxTemperature,
    required this.minTemperature,
    required this.weatherCode,
    required this.precipitationSum,
    required this.precipitationHours,
    required this.windSpeedMax,
    required this.windDirectionDominant,
    this.sunrise,
    this.sunset,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json, int index) {
    DateTime? parseDateTime(String? timeStr) {
      try {
        return timeStr != null ? DateTime.parse(timeStr) : null;
      } catch (e) {
        return null;
      }
    }

    return DailyForecast(
      date: DateTime.parse(json['time'][index]),
      maxTemperature: (json['temperature_2m_max'][index] as num).toDouble(),
      minTemperature: (json['temperature_2m_min'][index] as num).toDouble(),
      weatherCode: json['weathercode'][index] as int,
      precipitationSum: (json['precipitation_sum'][index] as num).toDouble(),
      precipitationHours: (json['precipitation_hours'][index] as num).toDouble(),
      windSpeedMax: (json['windspeed_10m_max'][index] as num).toDouble(),
      windDirectionDominant: json['winddirection_10m_dominant'][index] as int,
      sunrise: json['sunrise'] != null ? parseDateTime(json['sunrise'][index]) : null,
      sunset: json['sunset'] != null ? parseDateTime(json['sunset'][index]) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'temperature_2m_max': maxTemperature,
      'temperature_2m_min': minTemperature,
      'weathercode': weatherCode,
      'precipitation_sum': precipitationSum,
      'precipitation_hours': precipitationHours,
      'windspeed_10m_max': windSpeedMax,
      'winddirection_10m_dominant': windDirectionDominant,
      if (sunrise != null) 'sunrise': sunrise!.toIso8601String(),
      if (sunset != null) 'sunset': sunset!.toIso8601String(),
    };
  }
}

class WeatherModel {
  final double latitude;
  final double longitude;
  final double temperature;
  final double apparentTemperature;
  final double precipitation;
  final double rain;
  final double showers;
  final double snowfall;
  final int weatherCode;
  final int cloudCover;
  final double windSpeed;
  final int windDirection;
  final double windGusts;
  final int relativeHumidity;
  final int uvIndex;
  final DateTime time;
  final List<DailyForecast>? dailyForecast;
  final List<HourlyForecast>? hourlyForecast;
  String? _locationName;
  String? get locationName => _locationName;
  set locationName(String? value) => _locationName = value;

  @override
  String toString() {
    return 'WeatherModel(' 
        'location: $locationName, ' 
        'temp: ${temperature.toStringAsFixed(1)}°C, ' 
        'condition: ${_getWeatherCondition(weatherCode)}, '
        'time: ${time.toIso8601String().substring(0, 19)}'
        ')';
  }

  String _getWeatherCondition(int code) {
    // Simplified weather condition based on WMO Weather interpretation codes
    if (code < 1) return 'Clear sky';
    if (code < 3) return 'Mainly clear';
    if (code < 50) return 'Fog';
    if (code < 70) return 'Drizzle';
    if (code < 80) return 'Rain';
    if (code < 90) return 'Snow';
    return 'Thunderstorm';
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'temperature': temperature,
      'apparentTemperature': apparentTemperature,
      'precipitation': precipitation,
      'rain': rain,
      'showers': showers,
      'snowfall': snowfall,
      'weatherCode': weatherCode,
      'cloudCover': cloudCover,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'windGusts': windGusts,
      'relativeHumidity': relativeHumidity,
      'uvIndex': uvIndex,
      'time': time.toIso8601String(),
      'dailyForecast': dailyForecast?.map((f) => f.toJson()).toList(),
      'locationName': locationName,
    };
  }

  WeatherModel({
    required this.latitude,
    required this.longitude,
    required this.temperature,
    required this.apparentTemperature,
    required this.precipitation,
    required this.rain,
    required this.showers,
    required this.snowfall,
    required this.weatherCode,
    required this.cloudCover,
    required this.windSpeed,
    required this.windDirection,
    required this.windGusts,
    required this.relativeHumidity,
    required this.uvIndex,
    required this.time,
    this.dailyForecast,
    this.hourlyForecast,
    String? locationName,
  }) : _locationName = locationName;

  factory WeatherModel.fromJson(Map<String, dynamic> json, int index, {int uvIndex = 0, List<HourlyForecast>? hourlyForecast}) {
    debugPrint('Parsing WeatherModel from JSON...');
    
    // Handle current weather data
    final currentWeather = json['current_weather'] as Map<String, dynamic>? ?? {};
    final hourly = json['hourly'] as Map<String, dynamic>? ?? {};
    
    // Parse daily forecast if available
    List<DailyForecast>? dailyForecast;
    if (json['daily'] != null) {
      try {
        debugPrint('Processing daily forecast data...');
        dailyForecast = [];
        final dailyData = json['daily'] as Map<String, dynamic>;
        final daysCount = (dailyData['time'] as List?)?.length ?? 0;
        debugPrint('Found $daysCount days of forecast data');
        
        for (int i = 0; i < daysCount; i++) {
          try {
            final forecast = DailyForecast.fromJson(dailyData, i);
            dailyForecast!.add(forecast);
            debugPrint('Added forecast for ${forecast.date}: ${forecast.minTemperature}°C - ${forecast.maxTemperature}°C');
          } catch (e) {
            debugPrint('Error parsing daily forecast at index $i: $e');
          }
        }
        debugPrint('Successfully processed ${dailyForecast?.length ?? 0} daily forecasts');
      } catch (e) {
        debugPrint('Error processing daily forecast: $e');
      }
    } else {
      debugPrint('No daily forecast data found in the response');
    }
    
    // Get current time from current_weather or use the first hourly time
    final currentTime = currentWeather['time'] != null 
        ? DateTime.parse(currentWeather['time']) 
        : DateTime.now();
    
    // Default coordinates if not provided
    final double latitude = (json['latitude'] as num?)?.toDouble() ?? 0.0;
    final double longitude = (json['longitude'] as num?)?.toDouble() ?? 0.0;
    
    // Get current weather values from current_weather or hourly data
    final temperature = currentWeather['temperature']?.toDouble() ?? 
        (hourly['temperature_2m']?[0] as num?)?.toDouble() ?? 0.0;
        
    final weatherCode = currentWeather['weathercode'] as int? ?? 
        (hourly['weathercode']?[0] as int?) ?? 0;
        
    final windSpeed = currentWeather['windspeed']?.toDouble() ?? 
        (hourly['windspeed_10m']?[0] as num?)?.toDouble() ?? 0.0;
        
    final windDirection = currentWeather['winddirection'] as int? ?? 
        (hourly['winddirection_10m']?[0] as int?) ?? 0;
    
    // Get other values from hourly data if available
    final hourlyIndex = 0; // Use first hour if no specific index is better
    
    return WeatherModel(
      latitude: latitude,
      longitude: longitude,
      temperature: temperature,
      apparentTemperature: (hourly['apparent_temperature']?[hourlyIndex] as num?)?.toDouble() ?? temperature,
      precipitation: (hourly['precipitation']?[hourlyIndex] as num?)?.toDouble() ?? 0.0,
      rain: (hourly['rain']?[hourlyIndex] as num?)?.toDouble() ?? 0.0,
      showers: (hourly['showers']?[hourlyIndex] as num?)?.toDouble() ?? 0.0,
      snowfall: (hourly['snowfall']?[hourlyIndex] as num?)?.toDouble() ?? 0.0,
      weatherCode: weatherCode,
      cloudCover: (hourly['cloudcover']?[hourlyIndex] as num?)?.toInt() ?? 0,
      windSpeed: windSpeed,
      windDirection: windDirection,
      windGusts: (hourly['windgusts_10m']?[hourlyIndex] as num?)?.toDouble() ?? windSpeed,
      relativeHumidity: (hourly['relativehumidity_2m']?[hourlyIndex] as num?)?.toInt() ?? 50,
      uvIndex: uvIndex,
      time: currentTime,
      dailyForecast: dailyForecast,
      hourlyForecast: hourlyForecast,
    );
  }

  // Helper method to get weather condition based on weather code
  String get condition {
    // WMO Weather interpretation codes (WW)
    // Source: https://open-meteo.com/en/docs
    switch (weatherCode) {
      case 0:
        return 'Clear sky';
      case 1:
      case 2:
      case 3:
        return 'Partly cloudy';
      case 45:
      case 48:
        return 'Foggy';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 56:
      case 57:
        return 'Freezing Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rain';
      case 66:
      case 67:
        return 'Freezing Rain';
      case 71:
      case 73:
      case 75:
        return 'Snow fall';
      case 77:
        return 'Snow grains';
      case 80:
      case 81:
      case 82:
        return 'Rain showers';
      case 85:
      case 86:
        return 'Snow showers';
      case 95:
      case 96:
      case 99:
        return 'Thunderstorm';
      default:
        return 'Unknown';
    }
  }

  // Get weather icon based on weather code
  String get weatherIcon {
    // This is a simplified mapping - you might want to adjust based on your app's icon set
    if (weatherCode == 0) return '☀️';
    if (weatherCode <= 3) return '⛅';
    if (weatherCode <= 19) return '🌫️';
    if (weatherCode <= 29) return '🌧️';
    if (weatherCode <= 69) return '🌧️';
    if (weatherCode <= 79) return '❄️';
    if (weatherCode <= 99) return '⛈️';
    return '❓';
  }
}
