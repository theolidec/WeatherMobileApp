import 'package:flutter/foundation.dart';

class DailyForecast {
  final DateTime date;
  final double maxTemperature;
  final double minTemperature;
  final int weatherCode;
  final double precipitationSum;
  final double precipitationHours;
  final double windSpeedMax;
  final int windDirectionDominant;

  const DailyForecast({
    required this.date,
    required this.maxTemperature,
    required this.minTemperature,
    required this.weatherCode,
    required this.precipitationSum,
    required this.precipitationHours,
    required this.windSpeedMax,
    required this.windDirectionDominant,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json, int index) {
    return DailyForecast(
      date: DateTime.parse(json['time'][index]),
      maxTemperature: (json['temperature_2m_max'][index] as num).toDouble(),
      minTemperature: (json['temperature_2m_min'][index] as num).toDouble(),
      weatherCode: json['weathercode'][index] as int,
      precipitationSum: (json['precipitation_sum'][index] as num).toDouble(),
      precipitationHours: (json['precipitation_hours'][index] as num).toDouble(),
      windSpeedMax: (json['windspeed_10m_max'][index] as num).toDouble(),
      windDirectionDominant: json['winddirection_10m_dominant'][index] as int,
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
    String? locationName,
  }) : _locationName = locationName;

  factory WeatherModel.fromJson(Map<String, dynamic> json, int index, {int uvIndex = 0}) {
    // Parse daily forecast if available
    List<DailyForecast>? dailyForecast;
    if (json['daily'] != null) {
      debugPrint('Processing daily forecast data...');
      dailyForecast = [];
      final dailyData = json['daily'] as Map<String, dynamic>;
      final daysCount = (dailyData['time'] as List).length;
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
      debugPrint('Successfully processed ${dailyForecast.length} daily forecasts');
    } else {
      debugPrint('No daily forecast data found in the response');
    }
    // Default coordinates if not provided
    final double latitude = json['latitude']?.toDouble() ?? 0.0;
    final double longitude = json['longitude']?.toDouble() ?? 0.0;
    
    return WeatherModel(
      latitude: latitude,
      longitude: longitude,
      temperature: (json['temperature_2m'][index] as num).toDouble(),
      apparentTemperature: (json['apparent_temperature'][index] as num).toDouble(),
      precipitation: (json['precipitation'][index] as num).toDouble(),
      rain: (json['rain'][index] as num).toDouble(),
      showers: (json['showers'][index] as num).toDouble(),
      snowfall: (json['snowfall'][index] as num).toDouble(),
      weatherCode: json['weathercode'][index] as int,
      cloudCover: json['cloudcover'][index] as int,
      windSpeed: (json['windspeed_10m'][index] as num).toDouble(),
      windDirection: json['winddirection_10m'][index] as int,
      windGusts: (json['windgusts_10m'][index] as num).toDouble(),
      relativeHumidity: json['relativehumidity_2m'][index] as int,
uvIndex: uvIndex,
      time: DateTime.parse(json['time'][index]),
      dailyForecast: dailyForecast,
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
