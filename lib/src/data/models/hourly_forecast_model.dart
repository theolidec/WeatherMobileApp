import 'package:json_annotation/json_annotation.dart';
import 'package:weather_app/src/data/models/weather_model.dart';

part 'hourly_forecast_model.g.dart';

@JsonSerializable()
class HourlyForecastResponse {
  @JsonKey(name: 'hourly')
  final HourlyForecastData hourly;
  @JsonKey(name: 'latitude')
  final double latitude;
  @JsonKey(name: 'longitude')
  final double longitude;
  @JsonKey(name: 'generationtime_ms')
  final double generationTimeMs;
  @JsonKey(name: 'utc_offset_seconds')
  final int utcOffsetSeconds;
  @JsonKey(name: 'timezone')
  final String timezone;
  @JsonKey(name: 'timezone_abbreviation')
  final String timezoneAbbreviation;
  @JsonKey(name: 'elevation')
  final double elevation;

  HourlyForecastResponse({
    required this.hourly,
    required this.latitude,
    required this.longitude,
    required this.generationTimeMs,
    required this.utcOffsetSeconds,
    required this.timezone,
    required this.timezoneAbbreviation,
    required this.elevation,
  });

  factory HourlyForecastResponse.fromJson(Map<String, dynamic> json) =>
      _$HourlyForecastResponseFromJson(json);
  Map<String, dynamic> toJson() => _$HourlyForecastResponseToJson(this);
}

@JsonSerializable()
class HourlyForecastData {
  final List<String> time;
  @JsonKey(name: 'temperature_2m')
  final List<double> temperature;
  @JsonKey(name: 'apparent_temperature')
  final List<double> apparentTemperature;
  @JsonKey(name: 'precipitation')
  final List<double> precipitation;
  @JsonKey(name: 'weathercode')
  final List<int> weatherCode;
  @JsonKey(name: 'windspeed_10m')
  final List<double> windSpeed;
  @JsonKey(name: 'winddirection_10m')
  final List<int> windDirection;
  @JsonKey(name: 'relativehumidity_2m')
  final List<int> relativeHumidity;
  @JsonKey(name: 'surface_pressure')
  final List<double> surfacePressure;
  @JsonKey(name: 'visibility')
  final List<double>? visibility;
  @JsonKey(name: 'is_day')
  final List<int>? isDay;

  HourlyForecastData({
    required this.time,
    required this.temperature,
    required this.apparentTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
    required this.windDirection,
    required this.relativeHumidity,
    required this.surfacePressure,
    this.visibility,
    this.isDay,
  });

  factory HourlyForecastData.fromJson(Map<String, dynamic> json) =>
      _$HourlyForecastDataFromJson(json);
  Map<String, dynamic> toJson() => _$HourlyForecastDataToJson(this);
}

// Extension to convert to a list of HourlyForecast objects
extension HourlyForecastDataExtension on HourlyForecastData {
  List<HourlyForecast> toHourlyForecastList() {
    final List<HourlyForecast> forecasts = [];
    
    for (int i = 0; i < time.length; i++) {
      forecasts.add(
        HourlyForecast(
          time: DateTime.parse(time[i]),
          temperature: temperature[i],
          apparentTemperature: apparentTemperature[i],
          precipitation: precipitation[i],
          weatherCode: weatherCode[i],
          windSpeed: windSpeed[i],
          windDirection: windDirection[i],
          relativeHumidity: relativeHumidity[i],
          surfacePressure: surfacePressure[i],
          visibility: visibility?[i],
          isDay: isDay?[i] == 1,
        ),
      );
    }
    
    return forecasts;
  }
}

class HourlyForecast {
  final DateTime time;
  final double temperature;
  final double apparentTemperature;
  final double precipitation;
  final int weatherCode;
  final double windSpeed;
  final int windDirection;
  final int relativeHumidity;
  final double surfacePressure;
  final double? visibility;
  final bool? isDay;

  const HourlyForecast({
    required this.time,
    required this.temperature,
    required this.apparentTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
    required this.windDirection,
    required this.relativeHumidity,
    required this.surfacePressure,
    this.visibility,
    this.isDay,
  });

  String getWeatherCondition() {
    // Reuse the same weather condition mapping from DailyForecastData
    switch (weatherCode) {
      case 0:
        return 'Clear sky';
      case 1:
      case 2:
      case 3:
        return 'Mainly clear, partly cloudy, and overcast';
      case 45:
      case 48:
        return 'Fog and depositing rime fog';
      case 51:
      case 53:
      case 55:
        return 'Drizzle: Light, moderate, and dense intensity';
      case 56:
      case 57:
        return 'Freezing Drizzle: Light and dense intensity';
      case 61:
      case 63:
      case 65:
        return 'Rain: Slight, moderate and heavy intensity';
      case 66:
      case 67:
        return 'Freezing Rain: Light and heavy intensity';
      case 71:
      case 73:
      case 75:
        return 'Snow fall: Slight, moderate, and heavy intensity';
      case 77:
        return 'Snow grains';
      case 80:
      case 81:
      case 82:
        return 'Rain showers: Slight, moderate, and violent';
      case 85:
      case 86:
        return 'Snow showers slight and heavy';
      case 95:
        return 'Thunderstorm: Slight or moderate';
      case 96:
      case 99:
        return 'Thunderstorm with slight and heavy hail';
      default:
        return 'Unknown';
    }
  }
}
