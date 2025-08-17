// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_forecast_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyForecastResponse _$DailyForecastResponseFromJson(
  Map<String, dynamic> json,
) => DailyForecastResponse(
  daily: DailyForecastData.fromJson(json['daily'] as Map<String, dynamic>),
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  generationTimeMs: (json['generationtime_ms'] as num).toDouble(),
  utcOffsetSeconds: (json['utc_offset_seconds'] as num).toInt(),
  timezone: json['timezone'] as String,
  timezoneAbbreviation: json['timezone_abbreviation'] as String,
  elevation: (json['elevation'] as num).toDouble(),
);

Map<String, dynamic> _$DailyForecastResponseToJson(
  DailyForecastResponse instance,
) => <String, dynamic>{
  'daily': instance.daily,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'generationtime_ms': instance.generationTimeMs,
  'utc_offset_seconds': instance.utcOffsetSeconds,
  'timezone': instance.timezone,
  'timezone_abbreviation': instance.timezoneAbbreviation,
  'elevation': instance.elevation,
};

DailyForecastData _$DailyForecastDataFromJson(
  Map<String, dynamic> json,
) => DailyForecastData(
  time: (json['time'] as List<dynamic>).map((e) => e as String).toList(),
  weatherCode: (json['weathercode'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  temperatureMax: (json['temperature_2m_max'] as List<dynamic>)
      .map((e) => (e as num).toDouble())
      .toList(),
  temperatureMin: (json['temperature_2m_min'] as List<dynamic>)
      .map((e) => (e as num).toDouble())
      .toList(),
  apparentTemperatureMax: (json['apparent_temperature_max'] as List<dynamic>?)
      ?.map((e) => (e as num).toDouble())
      .toList(),
  apparentTemperatureMin:
      (json['apparent_temperature_min'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList() ??
      [],
  sunriseTime:
      (json['sunrise'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  sunsetTime:
      (json['sunset'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  precipitationSum:
      (json['precipitation_sum'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList() ??
      [],
  precipitationHours: (json['precipitation_hours'] as List<dynamic>?)
      ?.map((e) => (e as num).toDouble())
      .toList(),
  windSpeedMax:
      (json['windspeed_10m_max'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList() ??
      [],
  windGustsMax: (json['windgusts_10m_max'] as List<dynamic>?)
      ?.map((e) => (e as num).toDouble())
      .toList(),
  windDirection: (json['winddirection_10m_dominant'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  relativeHumidity: (json['relativehumidity_2m_mean'] as List<dynamic>?)
      ?.map((e) => (e as num).toDouble())
      .toList(),
  uvIndex: (json['uv_index_max'] as List<dynamic>?)
      ?.map((e) => (e as num).toDouble())
      .toList(),
);

Map<String, dynamic> _$DailyForecastDataToJson(DailyForecastData instance) =>
    <String, dynamic>{
      'time': instance.time,
      'weathercode': instance.weatherCode,
      'temperature_2m_max': instance.temperatureMax,
      'temperature_2m_min': instance.temperatureMin,
      'apparent_temperature_max': instance.apparentTemperatureMax,
      'apparent_temperature_min': instance.apparentTemperatureMin,
      'sunrise': instance.sunriseTime,
      'sunset': instance.sunsetTime,
      'precipitation_sum': instance.precipitationSum,
      'precipitation_hours': instance.precipitationHours,
      'windspeed_10m_max': instance.windSpeedMax,
      'windgusts_10m_max': instance.windGustsMax,
      'winddirection_10m_dominant': instance.windDirection,
      'relativehumidity_2m_mean': instance.relativeHumidity,
      'uv_index_max': instance.uvIndex,
    };
