import 'package:flutter/foundation.dart';

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
  final DateTime time;
  String? _locationName;
  String? get locationName => _locationName;
  set locationName(String? value) => _locationName = value;

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
    required this.time,
    String? locationName,
  }) : _locationName = locationName;

  factory WeatherModel.fromJson(Map<String, dynamic> json, int index) {
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
      time: DateTime.parse(json['time'][index]),
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
