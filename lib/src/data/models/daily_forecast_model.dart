import 'package:json_annotation/json_annotation.dart';
import 'package:weather_app/src/data/models/weather_model.dart';

part 'daily_forecast_model.g.dart';

@JsonSerializable()
class DailyForecastResponse {
  final DailyForecastData daily;
  final double latitude;
  final double longitude;
  final double generationtime_ms;
  final int utc_offset_seconds;
  final String timezone;
  final String timezone_abbreviation;
  final double elevation;

  DailyForecastResponse({
    required this.daily,
    required this.latitude,
    required this.longitude,
    required this.generationtime_ms,
    required this.utc_offset_seconds,
    required this.timezone,
    required this.timezone_abbreviation,
    required this.elevation,
  });

  factory DailyForecastResponse.fromJson(Map<String, dynamic> json) =>
      _$DailyForecastResponseFromJson(json);
  Map<String, dynamic> toJson() => _$DailyForecastResponseToJson(this);
}

@JsonSerializable()
class DailyForecastData {
  final List<String> time;
  @JsonKey(name: 'weathercode')
  final List<int> weatherCode;
  @JsonKey(name: 'temperature_2m_max')
  final List<double> temperatureMax;
  @JsonKey(name: 'temperature_2m_min')
  final List<double> temperatureMin;
  @JsonKey(name: 'apparent_temperature_max')
  final List<double> apparentTemperatureMax;
  @JsonKey(name: 'apparent_temperature_min')
  final List<double> apparentTemperatureMin;
  @JsonKey(name: 'sunrise')
  final List<String> sunriseTime;
  @JsonKey(name: 'sunset')
  final List<String> sunsetTime;
  @JsonKey(name: 'precipitation_sum')
  final List<double> precipitationSum;
  @JsonKey(name: 'precipitation_hours')
  final List<double>? precipitationHours;
  @JsonKey(name: 'windspeed_10m_max')
  final List<double> windSpeedMax;
  @JsonKey(name: 'windgusts_10m_max')
  final List<double>? windGustsMax;
  @JsonKey(name: 'winddirection_10m_dominant')
  final List<int>? windDirection;

  DailyForecastData({
    required this.time,
    required this.weatherCode,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.apparentTemperatureMax,
    required this.apparentTemperatureMin,
    required this.sunriseTime,
    required this.sunsetTime,
    required this.precipitationSum,
    this.precipitationHours,
    required this.windSpeedMax,
    this.windGustsMax,
    this.windDirection,
  });

  factory DailyForecastData.fromJson(Map<String, dynamic> json) =>
      _$DailyForecastDataFromJson(json);
  Map<String, dynamic> toJson() => _$DailyForecastDataToJson(this);
}

// Extension to convert to the app's existing model
extension DailyForecastDataExtension on DailyForecastData {
  List<WeatherModel> toWeatherModelList(double latitude, double longitude) {
    return List.generate(time.length, (index) {
      return WeatherModel(
        latitude: latitude,
        longitude: longitude,
        temperature: (temperatureMax[index] + temperatureMin[index]) / 2,
        apparentTemperature: (apparentTemperatureMax[index] + apparentTemperatureMin[index]) / 2,
        precipitation: precipitationSum[index],
        rain: precipitationSum[index], // Using sum as rain for simplicity
        showers: 0.0, // Not available in daily forecast
        snowfall: 0.0, // Not available in daily forecast
        weatherCode: weatherCode[index],
        cloudCover: 0, // Not available in daily forecast
        windSpeed: windSpeedMax[index],
        windDirection: windDirection?[index] ?? 0,
        windGusts: windGustsMax?[index] ?? windSpeedMax[index] * 1.5,
        relativeHumidity: 0, // Not available in daily forecast
        uvIndex: 0, // Will be set by the caller if available
        time: DateTime.parse(time[index]),
      );
    });
  }

  // Get weather condition text based on weather code
  String getWeatherCondition(int code) {
    return WeatherModel(
      latitude: 0,
      longitude: 0,
      temperature: 0,
      apparentTemperature: 0,
      precipitation: 0,
      rain: 0,
      showers: 0,
      snowfall: 0,
      weatherCode: code,
      cloudCover: 0,
      windSpeed: 0,
      windDirection: 0,
      windGusts: 0,
      relativeHumidity: 0,
      uvIndex: 0,
      time: DateTime.now(),
    ).condition;
  }
}
