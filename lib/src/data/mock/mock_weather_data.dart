import 'package:core_weather/src/data/models/weather_model.dart';
import 'package:intl/intl.dart';

class MockWeatherData {
  static List<WeatherModel> generateDailyForecast() {
    final now = DateTime.now();
    final List<WeatherModel> forecast = [];
    
    // Generate 7 days of forecast
    for (int i = 0; i < 7; i++) {
      final date = now.add(Duration(days: i));
      final isToday = i == 0;
      
      // Generate some variation in weather
      final baseTemp = 20.0 + (i * 2) - 6.0; // Vary temperature between days
      final weatherCode = _getRandomWeatherCode(i);
      
      forecast.add(
        WeatherModel(
          latitude: 0, // These values don't matter for mock data
          longitude: 0,
          temperature: baseTemp + (i * 0.5), // Slight temperature increase
          apparentTemperature: baseTemp + (i * 0.3),
          precipitation: i * 0.5, // Some rain probability
          rain: i * 0.5,
          showers: 0.0,
          snowfall: i < 2 ? 0.0 : 0.0, // No snow in this mock
          weatherCode: weatherCode,
          cloudCover: 20 + (i * 5),
          windSpeed: 5 + (i * 0.5),
          windDirection: 180 + (i * 30) % 360,
          windGusts: 8 + (i * 0.7),
          relativeHumidity: 60 + (i * 2) % 30,
          uvIndex: i % 3 + 2, // UV index between 2-4
          time: date,
        )..locationName = isToday ? 'Today' : DateFormat('EEEE').format(date),
      );
    }
    
    return forecast;
  }
  
  static int _getRandomWeatherCode(int index) {
    // Weather codes from Open-Meteo's WMO interpretation
    final codes = [
      0,  // Clear sky
      1,  // Mainly clear
      2,  // Partly cloudy
      3,  // Overcast
      45, // Fog
      51, // Drizzle
      53, // Drizzle
      55, // Dense drizzle
      61, // Slight rain
      63, // Moderate rain
      65, // Heavy rain
      80, // Rain showers
      81, // Rain showers
      82, // Violent rain showers
      95, // Thunderstorm
    ];
    
    return codes[index % codes.length];
  }
}
