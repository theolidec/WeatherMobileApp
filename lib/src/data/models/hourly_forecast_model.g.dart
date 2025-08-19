// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hourly_forecast_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HourlyForecastResponse _$HourlyForecastResponseFromJson(
  Map<String, dynamic> json,
) => HourlyForecastResponse(
  hourly: HourlyForecastData.fromJson(json['hourly'] as Map<String, dynamic>),
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  generationTimeMs: (json['generationtime_ms'] as num).toDouble(),
  utcOffsetSeconds: (json['utc_offset_seconds'] as num).toInt(),
  timezone: json['timezone'] as String,
  timezoneAbbreviation: json['timezone_abbreviation'] as String,
  elevation: (json['elevation'] as num).toDouble(),
);

Map<String, dynamic> _$HourlyForecastResponseToJson(
  HourlyForecastResponse instance,
) => <String, dynamic>{
  'hourly': instance.hourly,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'generationtime_ms': instance.generationTimeMs,
  'utc_offset_seconds': instance.utcOffsetSeconds,
  'timezone': instance.timezone,
  'timezone_abbreviation': instance.timezoneAbbreviation,
  'elevation': instance.elevation,
};

HourlyForecastData _$HourlyForecastDataFromJson(Map<String, dynamic> json) =>
    HourlyForecastData(
      time: (json['time'] as List<dynamic>).map((e) => e as String).toList(),
      temperature: (json['temperature_2m'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      apparentTemperature: (json['apparent_temperature'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      precipitation: (json['precipitation'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      weatherCode: (json['weathercode'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      windSpeed: (json['windspeed_10m'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      windDirection: (json['winddirection_10m'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      relativeHumidity: (json['relativehumidity_2m'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      surfacePressure: (json['surface_pressure'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      visibility: (json['visibility'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      isDay: (json['is_day'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$HourlyForecastDataToJson(HourlyForecastData instance) =>
    <String, dynamic>{
      'time': instance.time,
      'temperature_2m': instance.temperature,
      'apparent_temperature': instance.apparentTemperature,
      'precipitation': instance.precipitation,
      'weathercode': instance.weatherCode,
      'windspeed_10m': instance.windSpeed,
      'winddirection_10m': instance.windDirection,
      'relativehumidity_2m': instance.relativeHumidity,
      'surface_pressure': instance.surfacePressure,
      'visibility': instance.visibility,
      'is_day': instance.isDay,
    };
